package main

import (
	"context"
	"errors"
	"fmt"
	"sync/atomic"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

const (
	pgInt2        = "int2"
	pgInt4        = "int4"
	pgInt8        = "int8"
	pgFloat4      = "float4"
	pgFloat8      = "float8"
	pgNumeric     = "numeric"
	pgSmallint    = "smallint"
	pgInteger     = "integer"
	pgBigint      = "bigint"
	pgReal        = "real"
	pgDouble      = "double precision"
	pgSerial      = "serial"
	pgBigserial   = "bigserial"
	pgSmallserial = "smallserial"

	pgChar         = "character"
	pgVarchar      = "character varying"
	pgText         = "text"
	pgName         = "name"
	pgBpchar       = "bpchar"
	pgVarcharAlias = "varchar"
	pgCharAlias    = "char"

	pgDate        = "date"
	pgTime        = "time"
	pgTimeTz      = "time with time zone"
	pgTimestamp   = "timestamp"
	pgTimestampTz = "timestamp with time zone"
	pgTimestamptz = "timestamptz"
	pgInterval    = "interval"

	pgBytea = "bytea"

	pgBool    = "boolean"
	pgBoolean = "bool"

	pgJson  = "json"
	pgJsonb = "jsonb"

	pgUuid = "uuid"

	pgArray = "ARRAY"
)

type pgConn struct {
	conn          *pgx.Conn
	dsn           string
	backendPID    int32
	isQueryKilled atomic.Bool
}

func (c *pgConn) Close() error {
	return c.conn.Close(context.Background())
}

func (c *pgConn) pgKillInterrupted(err error) bool {
	if !c.isQueryKilled.Load() {
		return false
	}
	var pe *pgconn.PgError
	// pgErrCodeQueryCanceled 是 PostgreSQL 查询被服务端 cancel 时返回的 SQLSTATE
	// （对应 ErrorResponse: "canceling statement due to user request"）。
	// 参考：https://www.postgresql.org/docs/current/errcodes-appendix.html
	return errors.As(err, &pe) && pe.Code == "57014"
}

func pgDataType(typeName string) int32 {
	switch typeName {
	case pgInt2, pgInt4, pgInt8, pgFloat4, pgFloat8, pgNumeric,
		pgSmallint, pgInteger, pgBigint, pgReal, pgDouble,
		pgSerial, pgBigserial, pgSmallserial:
		return dataTypeNumber

	case pgChar, pgVarchar, pgText, pgName, pgBpchar,
		pgVarcharAlias, pgCharAlias, pgUuid:
		return dataTypeChar

	case pgDate, pgTime, pgTimeTz, pgTimestamp, pgTimestampTz,
		pgTimestamptz, pgInterval:
		return dataTypeTime

	case pgBytea:
		return dataTypeBlob

	case pgBool, pgBoolean:
		return dataTypeDataSet

	case pgJson, pgJsonb:
		return dataTypeJson

	default:
		if len(typeName) > 0 && typeName[len(typeName)-1] == ']' {
			return dataTypeBlob
		}
		return dataTypeChar
	}
}

func (c *pgConn) KillQuery() error {
	if c.backendPID == 0 {
		return nil
	}
	c.isQueryKilled.Store(true)
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	conn2, err := pgx.Connect(ctx, c.dsn)
	if err != nil {
		return err
	}
	defer conn2.Close(context.Background())
	var ok bool
	if err := conn2.QueryRow(ctx, "SELECT pg_cancel_backend($1)", c.backendPID).Scan(&ok); err != nil {
		return err
	}
	if !ok {
		return fmt.Errorf("pg_cancel_backend returned false for pid %d", c.backendPID)
	}
	return nil
}

func (c *pgConn) OpenQuery(sqlText string) (rowCursor, error) {
	c.isQueryKilled.Store(false)
	rows, err := c.conn.Query(context.Background(), sqlText)
	if err != nil {
		if c.pgKillInterrupted(err) {
			return nil, newStreamQueryCancelled(err)
		}
		return nil, err
	}

	fields := rows.FieldDescriptions()
	columns := make([]dbQueryColumn, 0, len(fields))
	for _, f := range fields {
		typeName := c.getTypeName(f.DataTypeOID)
		columns = append(columns, dbQueryColumn{
			name:     string(f.Name),
			dataType: pgDataType(typeName),
		})
	}

	// pgx：CommandTag 仅在 Rows 关闭后才有值；流式协议在首包就发 HEADER（impl.runStream）。
	// 无列结果集（典型 INSERT/UPDATE/DELETE 无 RETURNING）无行可读，先读完以关闭 Rows，才能在 Header 里带上 affected rows。
	var affectedRows int64
	if len(fields) == 0 {
		for rows.Next() {
		}
		if err := rows.Err(); err != nil {
			rows.Close()
			if c.pgKillInterrupted(err) {
				return nil, newStreamQueryCancelled(err)
			}
			return nil, err
		}
		affectedRows = rows.CommandTag().RowsAffected()
	}

	return &pgCur{
		conn:         c,
		rows:         rows,
		columns:      columns,
		affectedRows: affectedRows,
	}, nil
}

func (c *pgConn) getTypeName(oid uint32) string {
	if dt, ok := c.conn.TypeMap().TypeForOID(oid); ok {
		return dt.Name
	}
	return ""
}

type pgCur struct {
	conn         *pgConn
	rows         pgx.Rows
	columns      []dbQueryColumn
	affectedRows int64
}

func (q *pgCur) Close() error {
	q.rows.Close()
	return nil
}

func (q *pgCur) Header() *dbQueryHeader {
	return &dbQueryHeader{
		columns:      q.columns,
		affectedRows: q.affectedRows,
	}
}

func (q *pgCur) NextRow() (*dbQueryRow, bool, error) {
	if !q.rows.Next() {
		if err := q.rows.Err(); err != nil {
			if q.conn != nil && q.conn.pgKillInterrupted(err) {
				return nil, false, newStreamQueryCancelled(err)
			}
			return nil, false, err
		}
		return nil, false, nil
	}

	n := len(q.columns)
	raw := make([]any, n)
	for i := range raw {
		raw[i] = new(any)
	}

	if err := q.rows.Scan(raw...); err != nil {
		if q.conn != nil && q.conn.pgKillInterrupted(err) {
			return nil, false, newStreamQueryCancelled(err)
		}
		return nil, false, err
	}

	values := make([]dbQueryValue, 0, n)
	for _, v := range raw {
		ptr := v.(*any)
		values = append(values, buildQueryValue(*ptr))
	}
	return &dbQueryRow{values: values}, true, nil
}

func openPgConn(dsn string) (driverConn, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	conn, err := pgx.Connect(ctx, dsn)
	if err != nil {
		return nil, err
	}

	if err := conn.Ping(ctx); err != nil {
		_ = conn.Close(context.Background())
		return nil, err
	}

	pc := &pgConn{conn: conn, dsn: dsn}
	var pid int32
	if err := conn.QueryRow(ctx, "SELECT pg_backend_pid()").Scan(&pid); err != nil {
		_ = conn.Close(context.Background())
		return nil, err
	}
	pc.backendPID = pid
	return pc, nil
}
