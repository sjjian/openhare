package main

import (
	"context"
	"database/sql/driver"
	"errors"
	"fmt"
	"io"
	"sync/atomic"
	"time"

	"github.com/go-sql-driver/mysql"
)

const (
	mysqlTinyint    = "TINYINT"
	mysqlSmallint   = "SMALLINT"
	mysqlMediumint  = "MEDIUMINT"
	mysqlInt        = "INT"
	mysqlInteger    = "INTEGER"
	mysqlBigint     = "BIGINT"
	mysqlFloat      = "FLOAT"
	mysqlDouble     = "DOUBLE"
	mysqlDoublePrec = "DOUBLE PRECISION"
	mysqlReal       = "REAL"
	mysqlDecimal    = "DECIMAL"
	mysqlDec        = "DEC"
	mysqlNumeric    = "NUMERIC"
	mysqlFixed      = "FIXED"
	mysqlBit        = "BIT"

	mysqlChar       = "CHAR"
	mysqlVarchar    = "VARCHAR"
	mysqlBinary     = "BINARY"
	mysqlVarbinary  = "VARBINARY"
	mysqlTinyblob   = "TINYBLOB"
	mysqlBlob       = "BLOB"
	mysqlMediumblob = "MEDIUMBLOB"
	mysqlLongblob   = "LONGBLOB"
	mysqlTinytext   = "TINYTEXT"
	mysqlText       = "TEXT"
	mysqlMediumtext = "MEDIUMTEXT"
	mysqlLongtext   = "LONGTEXT"
	mysqlEnum       = "ENUM"
	mysqlSet        = "SET"
	mysqlJson       = "JSON"

	mysqlDate      = "DATE"
	mysqlTime      = "TIME"
	mysqlDatetime  = "DATETIME"
	mysqlTimestamp = "TIMESTAMP"
	mysqlYear      = "YEAR"
)

var errNotSupported = errors.New("not supported")

// mysqlErrQueryInterrupted 因 KILL QUERY 等导致语句被中断（见 MySQL ER_QUERY_INTERRUPTED）。
const mysqlErrQueryInterrupted uint16 = 1317

type mysqlRowsWithAffected interface {
	driver.Rows
	RowsAffected() int64
}

type mysqlConn struct {
	conn       driver.Conn
	dsn        string
	connID     int64
	killIssued atomic.Bool
}

func (c *mysqlConn) Close() error {
	return c.conn.Close()
}

func mysqlDataType(typeName string) int32 {
	switch typeName {
	case mysqlTinyint, mysqlSmallint, mysqlMediumint, mysqlInt, mysqlInteger,
		mysqlBigint, mysqlFloat, mysqlDouble, mysqlDoublePrec, mysqlReal,
		mysqlDecimal, mysqlDec, mysqlNumeric, mysqlFixed, mysqlBit:
		return dataTypeNumber

	case mysqlChar, mysqlVarchar, mysqlEnum, mysqlSet,
		mysqlTinytext, mysqlText, mysqlMediumtext, mysqlLongtext:
		return dataTypeChar

	case mysqlDate, mysqlTime, mysqlDatetime, mysqlTimestamp, mysqlYear:
		return dataTypeTime

	case mysqlBinary, mysqlVarbinary,
		mysqlTinyblob, mysqlBlob, mysqlMediumblob, mysqlLongblob:
		return dataTypeBlob

	case mysqlJson:
		return dataTypeJson

	default:
		return dataTypeChar
	}
}

func (c *mysqlConn) mysqlKillInterrupted(err error) bool {
	if !c.killIssued.Load() {
		return false
	}
	var me *mysql.MySQLError
	return errors.As(err, &me) && me.Number == mysqlErrQueryInterrupted
}

func (c *mysqlConn) KillQuery() error {
	if c.connID == 0 {
		return nil
	}
	c.killIssued.Store(true)
	connector, err := mysql.MySQLDriver{}.OpenConnector(c.dsn)
	if err != nil {
		return err
	}
	conn2, err := connector.Connect(context.Background())
	if err != nil {
		return err
	}
	defer conn2.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	execer, ok := conn2.(driver.ExecerContext)
	if !ok {
		return fmt.Errorf("mysql: ExecerContext not available")
	}
	_, err = execer.ExecContext(ctx, fmt.Sprintf("KILL QUERY %d", c.connID), nil)
	return err
}

func (c *mysqlConn) loadConnID() error {
	queryer, ok := c.conn.(driver.QueryerContext)
	if !ok {
		return fmt.Errorf("mysql: QueryerContext not available")
	}
	rows, err := queryer.QueryContext(context.Background(), "SELECT CONNECTION_ID()", nil)
	if err != nil {
		return err
	}
	defer rows.Close()
	dest := make([]driver.Value, 1)
	if err := rows.Next(dest); err != nil {
		return err
	}
	switch v := dest[0].(type) {
	case int64:
		c.connID = v
	case uint64:
		c.connID = int64(v)
	case int32:
		c.connID = int64(v)
	case []byte:
		_, err = fmt.Sscanf(string(v), "%d", &c.connID)
		return err
	default:
		_, err = fmt.Sscanf(fmt.Sprint(v), "%d", &c.connID)
		return err
	}
	return nil
}

func (c *mysqlConn) OpenQuery(sqlText string) (rowCursor, error) {
	c.killIssued.Store(false)
	queryer, ok := c.conn.(driver.QueryerContext)
	if !ok {
		return nil, errNotSupported
	}

	rows, err := queryer.QueryContext(context.Background(), sqlText, nil)
	if err != nil {
		if c.mysqlKillInterrupted(err) {
			return nil, newStreamQueryCancelled(err)
		}
		return nil, err
	}

	var affectedRows int64
	if rowsWithAffected, ok := rows.(mysqlRowsWithAffected); ok {
		affectedRows = rowsWithAffected.RowsAffected()
	}

	colNames := rows.Columns()
	columns := make([]dbQueryColumn, 0, len(colNames))
	for i, name := range colNames {
		dbType := ""
		if ct, ok := rows.(driver.RowsColumnTypeDatabaseTypeName); ok {
			dbType = ct.ColumnTypeDatabaseTypeName(i)
		}
		columns = append(columns, dbQueryColumn{
			name:     name,
			dataType: mysqlDataType(dbType),
		})
	}

	return &mysqlCur{
		conn:         c,
		rows:         rows,
		columns:      columns,
		affectedRows: affectedRows,
	}, nil
}

type mysqlCur struct {
	conn         *mysqlConn
	rows         driver.Rows
	columns      []dbQueryColumn
	affectedRows int64
}

func (q *mysqlCur) Close() error {
	return q.rows.Close()
}

func (q *mysqlCur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: q.affectedRows,
	}
}

func (q *mysqlCur) NextRow() (*dbQueryRow, bool, error) {
	dest := make([]driver.Value, len(q.columns))
	if err := q.rows.Next(dest); err != nil {
		if errors.Is(err, io.EOF) {
			return nil, false, nil
		}
		if q.conn != nil && q.conn.mysqlKillInterrupted(err) {
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

func openMysqlConn(dsn string) (driverConn, error) {
	connector, err := mysql.MySQLDriver{}.OpenConnector(dsn)
	if err != nil {
		return nil, err
	}

	conn, err := connector.Connect(context.Background())
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second) // todo: 时间可配
	defer cancel()

	if pinger, ok := conn.(driver.Pinger); ok {
		if err := pinger.Ping(ctx); err != nil {
			_ = conn.Close()
			return nil, err
		}
	}

	mc := &mysqlConn{conn: conn, dsn: dsn}
	if err := mc.loadConnID(); err != nil {
		_ = conn.Close()
		return nil, err
	}
	return mc, nil
}
