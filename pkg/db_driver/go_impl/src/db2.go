package main

import (
	"context"
	"database/sql"
	"errors"
	"strings"
	"sync"
	"time"

	_ "github.com/go-db2/go-db2"
)

// Db2 data type mapping constants
const (
	db2Smallint = "SMALLINT"
	db2Integer  = "INTEGER"
	db2Int      = "INT"
	db2Bigint   = "BIGINT"
	db2Decimal  = "DECIMAL"
	db2Dec      = "DEC"
	db2Numeric  = "NUMERIC"
	db2Real     = "REAL"
	db2Double   = "DOUBLE"
	db2Float    = "FLOAT"
	db2DecFloat = "DECFLOAT"

	db2Char       = "CHAR"
	db2Varchar    = "VARCHAR"
	db2LongVar    = "LONG VARCHAR"
	db2Clob       = "CLOB"
	db2Dbclob     = "DBCLOB"
	db2Graphic    = "GRAPHIC"
	db2Vargraphic = "VARGRAPHIC"

	db2Date        = "DATE"
	db2Time        = "TIME"
	db2Timestamp   = "TIMESTAMP"
	db2TimestampTz = "TIMESTAMPTZ"

	db2Blob       = "BLOB"
	db2Binary     = "BINARY"
	db2Varbinary  = "VARBINARY"
	db2LongVarbin = "LONG VARBINARY"

	db2Xml  = "XML"
	db2Json = "JSON"
)

func db2DataType(typeName string) int32 {
	t := strings.ToUpper(strings.TrimSpace(typeName))
	switch t {
	case db2Smallint, db2Integer, db2Int, db2Bigint,
		db2Decimal, db2Dec, db2Numeric, db2Real, db2Double, db2Float, db2DecFloat:
		return dataTypeNumber

	case db2Char, db2Varchar, db2LongVar, db2Clob, db2Dbclob, db2Graphic, db2Vargraphic:
		return dataTypeChar

	case db2Date, db2Time, db2Timestamp, db2TimestampTz:
		return dataTypeTime

	case db2Blob, db2Binary, db2Varbinary, db2LongVarbin:
		return dataTypeBlob

	case db2Xml, db2Json:
		return dataTypeJson

	default:
		return dataTypeChar
	}
}

type db2Conn struct {
	db           *sql.DB
	streamMu     sync.Mutex
	streamCancel context.CancelFunc
}

func (c *db2Conn) Close() error {
	return c.db.Close()
}

func (c *db2Conn) KillQuery() error {
	c.streamMu.Lock()
	fn := c.streamCancel
	c.streamMu.Unlock()
	if fn != nil {
		fn()
	}
	return nil
}

func (c *db2Conn) OpenQuery(sqlText string) (rowCursor, error) {
	ctx, cancel := context.WithCancel(context.Background())

	c.streamMu.Lock()
	c.streamCancel = cancel
	c.streamMu.Unlock()

	rows, err := c.db.QueryContext(ctx, sqlText)
	if err != nil {
		c.streamMu.Lock()
		c.streamCancel = nil
		c.streamMu.Unlock()
		cancel()
		if errors.Is(err, context.Canceled) {
			return nil, newStreamQueryCancelled(err)
		}
		return nil, err
	}

	names, err := rows.Columns()
	if err != nil {
		_ = rows.Close()
		c.streamMu.Lock()
		c.streamCancel = nil
		c.streamMu.Unlock()
		cancel()
		return nil, err
	}

	colTypes, _ := rows.ColumnTypes()
	columns := make([]dbQueryColumn, 0, len(names))
	for i, name := range names {
		typeName := ""
		if i < len(colTypes) && colTypes[i] != nil {
			typeName = colTypes[i].DatabaseTypeName()
		}
		columns = append(columns, dbQueryColumn{
			name:     name,
			dataType: db2DataType(typeName),
		})
	}

	return &db2Cur{
		parent:  c,
		cancel:  cancel,
		rows:    rows,
		columns: columns,
	}, nil
}

type db2Cur struct {
	parent       *db2Conn
	cancel       context.CancelFunc
	rows         *sql.Rows
	columns      []dbQueryColumn
	affectedRows int64
}

func (q *db2Cur) Close() error {
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

func (q *db2Cur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: q.affectedRows,
	}
}

func (q *db2Cur) NextRow() (*dbQueryRow, bool, error) {
	if !q.rows.Next() {
		if err := q.rows.Err(); err != nil {
			if errors.Is(err, context.Canceled) {
				return nil, false, newStreamQueryCancelled(err)
			}
			return nil, false, err
		}
		return nil, false, nil
	}

	dest := make([]any, len(q.columns))
	destPtrs := make([]any, len(q.columns))
	for i := range dest {
		destPtrs[i] = &dest[i]
	}

	if err := q.rows.Scan(destPtrs...); err != nil {
		if errors.Is(err, context.Canceled) {
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

func openDb2Conn(dsn string) (driverConn, error) {
	db, err := sql.Open("db2", dsn)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		_ = db.Close()
		return nil, err
	}
	return &db2Conn{db: db}, nil
}
