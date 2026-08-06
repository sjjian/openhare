//go:build duckdb_arrow

package duckdb

/*
#include <stdlib.h>
#include <stdint.h>

#ifndef ARROW_C_DATA_INTERFACE
#define ARROW_C_DATA_INTERFACE

#define ARROW_FLAG_DICTIONARY_ORDERED 1
#define ARROW_FLAG_NULLABLE 2
#define ARROW_FLAG_MAP_KEYS_SORTED 4

struct ArrowSchema {
  // Array type description
  const char* format;
  const char* name;
  const char* metadata;
  int64_t flags;
  int64_t n_children;
  struct ArrowSchema** children;
  struct ArrowSchema* dictionary;

  // Release callback
  void (*release)(struct ArrowSchema*);
  // Opaque producer-specific data
  void* private_data;
};

struct ArrowArray {
  // Array data description
  int64_t length;
  int64_t null_count;
  int64_t offset;
  int64_t n_buffers;
  int64_t n_children;
  const void** buffers;
  struct ArrowArray** children;
  struct ArrowArray* dictionary;

  // Release callback
  void (*release)(struct ArrowArray*);
  // Opaque producer-specific data
  void* private_data;
};

struct ArrowArrayStream {
	void (*get_schema)(struct ArrowArrayStream*);
	void (*get_next)(struct ArrowArrayStream*);
	void (*get_last_error)(struct ArrowArrayStream*);
	void (*release)(struct ArrowArrayStream*);
	void* private_data;
};

#endif  // ARROW_C_DATA_INTERFACE
*/
import "C"

import (
	"context"
	"database/sql/driver"
	"errors"
	"fmt"
	"sync"
	"unsafe"

	"github.com/apache/arrow-go/v18/arrow"
	"github.com/apache/arrow-go/v18/arrow/array"
	"github.com/apache/arrow-go/v18/arrow/cdata"

	"github.com/duckdb/duckdb-go/v2/arrowmapping"
	"github.com/duckdb/duckdb-go/v2/mapping"
)

// Arrow exposes DuckDB Apache Arrow interface.
// https://duckdb.org/docs/api/c/api#arrow-interface
type Arrow struct {
	conn *Conn
}

// NewArrowFromConn returns a new Arrow from a DuckDB driver connection.
func NewArrowFromConn(driverConn driver.Conn) (*Arrow, error) {
	conn, ok := driverConn.(*Conn)
	if !ok {
		return nil, fmt.Errorf("not a duckdb driver connection")
	}
	if conn.closed {
		return nil, errClosedCon
	}

	return &Arrow{conn: conn}, nil
}

// QueryContext prepares statements, executes them, and returns an Apache Arrow array.RecordReader as a result of the last
// executed statement. Arguments are bound to the last statement.
func (a *Arrow) QueryContext(ctx context.Context, query string, args ...any) (array.RecordReader, error) {
	if a.conn.closed {
		return nil, errClosedCon
	}

	r, err := a.conn.QueryContext(ctx, query, a.anyArgsToNamedArgs(args))
	if err != nil {
		if r != nil {
			err = errors.Join(err, r.Close())
		}
		return nil, err
	}

	return recordReaderFromRows(ctx, r)
}

var errArrowScan = errors.New("could not register arrow view due to arrow scan API failure")

// RegisterView registers an Arrow record reader as a view with the given name in DuckDB.
// The returned release function must be called to release the memory once the view is no longer needed.
func (a *Arrow) RegisterView(reader array.RecordReader, name string) (release func(), err error) {
	if a.conn.closed {
		return nil, errClosedCon
	}

	stream := C.calloc(1, C.sizeof_struct_ArrowArrayStream)
	release = func() {
		cdata.ReleaseCArrowArrayStream((*cdata.CArrowArrayStream)(stream))
		C.free(stream)
	}
	cdata.ExportRecordReader(reader, (*cdata.CArrowArrayStream)(stream))

	arrowStream := arrowmapping.ArrowStream{
		Ptr: unsafe.Pointer(stream),
	}
	if arrowmapping.ArrowScan(a.conn.conn, name, arrowStream) == mapping.StateError {
		release()
		return nil, errArrowScan
	}

	return release, nil
}

func (a *Arrow) anyArgsToNamedArgs(args []any) []driver.NamedValue {
	if len(args) == 0 {
		return nil
	}

	values := make([]driver.Value, len(args))
	for i, arg := range args {
		values[i] = arg
	}

	return argsToNamedArgs(values)
}

var _ array.RecordReader = (*recordReader)(nil)

type recordReader struct {
	ctx    context.Context
	res    mapping.Result
	opts   arrowmapping.ArrowOptions
	schema *arrow.Schema
	rows   *rows

	mu       sync.Mutex // protects err and current
	refCount int64
	closed   bool // tracks if the reader has been closed/released
	current  arrow.RecordBatch
	err      error
}

func recordReaderFromRows(ctx context.Context, from driver.Rows) (array.RecordReader, error) {
	rr, ok := from.(*rows)
	if !ok {
		return nil, fmt.Errorf("not a duckdb rows")
	}
	if rr.stmt == nil || rr.stmt.closed || rr.stmt.conn == nil || rr.stmt.conn.closed {
		return nil, errClosedCon
	}
	if rr.rowCount != 0 {
		return nil, fmt.Errorf("cannot convert duckdb rows to arrow reader after reading has started")
	}
	// arrow options
	arrowOptions := arrowmapping.ResultGetArrowOptions(&rr.res)
	// get arrow schema
	cc := mapping.ColumnCount(&rr.res)
	names := make([]string, cc)
	types := make([]mapping.LogicalType, cc)
	for i := range cc {
		names[i] = mapping.ColumnName(&rr.res, i)
		types[i] = mapping.ColumnLogicalType(&rr.res, i)
	}
	defer func() {
		for i := range cc {
			mapping.DestroyLogicalType(&types[i])
		}
	}()

	schema, ed := arrowmapping.NewArrowSchema(arrowOptions, types, names)
	if err := errorDataError(ed); err != nil {
		defer arrowmapping.DestroyArrowOptions(&arrowOptions)
		return nil, fmt.Errorf("failed to create arrow schema: %w", err)
	}

	return &recordReader{
		ctx:      ctx,
		res:      rr.res,
		opts:     arrowOptions,
		schema:   schema,
		rows:     rr,
		refCount: 1,
	}, nil
}

func (r *recordReader) Retain() {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.err != nil || r.closed {
		return // Do not increase refCount if there is an error or if closed.
	}
	r.refCount++
}

func (r *recordReader) Release() {
	r.mu.Lock()
	defer r.mu.Unlock()

	if r.refCount <= 0 {
		return // Do not release if refCount is already zero.
	}
	r.refCount--
	if r.refCount != 0 {
		return // Do not release if there are still references.
	}

	// If this is the last reference, we need to clean up.
	r.closed = true
	if r.current != nil {
		r.current.Release()
		r.current = nil
	}
	arrowmapping.DestroyArrowOptions(&r.opts)
	r.err = r.rows.Close()
}

func (r *recordReader) Schema() *arrow.Schema {
	return r.schema
}

func (r *recordReader) Next() bool {
	r.mu.Lock()
	defer r.mu.Unlock()

	if r.current != nil {
		r.current.Release()
		r.current = nil
	}

	if r.closed {
		r.err = errors.New("arrow reader has been closed")
		return false
	}
	if r.err != nil {
		return false
	}

	select {
	case <-r.ctx.Done():
		r.err = r.ctx.Err()
		return false
	default:
		chunk := mapping.FetchChunk(r.res)
		if chunk.Ptr == nil {
			return false
		}
		defer mapping.DestroyDataChunk(&chunk)
		rec, ed := arrowmapping.DataChunkToArrowArray(r.opts, r.schema, chunk)
		if err := errorDataError(ed); err != nil {
			r.err = fmt.Errorf("failed to create arrow array: %w", err)
			return false
		}
		r.current = rec
		return true
	}
}

func (r *recordReader) Record() arrow.RecordBatch {
	return r.RecordBatch()
}

func (r *recordReader) RecordBatch() arrow.RecordBatch {
	r.mu.Lock()
	defer r.mu.Unlock()

	if r.err != nil {
		return nil
	}
	return r.current
}

func (r *recordReader) Err() error {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.err
}
