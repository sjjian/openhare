package db2

import (
	"context"
	"database/sql/driver"
)

// Tx represents an in-progress transaction on an IBM Db2 database.
type Tx struct {
	conn   *Conn
	ctx    context.Context
	closed bool
}

// Commit commits the transaction.
func (tx *Tx) Commit() error {
	if tx.conn == nil || tx.conn.session == nil {
		return ErrConnectionClosed
	}

	tx.conn.mu.Lock()
	defer tx.conn.mu.Unlock()

	if tx.closed {
		return ErrConnectionClosed
	}
	tx.closed = true

	defer tx.conn.session.SetAutoCommit(true)
	return tx.conn.session.Commit(tx.ctx)
}

// Rollback aborts the transaction.
func (tx *Tx) Rollback() error {
	if tx.conn == nil || tx.conn.session == nil {
		return ErrConnectionClosed
	}

	tx.conn.mu.Lock()
	defer tx.conn.mu.Unlock()

	if tx.closed {
		return ErrConnectionClosed
	}
	tx.closed = true

	defer tx.conn.session.SetAutoCommit(true)
	return tx.conn.session.Rollback(tx.ctx)
}

var _ driver.Tx = (*Tx)(nil)
