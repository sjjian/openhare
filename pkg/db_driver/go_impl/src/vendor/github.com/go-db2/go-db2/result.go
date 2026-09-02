package db2

import (
	"context"
	"database/sql/driver"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"sync"
)

// Result implements the database/sql/driver.Result interface.
type Result struct {
	mu           sync.Mutex
	conn         *Conn
	affectedRows int64
	lastInsertId int64
	isInsert     bool
}

// NewResult creates a new driver.Result with affected rows count and preset lastInsertId.
func NewResult(affectedRows, lastInsertId int64) *Result {
	return &Result{
		affectedRows: affectedRows,
		lastInsertId: lastInsertId,
	}
}

// NewResultWithConn creates a new driver.Result attached to a connection for on-demand identity retrieval.
func NewResultWithConn(conn *Conn, affectedRows int64, isInsert bool) *Result {
	return &Result{
		conn:         conn,
		affectedRows: affectedRows,
		isInsert:     isInsert,
	}
}

// LastInsertId returns the database's auto-generated ID for the inserted row via IDENTITY_VAL_LOCAL().
func (r *Result) LastInsertId() (int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	if r.lastInsertId != 0 {
		return r.lastInsertId, nil
	}

	if !r.isInsert || r.conn == nil || r.conn.session == nil {
		return 0, errors.New("db2: LastInsertId is only available after an INSERT statement")
	}

	r.conn.mu.Lock()
	defer r.conn.mu.Unlock()

	// Query IDENTITY_VAL_LOCAL() from SYSIBM.SYSDUMMY1
	_, rawRows, err := r.conn.session.QueryDirect(context.Background(), "SELECT IDENTITY_VAL_LOCAL() AS LAST_ID FROM SYSIBM.SYSDUMMY1")
	if err != nil {
		return 0, fmt.Errorf("db2: failed to query IDENTITY_VAL_LOCAL(): %w", err)
	}

	if len(rawRows) == 0 || len(rawRows[0]) == 0 || rawRows[0][0] == nil {
		return 0, errors.New("db2: no identity value returned")
	}

	val := rawRows[0][0]
	id, err := parseIdentityValue(val)
	if err != nil {
		return 0, fmt.Errorf("db2: invalid identity value %v: %w", val, err)
	}

	r.lastInsertId = id
	return id, nil
}

// RowsAffected returns the number of rows affected by the query.
func (r *Result) RowsAffected() (int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.affectedRows, nil
}

func isInsertQuery(sql string) bool {
	trimmed := strings.ToUpper(stripLeadingCommentsAndSpaces(sql))
	return strings.HasPrefix(trimmed, "INSERT")
}

func parseIdentityValue(val any) (int64, error) {
	switch v := val.(type) {
	case int64:
		return v, nil
	case int:
		return int64(v), nil
	case int32:
		return int64(v), nil
	case int16:
		return int64(v), nil
	case int8:
		return int64(v), nil
	case uint64:
		return int64(v), nil
	case uint32:
		return int64(v), nil
	case uint:
		return int64(v), nil
	case float64:
		return int64(v), nil
	case float32:
		return int64(v), nil
	case string:
		str := strings.TrimSpace(v)
		if idx := strings.Index(str, "."); idx != -1 {
			str = str[:idx]
		}
		if str == "" {
			return 0, nil
		}
		return strconv.ParseInt(str, 10, 64)
	case []byte:
		str := strings.TrimSpace(string(v))
		if idx := strings.Index(str, "."); idx != -1 {
			str = str[:idx]
		}
		if str == "" {
			return 0, nil
		}
		return strconv.ParseInt(str, 10, 64)
	default:
		str := fmt.Sprint(val)
		if idx := strings.Index(str, "."); idx != -1 {
			str = str[:idx]
		}
		return strconv.ParseInt(str, 10, 64)
	}
}

var _ driver.Result = (*Result)(nil)
