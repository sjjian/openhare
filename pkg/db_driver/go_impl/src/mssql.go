package main

import (
	"context"
	"database/sql/driver"
	"errors"
	"fmt"
	"io"
	"sync"
	"time"

	mssql "github.com/microsoft/go-mssqldb"
)

// MSSQL 类型名称常量（来源：github.com/microsoft/go-mssqldb）
// 参考：MSSQL 官方文档和 go-mssqldb 驱动实现
const (
	// Number types
	// https://learn.microsoft.com/en-us/sql/t-sql/data-types/numeric-types
	mssqlInt        = "int"
	mssqlBigint     = "bigint"
	mssqlSmallint   = "smallint"
	mssqlTinyint    = "tinyint"
	mssqlDecimal    = "decimal"
	mssqlNumeric    = "numeric"
	mssqlMoney      = "money"
	mssqlSmallmoney = "smallmoney"
	mssqlFloat      = "float"
	mssqlReal       = "real"

	// Character types
	// https://learn.microsoft.com/en-us/sql/t-sql/data-types/char-and-varchar-transact-sql
	mssqlChar             = "char"
	mssqlVarchar          = "varchar"
	mssqlText             = "text"
	mssqlNchar            = "nchar"
	mssqlNvarchar         = "nvarchar"
	mssqlNtext            = "ntext"
	mssqlUniqueidentifier = "uniqueidentifier"

	// Date/Time types
	// https://learn.microsoft.com/en-us/sql/t-sql/data-types/date-and-time-types
	mssqlDate           = "date"
	mssqlTime           = "time"
	mssqlDatetime       = "datetime"
	mssqlDatetime2      = "datetime2"
	mssqlSmalldatetime  = "smalldatetime"
	mssqlDatetimeoffset = "datetimeoffset"

	// Binary types
	// https://learn.microsoft.com/en-us/sql/t-sql/data-types/binary-and-varbinary-transact-sql
	mssqlBinary    = "binary"
	mssqlVarbinary = "varbinary"
	mssqlImage     = "image"

	// Special types
	mssqlBit = "bit"
	mssqlXml = "xml"
)

// mssqlConn 直接使用 go-mssqldb 的 driver.Conn（*mssql.Conn），不经过 database/sql.DB。
type mssqlConn struct {
	conn         *mssql.Conn
	streamMu     sync.Mutex
	streamCancel context.CancelFunc
}

func (c *mssqlConn) Close() error {
	return c.conn.Close()
}

func mssqlDataType(typeName string) int32 {
	// MSSQL 类型名称精确匹配
	switch typeName {
	// Number types
	case mssqlInt, mssqlBigint, mssqlSmallint, mssqlTinyint,
		mssqlDecimal, mssqlNumeric,
		mssqlMoney, mssqlSmallmoney,
		mssqlFloat, mssqlReal:
		return dataTypeNumber

	// Character types
	case mssqlChar, mssqlVarchar, mssqlText,
		mssqlNchar, mssqlNvarchar, mssqlNtext,
		mssqlUniqueidentifier:
		return dataTypeChar

	// Date/Time types
	case mssqlDate, mssqlTime,
		mssqlDatetime, mssqlDatetime2, mssqlSmalldatetime, mssqlDatetimeoffset:
		return dataTypeTime

	// Binary types
	case mssqlBinary, mssqlVarbinary, mssqlImage:
		return dataTypeBlob

	// Special types
	case mssqlBit:
		return dataTypeDataSet
	case mssqlXml:
		return dataTypeJson

	default:
		return dataTypeChar
	}
}

func (c *mssqlConn) KillQuery() error {
	c.streamMu.Lock()
	fn := c.streamCancel
	c.streamMu.Unlock()
	if fn != nil {
		fn()
	}
	return nil
}

func (c *mssqlConn) OpenQuery(sqlText string) (rowCursor, error) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	c.streamMu.Lock()
	c.streamCancel = cancel
	c.streamMu.Unlock()

	var cur rowCursor
	var err error
	cur, err = c.openQuery(ctx, sqlText)
	if err != nil {
		if errors.Is(err, context.Canceled) {
			err = newStreamQueryCancelled(err)
		}
	}
	c.streamMu.Lock()
	c.streamCancel = nil
	c.streamMu.Unlock()
	return cur, err
}

func (c *mssqlConn) openQuery(ctx context.Context, sqlText string) (*mssqlCur, error) {
	st, err := c.conn.PrepareContext(ctx, sqlText)
	if err != nil {
		return nil, err
	}
	stmt, ok := st.(*mssql.Stmt)
	if !ok {
		_ = st.Close()
		return nil, fmt.Errorf("mssql: unexpected driver.Stmt type %T", st)
	}
	qrows, err := stmt.QueryContext(ctx, nil)
	if err != nil {
		_ = stmt.Close()
		return nil, err
	}
	mr, ok := qrows.(*mssql.Rows)
	if !ok {
		_ = qrows.Close()
		return nil, fmt.Errorf("mssql: unexpected driver.Rows type %T", qrows)
	}

	names := mr.Columns()
	columns := make([]dbQueryColumn, 0, len(names))
	var drvRows driver.Rows = mr
	ct, hasCT := drvRows.(driver.RowsColumnTypeDatabaseTypeName)
	for i, name := range names {
		dbType := ""
		if hasCT {
			dbType = ct.ColumnTypeDatabaseTypeName(i)
		}
		columns = append(columns, dbQueryColumn{
			name:     name,
			dataType: mssqlDataType(dbType),
		})
	}

	return &mssqlCur{rows: mr, columns: columns}, nil
}

type mssqlCur struct {
	rows    *mssql.Rows
	columns []dbQueryColumn
}

func (q *mssqlCur) Close() error {
	return q.rows.Close()
}

func (q *mssqlCur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: q.rows.DriverRowsAffected(),
	}
}

func (q *mssqlCur) NextRow() (*dbQueryRow, bool, error) {
	dest := make([]driver.Value, len(q.columns))
	if err := q.rows.Next(dest); err != nil {
		if errors.Is(err, io.EOF) {
			return nil, false, nil
		}
		return nil, false, err
	}
	values := make([]dbQueryValue, 0, len(dest))
	for _, v := range dest {
		values = append(values, buildQueryValue(v))
	}
	return &dbQueryRow{values: values}, true, nil
}

func openMssqlConn(dsn string) (driverConn, error) {
	connector, err := mssql.NewConnector(dsn)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	dc, err := connector.Connect(ctx)
	if err != nil {
		return nil, err
	}
	mc, ok := dc.(*mssql.Conn)
	if !ok {
		_ = dc.Close()
		return nil, fmt.Errorf("mssql: unexpected driver.Conn type %T", dc)
	}
	if err := mc.Ping(ctx); err != nil {
		_ = mc.Close()
		return nil, err
	}
	return &mssqlConn{conn: mc}, nil
}
