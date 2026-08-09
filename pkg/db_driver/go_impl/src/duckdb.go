package main

import (
	"context"
	"database/sql/driver"
	"errors"
	"fmt"
	"io"
	"strings"
	"sync"
	"time"

	duckdb "github.com/duckdb/duckdb-go/v2"
)

func duckdbDataType(typeName string) int32 {
	t := strings.ToUpper(strings.TrimSpace(typeName))

	switch {
	case strings.Contains(t, "INT"),
		strings.Contains(t, "HUGEINT"),
		strings.Contains(t, "UBIGINT"),
		strings.Contains(t, "UINTEGER"),
		strings.Contains(t, "USMALLINT"),
		strings.Contains(t, "UTINYINT"),
		strings.Contains(t, "FLOAT"),
		strings.Contains(t, "DOUBLE"),
		strings.Contains(t, "DECIMAL"),
		strings.Contains(t, "NUMERIC"),
		strings.Contains(t, "REAL"),
		t == "BIGINT" || t == "SMALLINT" || t == "TINYINT" || t == "INTEGER" || t == "HUGEINT":
		return dataTypeNumber
	case strings.Contains(t, "VARCHAR"),
		strings.Contains(t, "CHAR"),
		strings.Contains(t, "TEXT"),
		strings.Contains(t, "STRING"),
		strings.Contains(t, "UUID"),
		strings.Contains(t, "ENUM"):
		return dataTypeChar
	case strings.Contains(t, "DATE"),
		strings.Contains(t, "TIME"),
		strings.Contains(t, "TIMESTAMP"),
		strings.Contains(t, "INTERVAL"):
		return dataTypeTime
	case strings.Contains(t, "BLOB"),
		strings.Contains(t, "BYTEA"),
		strings.Contains(t, "BINARY"),
		strings.Contains(t, "BIT"):
		return dataTypeBlob
	case strings.Contains(t, "JSON"):
		return dataTypeJson
	case strings.Contains(t, "BOOLEAN"), t == "BOOL":
		return dataTypeDataSet
	case strings.Contains(t, "LIST"),
		strings.Contains(t, "ARRAY"),
		strings.Contains(t, "STRUCT"),
		strings.Contains(t, "MAP"),
		strings.Contains(t, "UNION"):
		return dataTypeJson
	default:
		return dataTypeChar
	}
}

// duckdbConn 使用 duckdb-go 的 Connector + Conn，不经过 database/sql.DB。
type duckdbConn struct {
	connector    *duckdb.Connector
	conn         *duckdb.Conn
	streamMu     sync.Mutex
	streamCancel context.CancelFunc
	killIssued   bool
}

func (c *duckdbConn) Close() error {
	var err error
	if c.conn != nil {
		err = c.conn.Close()
		c.conn = nil
	}
	if c.connector != nil {
		if e := c.connector.Close(); e != nil && err == nil {
			err = e
		}
		c.connector = nil
	}
	return err
}

func (c *duckdbConn) killed() bool {
	c.streamMu.Lock()
	defer c.streamMu.Unlock()
	return c.killIssued
}

func (c *duckdbConn) KillQuery() error {
	c.streamMu.Lock()
	c.killIssued = true
	fn := c.streamCancel
	c.streamMu.Unlock()
	if fn != nil {
		fn()
	}
	return nil
}

func (c *duckdbConn) OpenQuery(sqlText string) (rowCursor, error) {
	// 与 sqlite 相同：cancel 必须跨整个 cursor 生命周期，由 cur.Close 释放。
	ctx, cancel := context.WithCancel(context.Background())

	c.streamMu.Lock()
	c.killIssued = false
	c.streamCancel = cancel
	c.streamMu.Unlock()

	cur, err := c.openQuery(ctx, sqlText)
	if err != nil {
		c.streamMu.Lock()
		killed := c.killIssued
		c.streamCancel = nil
		c.streamMu.Unlock()
		cancel()
		if killed || isDuckdbInterrupt(err) {
			return nil, newStreamQueryCancelled(err)
		}
		return nil, err
	}
	cur.parent = c
	cur.cancel = cancel
	return cur, nil
}

func (c *duckdbConn) openQuery(ctx context.Context, sqlText string) (*duckdbCur, error) {
	rows, err := c.conn.QueryContext(ctx, sqlText, nil)
	if err != nil {
		return nil, err
	}

	names := rows.Columns()
	columns := make([]dbQueryColumn, 0, len(names))
	var rowsIface driver.Rows = rows
	ct, hasCT := rowsIface.(driver.RowsColumnTypeDatabaseTypeName)
	for i, name := range names {
		dbType := ""
		if hasCT {
			dbType = ct.ColumnTypeDatabaseTypeName(i)
		}
		columns = append(columns, dbQueryColumn{
			name:     name,
			dataType: duckdbDataType(dbType),
		})
	}

	return &duckdbCur{rows: rows, columns: columns}, nil
}

type duckdbCur struct {
	parent  *duckdbConn
	cancel  context.CancelFunc
	rows    driver.Rows
	columns []dbQueryColumn
	done    bool
}

func (q *duckdbCur) Close() error {
	if q.cancel != nil {
		if q.parent != nil {
			q.parent.streamMu.Lock()
			q.parent.streamCancel = nil
			q.parent.streamMu.Unlock()
		}
		q.cancel()
		q.cancel = nil
	}
	if q.rows == nil {
		return nil
	}
	return q.rows.Close()
}

func (q *duckdbCur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: 0,
	}
}

func (q *duckdbCur) NextRow() (*dbQueryRow, bool, error) {
	if q.done {
		return nil, false, nil
	}
	dest := make([]driver.Value, len(q.columns))
	if err := q.rows.Next(dest); err != nil {
		if errors.Is(err, io.EOF) {
			q.done = true
			return nil, false, nil
		}
		if q.parent != nil && (q.parent.killed() || isDuckdbInterrupt(err)) {
			return nil, false, newStreamQueryCancelled(err)
		}
		return nil, false, err
	}

	values := make([]dbQueryValue, 0, len(dest))
	for _, v := range dest {
		values = append(values, buildQueryValue(v))
	}
	return &dbQueryRow{values: values}, true, nil
}

func isDuckdbInterrupt(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) {
		return true
	}
	return strings.Contains(err.Error(), "INTERRUPT")
}

func openDuckdbConn(dsn string) (driverConn, error) {
	if dsn == "" {
		dsn = ":memory:"
	}
	connector, err := duckdb.NewConnector(dsn, nil)
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	dc, err := connector.Connect(ctx)
	if err != nil {
		_ = connector.Close()
		return nil, err
	}
	conn, ok := dc.(*duckdb.Conn)
	if !ok {
		_ = dc.Close()
		_ = connector.Close()
		return nil, fmt.Errorf("duckdb: unexpected driver.Conn type %T", dc)
	}

	pingRows, err := conn.QueryContext(ctx, "SELECT 1", nil)
	if err != nil {
		_ = conn.Close()
		_ = connector.Close()
		return nil, err
	}
	_ = pingRows.Close()

	return &duckdbConn{connector: connector, conn: conn}, nil
}
