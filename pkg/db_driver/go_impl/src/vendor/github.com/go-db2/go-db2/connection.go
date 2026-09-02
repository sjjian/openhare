package db2

import (
	"context"
	"database/sql/driver"
	"errors"
	"strings"
	"sync"

	"github.com/go-db2/go-db2/network"
)

// Conn implements the database/sql/driver.Conn interface for IBM Db2.
type Conn struct {
	session *network.Session
	cfg     *Config
	mu      sync.Mutex
	closed  bool
}

// NewConn wraps a connected network session into a database/sql driver.Conn.
func NewConn(session *network.Session, cfg *Config) *Conn {
	return &Conn{
		session: session,
		cfg:     cfg,
	}
}

// Prepare returns a prepared statement, bound to this connection.
func (c *Conn) Prepare(query string) (driver.Stmt, error) {
	return c.PrepareContext(context.Background(), query)
}

// PrepareContext returns a prepared statement, bound to this connection with context support.
func (c *Conn) PrepareContext(ctx context.Context, query string) (driver.Stmt, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return nil, ErrConnectionClosed
	}

	outCols, paramCols, err := c.session.PrepareAndDescribe(ctx, query)
	if err != nil {
		return nil, err
	}

	return NewStmt(c, query, outCols, paramCols), nil
}

// Exec executes a query that doesn't return rows (legacy interface).
func (c *Conn) Exec(query string, args []driver.Value) (driver.Result, error) {
	namedArgs := make([]driver.NamedValue, len(args))
	for i, v := range args {
		namedArgs[i] = driver.NamedValue{Ordinal: i + 1, Value: v}
	}
	return c.ExecContext(context.Background(), query, namedArgs)
}

// ExecContext executes a query without returning rows.
func (c *Conn) ExecContext(ctx context.Context, query string, args []driver.NamedValue) (driver.Result, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return nil, ErrConnectionClosed
	}

	// Auto-switch user if specified via WithUser in context
	if targetUser := UserFromContext(ctx); targetUser != "" && targetUser != c.session.CurrentUser() {
		if err := c.session.SwitchUser(ctx, targetUser); err != nil {
			return nil, err
		}
	}

	// Auto-set client info if specified via WithClientInfo in context
	if clientInfo := ClientInfoFromContext(ctx); !clientInfo.IsEmpty() {
		_ = c.session.SetClientInfo(ctx, clientInfo.ApplicationName, clientInfo.WorkstationName, clientInfo.UserID, clientInfo.Accounting, clientInfo.CorrelationToken)
	}

	if len(args) == 0 {
		affected, err := c.session.ExecDirect(ctx, query)
		if err != nil {
			return nil, err
		}
		return NewResultWithConn(c, affected, isInsertQuery(query)), nil
	}

	// Prepare and execute with parameters
	outCols, paramCols, err := c.session.PrepareAndDescribe(ctx, query)
	if err != nil {
		return nil, err
	}

	stmt := NewStmt(c, query, outCols, paramCols)
	return stmt.execContextLocked(ctx, args)
}

// Query executes a query that may return rows (legacy interface).
func (c *Conn) Query(query string, args []driver.Value) (driver.Rows, error) {
	namedArgs := make([]driver.NamedValue, len(args))
	for i, v := range args {
		namedArgs[i] = driver.NamedValue{Ordinal: i + 1, Value: v}
	}
	return c.QueryContext(context.Background(), query, namedArgs)
}

// QueryContext executes a query that may return rows.
func (c *Conn) QueryContext(ctx context.Context, query string, args []driver.NamedValue) (driver.Rows, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return nil, ErrConnectionClosed
	}

	// Auto-switch user if specified via WithUser in context
	if targetUser := UserFromContext(ctx); targetUser != "" && targetUser != c.session.CurrentUser() {
		if err := c.session.SwitchUser(ctx, targetUser); err != nil {
			return nil, err
		}
	}

	// Auto-set client info if specified via WithClientInfo in context
	if clientInfo := ClientInfoFromContext(ctx); !clientInfo.IsEmpty() {
		_ = c.session.SetClientInfo(ctx, clientInfo.ApplicationName, clientInfo.WorkstationName, clientInfo.UserID, clientInfo.Accounting, clientInfo.CorrelationToken)
	}

	if len(args) == 0 {
		if !isQueryStatement(query) {
			_, err := c.session.ExecDirect(ctx, query)
			if err != nil {
				return nil, err
			}
			return NewRows(nil, nil), nil
		}

		cols, rawRows, err := c.session.QueryDirect(ctx, query)
		if err != nil {
			return nil, err
		}

		rowsData := make([][]driver.Value, len(rawRows))
		for i, r := range rawRows {
			row := make([]driver.Value, len(r))
			for j, v := range r {
				row[j] = driver.Value(v)
			}
			rowsData[i] = row
		}

		return NewRows(cols, rowsData), nil
	}

	// Prepare and query with parameters
	outCols, paramCols, err := c.session.PrepareAndDescribe(ctx, query)
	if err != nil {
		return nil, err
	}

	stmt := NewStmt(c, query, outCols, paramCols)
	return stmt.queryContextLocked(ctx, args)
}

func stripLeadingCommentsAndSpaces(sql string) string {
	s := strings.TrimSpace(sql)
	for {
		if strings.HasPrefix(s, "--") {
			idx := strings.IndexByte(s, '\n')
			if idx == -1 {
				return ""
			}
			s = strings.TrimSpace(s[idx+1:])
			continue
		}
		if strings.HasPrefix(s, "/*") {
			idx := strings.Index(s, "*/")
			if idx == -1 {
				return ""
			}
			s = strings.TrimSpace(s[idx+2:])
			continue
		}
		if strings.HasPrefix(s, "(") {
			s = strings.TrimSpace(s[1:])
			continue
		}
		break
	}
	return s
}

func isQueryStatement(sql string) bool {
	cleaned := strings.ToUpper(stripLeadingCommentsAndSpaces(sql))
	return strings.HasPrefix(cleaned, "SELECT") ||
		strings.HasPrefix(cleaned, "WITH") ||
		strings.HasPrefix(cleaned, "VALUES") ||
		strings.HasPrefix(cleaned, "TABLE")
}

// CurrentUser returns the currently active user on this connection.
func (c *Conn) CurrentUser() string {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.closed || c.session == nil {
		return ""
	}
	return c.session.CurrentUser()
}

// SwitchUser transitions the active user identity on this connection within a trusted context or session.
func (c *Conn) SwitchUser(ctx context.Context, newUser string, password ...string) error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return ErrConnectionClosed
	}

	return c.session.SwitchUser(ctx, newUser, password...)
}

// SetClientInfo updates client info registers on this connection.
func (c *Conn) SetClientInfo(ctx context.Context, info ClientInfo) error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return ErrConnectionClosed
	}

	return c.session.SetClientInfo(ctx, info.ApplicationName, info.WorkstationName, info.UserID, info.Accounting, info.CorrelationToken)
}

// Close invalidates and closes the database connection.
func (c *Conn) Close() error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed {
		return nil
	}
	c.closed = true

	if c.session != nil {
		return c.session.Close()
	}
	return nil
}

// Begin starts and returns a new transaction (legacy interface).
func (c *Conn) Begin() (driver.Tx, error) {
	return c.BeginTx(context.Background(), driver.TxOptions{})
}

// BeginTx starts and returns a new transaction with the provided context and options.
func (c *Conn) BeginTx(ctx context.Context, opts driver.TxOptions) (driver.Tx, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return nil, ErrConnectionClosed
	}

	if opts.ReadOnly {
		return nil, errors.New("db2: read-only transactions are not supported")
	}

	// Disable auto-commit for explicit transaction scope
	c.session.SetAutoCommit(false)

	return &Tx{
		conn: c,
		ctx:  ctx,
	}, nil
}

// Ping implements driver.Pinger interface to verify connection liveness.
func (c *Conn) Ping(ctx context.Context) error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.closed || c.session == nil {
		return ErrConnectionClosed
	}

	return c.session.Ping(ctx)
}

// Interface assertions
// CheckNamedValue implements driver.NamedValueChecker interface.
func (c *Conn) CheckNamedValue(nv *driver.NamedValue) error {
	return nil
}

var (
	_ driver.Conn               = (*Conn)(nil)
	_ driver.ConnPrepareContext = (*Conn)(nil)
	_ driver.ConnBeginTx        = (*Conn)(nil)
	_ driver.Pinger             = (*Conn)(nil)
	_ driver.ExecerContext      = (*Conn)(nil)
	_ driver.QueryerContext     = (*Conn)(nil)
	_ driver.NamedValueChecker  = (*Conn)(nil)
)
