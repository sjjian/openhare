package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"reflect"
	"strings"
	"sync"
	"time"

	"github.com/ClickHouse/clickhouse-go/v2"
	"github.com/ClickHouse/clickhouse-go/v2/lib/driver"
	"github.com/google/uuid"
)

// clickhouseErrQueryWasCancelled 对应 ClickHouse ErrorCodes::QUERY_WAS_CANCELLED。
const clickhouseErrQueryWasCancelled int32 = 394

type clickhouseConn struct {
	conn         driver.Conn
	dsn          string
	streamMu     sync.Mutex
	streamCancel context.CancelFunc
	queryID      string
	killIssued   bool
}

func clickhouseDataType(typeName string) int32 {
	t := strings.ToUpper(strings.TrimSpace(typeName))

	switch {
	case strings.Contains(t, "ARRAY"),
		strings.Contains(t, "MAP"),
		strings.Contains(t, "TUPLE"),
		strings.Contains(t, "NESTED"),
		strings.Contains(t, "JSON"),
		strings.Contains(t, "OBJECT"),
		strings.Contains(t, "VARIANT"),
		strings.Contains(t, "DYNAMIC"):
		return dataTypeJson
	case strings.Contains(t, "DATE"),
		strings.Contains(t, "TIME"),
		strings.Contains(t, "INTERVAL"):
		return dataTypeTime
	case strings.Contains(t, "INT"),
		strings.Contains(t, "FLOAT"),
		strings.Contains(t, "DECIMAL"),
		strings.Contains(t, "NUMERIC"),
		strings.Contains(t, "BOOL"),
		strings.Contains(t, "BFLOAT"):
		return dataTypeNumber
	case strings.Contains(t, "STRING"),
		strings.Contains(t, "UUID"),
		strings.Contains(t, "ENUM"),
		strings.Contains(t, "IPV"),
		strings.Contains(t, "FIXEDSTRING"):
		return dataTypeChar
	case strings.Contains(t, "BLOB"),
		strings.Contains(t, "BINARY"):
		return dataTypeBlob
	default:
		return dataTypeChar
	}
}

func (c *clickhouseConn) Close() error {
	if c.conn == nil {
		return nil
	}
	return c.conn.Close()
}

func (c *clickhouseConn) killed() bool {
	c.streamMu.Lock()
	defer c.streamMu.Unlock()
	return c.killIssued
}

func (c *clickhouseConn) clickhouseKillInterrupted(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) {
		return true
	}
	if !c.killed() {
		return false
	}
	var e *clickhouse.Exception
	if errors.As(err, &e) && e.Code == clickhouseErrQueryWasCancelled {
		return true
	}
	msg := strings.ToLower(err.Error())
	return strings.Contains(msg, "query was cancelled") || strings.Contains(msg, "canceled")
}

func (c *clickhouseConn) KillQuery() error {
	c.streamMu.Lock()
	c.killIssued = true
	fn := c.streamCancel
	queryID := c.queryID
	c.streamMu.Unlock()
	if fn != nil {
		fn()
	}
	if queryID == "" {
		return nil
	}

	opts, err := clickhouse.ParseDSN(c.dsn)
	if err != nil {
		return err
	}
	conn2, err := clickhouse.Open(opts)
	if err != nil {
		return err
	}
	defer conn2.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	escaped := strings.ReplaceAll(queryID, "'", "''")
	return conn2.Exec(ctx, fmt.Sprintf("KILL QUERY WHERE query_id = '%s'", escaped))
}

func (c *clickhouseConn) OpenQuery(sqlText string) (rowCursor, error) {
	ctx, cancel := context.WithCancel(context.Background())
	queryID := uuid.NewString()

	c.streamMu.Lock()
	c.killIssued = false
	c.streamCancel = cancel
	c.queryID = queryID
	c.streamMu.Unlock()

	cur, err := c.openQuery(ctx, queryID, sqlText)
	if err != nil {
		c.streamMu.Lock()
		killed := c.killIssued
		c.streamCancel = nil
		c.queryID = ""
		c.streamMu.Unlock()
		cancel()
		if killed || c.clickhouseKillInterrupted(err) {
			return nil, newStreamQueryCancelled(err)
		}
		return nil, err
	}
	cur.parent = c
	cur.cancel = cancel
	return cur, nil
}

func (c *clickhouseConn) openQuery(ctx context.Context, queryID, sqlText string) (*clickhouseCur, error) {
	chCtx := clickhouse.Context(ctx, clickhouse.WithQueryID(queryID))
	rows, err := c.conn.Query(chCtx, sqlText)
	if err != nil {
		if c.clickhouseKillInterrupted(err) {
			return nil, err
		}
		if errors.Is(err, io.EOF) {
			return &clickhouseCur{}, nil
		}
		return nil, err
	}

	names := rows.Columns()
	types := rows.ColumnTypes()
	columns := make([]dbQueryColumn, 0, len(names))
	for i, name := range names {
		dbType := ""
		if i < len(types) && types[i] != nil {
			dbType = types[i].DatabaseTypeName()
		}
		columns = append(columns, dbQueryColumn{
			name:     name,
			dataType: clickhouseDataType(dbType),
		})
	}

	return &clickhouseCur{rows: rows, columns: columns, columnTypes: types}, nil
}

type clickhouseCur struct {
	parent      *clickhouseConn
	cancel      context.CancelFunc
	rows        driver.Rows
	columns     []dbQueryColumn
	columnTypes []driver.ColumnType
	done        bool
}

func (q *clickhouseCur) Close() error {
	if q.cancel != nil {
		if q.parent != nil {
			q.parent.streamMu.Lock()
			q.parent.streamCancel = nil
			q.parent.queryID = ""
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

func (q *clickhouseCur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: 0,
	}
}

func (q *clickhouseCur) NextRow() (*dbQueryRow, bool, error) {
	if q.done || q.rows == nil {
		return nil, false, nil
	}
	if !q.rows.Next() {
		q.done = true
		if err := q.rows.Err(); err != nil {
			if q.parent != nil && q.parent.clickhouseKillInterrupted(err) {
				return nil, false, newStreamQueryCancelled(err)
			}
			return nil, false, err
		}
		return nil, false, nil
	}

	n := len(q.columns)
	dest := make([]any, n)
	for i := 0; i < n; i++ {
		if i < len(q.columnTypes) {
			dest[i] = clickhouseScanDest(q.columnTypes[i])
		} else {
			s := ""
			dest[i] = &s
		}
	}
	if err := q.rows.Scan(dest...); err != nil {
		if q.parent != nil && q.parent.clickhouseKillInterrupted(err) {
			return nil, false, newStreamQueryCancelled(err)
		}
		return nil, false, err
	}

	values := make([]dbQueryValue, 0, n)
	for _, d := range dest {
		values = append(values, buildQueryValue(clickhouseUnwrap(d)))
	}
	return &dbQueryRow{values: values}, true, nil
}

func clickhouseScanDest(ct driver.ColumnType) any {
	if ct == nil {
		s := ""
		return &s
	}
	st := ct.ScanType()
	if st == nil {
		s := ""
		return &s
	}
	return reflect.New(st).Interface()
}

func clickhouseUnwrap(dest any) any {
	if dest == nil {
		return nil
	}
	v := reflect.ValueOf(dest)
	for v.Kind() == reflect.Ptr {
		if v.IsNil() {
			return nil
		}
		v = v.Elem()
	}
	if !v.IsValid() {
		return nil
	}
	if v.Kind() == reflect.Interface {
		if v.IsNil() {
			return nil
		}
		return clickhouseWiden(v.Interface())
	}
	return clickhouseWiden(v.Interface())
}

func clickhouseWiden(v any) any {
	switch x := v.(type) {
	case int8:
		return int64(x)
	case int16:
		return int64(x)
	case uint8:
		return uint64(x)
	case uint16:
		return uint64(x)
	case uint:
		return uint64(x)
	default:
		return v
	}
}

func openClickhouseConn(dsn string) (driverConn, error) {
	opts, err := clickhouse.ParseDSN(dsn)
	if err != nil {
		return nil, err
	}
	// SQL 客户端会话需要复用同一条连接，否则 USE / 会话设置会丢。
	opts.MaxOpenConns = 1
	opts.MaxIdleConns = 1

	conn, err := clickhouse.Open(opts)
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	if err := conn.Ping(ctx); err != nil {
		_ = conn.Close()
		return nil, err
	}

	return &clickhouseConn{conn: conn, dsn: dsn}, nil
}
