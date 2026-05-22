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

	sqlite3 "github.com/mattn/go-sqlite3"
)

const (
	sqliteInteger  = "INTEGER"
	sqliteInt      = "INT"
	sqliteBigInt   = "BIGINT"
	sqliteSmallInt = "SMALLINT"
	sqliteTinyInt  = "TINYINT"
	sqliteReal     = "REAL"
	sqliteDouble   = "DOUBLE"
	sqliteFloat    = "FLOAT"
	sqliteNumeric  = "NUMERIC"
	sqliteDecimal  = "DECIMAL"

	sqliteText    = "TEXT"
	sqliteChar    = "CHAR"
	sqliteVarchar = "VARCHAR"
	sqliteClob    = "CLOB"

	sqliteBlob = "BLOB"

	sqliteDate      = "DATE"
	sqliteDatetime  = "DATETIME"
	sqliteTime      = "TIME"
	sqliteTimestamp = "TIMESTAMP"

	sqliteJson = "JSON"
)

// sqliteConn 直接使用 go-sqlite3 的 driver.Conn（*sqlite3.SQLiteConn），不经过 database/sql.DB。
type sqliteConn struct {
	conn         *sqlite3.SQLiteConn
	streamMu     sync.Mutex
	streamCancel context.CancelFunc
	killIssued   bool
}

func (c *sqliteConn) Close() error {
	return c.conn.Close()
}

func (c *sqliteConn) killed() bool {
	c.streamMu.Lock()
	defer c.streamMu.Unlock()
	return c.killIssued
}

func sqliteDataType(typeName string) int32 {
	t := strings.ToUpper(strings.TrimSpace(typeName))

	if strings.Contains(t, "INT") {
		return dataTypeNumber
	}
	if strings.Contains(t, "REAL") || strings.Contains(t, "FLOA") ||
		strings.Contains(t, "DOUB") || strings.Contains(t, "NUMERIC") ||
		strings.Contains(t, "DECIMAL") {
		return dataTypeNumber
	}
	if strings.Contains(t, "CHAR") || strings.Contains(t, "CLOB") ||
		strings.Contains(t, "TEXT") {
		return dataTypeChar
	}
	if strings.Contains(t, "DATE") || strings.Contains(t, "TIME") {
		return dataTypeTime
	}
	if strings.Contains(t, "BLOB") {
		return dataTypeBlob
	}
	if strings.Contains(t, "JSON") {
		return dataTypeJson
	}

	return dataTypeChar
}

/*
测试耗时的SQL:
```sql
WITH RECURSIVE heavy_calc(n, val1, val2, val3, val4, val5, val6) AS (
   SELECT 1,
          ABS(CAST(RANDOM() AS REAL)),
          ABS(CAST(RANDOM() AS REAL)),
          ABS(CAST(RANDOM() AS REAL)),
          ABS(CAST(RANDOM() AS REAL)),
          ABS(CAST(RANDOM() AS REAL)),
          ABS(CAST(RANDOM() AS REAL))
   UNION ALL
   SELECT
      n+1,
      (val1 * 1.000001 + val2 * 0.000002 + val3 * 0.000003) % 10000000,
      (val2 * 1.000002 + val3 * 0.000003 + val4 * 0.000004) % 10000000,
      (val3 * 1.000003 + val4 * 0.000004 + val5 * 0.000005) % 10000000,
      (val4 * 1.000004 + val5 * 0.000005 + val6 * 0.000006) % 10000000,
      (val5 * 1.000005 + val6 * 0.000006 + val1 * 0.000001) % 10000000,
      (val6 * 1.000006 + val1 * 0.000001 + val2 * 0.000002) % 10000000
   FROM heavy_calc
   WHERE n < 20000000
)
SELECT COUNT(*) as total_iterations,
       AVG(val1) as avg_val1,
       AVG(val2) as avg_val2,
       AVG(val3) as avg_val3,
       AVG(val4) as avg_val4,
       AVG(val5) as avg_val5,
       AVG(val6) as avg_val6
FROM heavy_calc;
```
*/

func (c *sqliteConn) KillQuery() error {
	c.streamMu.Lock()
	c.killIssued = true
	fn := c.streamCancel
	c.streamMu.Unlock()
	if fn != nil {
		fn()
	}
	return nil
}

func (c *sqliteConn) OpenQuery(sqlText string) (rowCursor, error) {
	// 注意：不能 defer cancel()。go-sqlite3 把 ctx 保留到 SQLiteRows，NextRow 期间还要靠它响应 KillQuery；
	// cancel 由 cur.Close 调用，确保 ctx 跨整个 cursor 生命周期。
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
		if killed {
			return nil, newStreamQueryCancelled(err)
		}
		return nil, err
	}
	cur.parent = c
	cur.cancel = cancel
	return cur, nil
}

func (c *sqliteConn) openQuery(ctx context.Context, sqlText string) (*sqliteCur, error) {
	st, err := c.conn.PrepareContext(ctx, sqlText)
	if err != nil {
		return nil, err
	}
	stmt, ok := st.(*sqlite3.SQLiteStmt)
	if !ok {
		_ = st.Close()
		return nil, fmt.Errorf("sqlite: unexpected driver.Stmt type %T", st)
	}
	dr, err := stmt.QueryContext(ctx, nil)
	if err != nil {
		_ = stmt.Close()
		return nil, err
	}
	sr, ok := dr.(*sqlite3.SQLiteRows)
	if !ok {
		_ = dr.Close()
		return nil, fmt.Errorf("sqlite: unexpected driver.Rows type %T", dr)
	}

	names := sr.Columns()
	columns := make([]dbQueryColumn, 0, len(names))
	var rowsIface driver.Rows = sr
	ct, hasCT := rowsIface.(driver.RowsColumnTypeDatabaseTypeName)
	for i, name := range names {
		dbType := ""
		if hasCT {
			dbType = ct.ColumnTypeDatabaseTypeName(i)
		}
		columns = append(columns, dbQueryColumn{
			name:     name,
			dataType: sqliteDataType(dbType),
		})
	}

	cur := &sqliteCur{conn: c.conn, rows: sr, columns: columns}
	// INSERT/UPDATE/DELETE 无结果列时，Query 返回后尚未 step，sqlite3_changes 要在语句执行后才有效。
	// 先拉完空结果，首包 HEADER 才能带上与 Exec 一致的受影响行数。
	if len(columns) == 0 {
		if err := cur.stepNoColumnResult(); err != nil {
			_ = sr.Close()
			return nil, err
		}
	}
	return cur, nil
}

// stepNoColumnResult 对无列结果集执行一次 Next 直至 EOF，使 sqlite3_changes 在首包 HEADER 前已更新。
func (q *sqliteCur) stepNoColumnResult() error {
	dest := []driver.Value{}
	if err := q.rows.Next(dest); err != nil && !errors.Is(err, io.EOF) {
		return err
	}
	q.done = true
	q.affectedRows = q.conn.DriverChanges()
	return nil
}

type sqliteCur struct {
	parent       *sqliteConn // 外层 sqliteConn，用于 NextRow 错误归一化 + Close 时清理 streamCancel
	cancel       context.CancelFunc
	conn         *sqlite3.SQLiteConn
	rows         *sqlite3.SQLiteRows
	columns      []dbQueryColumn
	affectedRows int64
	done         bool
}

func (q *sqliteCur) Close() error {
	if q.cancel != nil {
		if q.parent != nil {
			q.parent.streamMu.Lock()
			q.parent.streamCancel = nil
			q.parent.streamMu.Unlock()
		}
		q.cancel()
		q.cancel = nil
	}
	return q.rows.Close()
}

func (q *sqliteCur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: q.affectedRows,
	}
}

func (q *sqliteCur) NextRow() (*dbQueryRow, bool, error) {
	if q.done {
		return nil, false, nil
	}
	dest := make([]driver.Value, len(q.columns))
	if err := q.rows.Next(dest); err != nil {
		if errors.Is(err, io.EOF) {
			q.done = true
			return nil, false, nil
		}
		if q.parent != nil && q.parent.killed() {
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

func openSqliteConn(dsn string) (driverConn, error) {
	d := &sqlite3.SQLiteDriver{}
	dc, err := d.Open(dsn)
	if err != nil {
		return nil, err
	}
	conn, ok := dc.(*sqlite3.SQLiteConn)
	if !ok {
		_ = dc.Close()
		return nil, fmt.Errorf("sqlite: unexpected driver.Conn type %T", dc)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	if err := conn.Ping(ctx); err != nil {
		_ = conn.Close()
		return nil, err
	}
	return &sqliteConn{conn: conn}, nil
}
