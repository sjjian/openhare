package db2

import (
	"errors"
	"fmt"
)

// Common Driver Errors
var (
	ErrConnectionClosed     = errors.New("db2: connection is closed")
	ErrDatabaseNotFound     = errors.New("db2: relational database not found (RDBNFNRM)")
	ErrAuthenticationFailed = errors.New("db2: authentication failed (SECCHKRM)")
	ErrInvalidConnectionStr = errors.New("db2: invalid connection string")
)

// Db2Error represents a structured error returned by the IBM Db2 database engine.
type Db2Error struct {
	SQLCode  int32
	SQLState string
	Message  string
}

// Error formats the Db2 error adhering to IBM SQL standard (SQLCODE, SQLSTATE, Message).
func (e *Db2Error) Error() string {
	if e.Message != "" {
		return fmt.Sprintf("db2: SQLCODE=%d SQLSTATE=%s %s", e.SQLCode, e.SQLState, e.Message)
	}
	return fmt.Sprintf("db2: SQLCODE=%d SQLSTATE=%s", e.SQLCode, e.SQLState)
}
