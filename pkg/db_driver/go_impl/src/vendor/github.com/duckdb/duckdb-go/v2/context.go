package duckdb

import (
	"context"
	"sync"
	"time"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// contextStore stores the thread-safe context of a connection.
type contextStore struct {
	m sync.Map
}

// newContextStore creates a new instance of ctxStore.
func newContextStore() *contextStore {
	return &contextStore{
		m: sync.Map{},
	}
}

func (s *contextStore) load(connId uint64) context.Context {
	v, ok := s.m.Load(connId)
	if !ok {
		return context.Background()
	}
	ctx, ok := v.(context.Context)
	if !ok {
		return context.Background()
	}

	return ctx
}

func (s *contextStore) store(connId uint64, ctx context.Context, replace bool) func() {
	if !replace {
		_, ok := s.m.Load(connId)
		if ok {
			return func() {}
		}
	}

	s.m.Store(connId, ctx)

	return func() {
		s.delete(connId)
	}
}

func (s *contextStore) delete(connId uint64) {
	s.m.Delete(connId)
}

// How frequently to `duckdb_interrupt` after ctx cancellation while the DuckDB call is still executing.
var interruptInterval = 500 * time.Millisecond

// runWithCtxInterrupt runs the function fn (which runs DuckDB mapping call/s),
// and robustly propagates ctx cancellation to DuckDB by repeatedly calling
// mapping.Interrupt on the given connection while the call is in flight.
//
// Semantics:
//
//   - Short-circuit - if ctx is already canceled, the call is not started and ctx.Err() is returned.
//
//   - While fn is executing, and after ctx is canceled, we repeatedly invoke
//     duckdb_interrupt(conn) until fn returns, for cases when the interruptions are cleared internally in DuckDB.
//
//   - The interrupt loop is strictly scoped to the lifetime of this call and
//     stops immediately when fn returns, to avoid goroutine leaks.
//
//   - We never call interrupt unless ctx is canceled.
//
//   - The callback fn receives a derived context that carries an internal marker.
//     Any nested calls of runWithCtxInterrupt must pass that context forward
//     so the marker can suppress additional interrupter goroutines.
func runWithCtxInterrupt(ctx context.Context, conn mapping.Connection, fn func(context.Context) error) error {
	// Short circuit: do not start the DuckDB call if context is already canceled.
	if err := ctx.Err(); err != nil {
		return err
	}

	// guard: if an interrupter is already active for this call, don’t spawn another.
	// We tag the context to indicate an active interrupter scope.
	type interruptActiveKey struct{}
	if ctx.Value(interruptActiveKey{}) != nil {
		return fn(ctx)
	}
	ctx = context.WithValue(ctx, interruptActiveKey{}, struct{}{})

	bgDoneCh := make(chan struct{})
	done := make(chan struct{})

	go interrupterRoutine(ctx, conn, done, bgDoneCh)

	// We pass `ctx` to keep that "enriched" context with the mark that we've already spawned a go-routine
	err := fn(ctx)

	close(done)

	// Wait for interrupter goroutine to finish
	// Sometimes the go-routine is not scheduled immediately.
	// By the time it is scheduled, another query might be running on this connection.
	// If we don't wait for the go-routine to finish, it can cancel that new query.
	<-bgDoneCh
	return err
}

func interrupterRoutine(ctx context.Context, conn mapping.Connection, done <-chan struct{}, bgDoneCh chan<- struct{}) {
	select {
	case <-ctx.Done():
	case <-done:
		// finished before cancellation
		close(bgDoneCh)
		return
	}

	// Re-assert interruption until the wrapped function finishes.
	for {
		select {
		case <-done:
			close(bgDoneCh)
			return
		default:
			mapping.Interrupt(conn)
			time.Sleep(interruptInterval)
		}
	}
}
