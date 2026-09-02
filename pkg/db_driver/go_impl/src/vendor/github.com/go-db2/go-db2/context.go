package db2

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"errors"
)

type contextKey string

const (
	userContextKey       contextKey = "db2_session_user"
	clientInfoContextKey contextKey = "db2_client_info"
)

// ClientInfo holds metadata about the client application, workstation, user, accounting, and correlation token.
type ClientInfo struct {
	ApplicationName  string
	WorkstationName  string
	UserID           string
	Accounting       string
	CorrelationToken string
}

// IsEmpty returns true if all client info fields are empty.
func (ci ClientInfo) IsEmpty() bool {
	return ci.ApplicationName == "" && ci.WorkstationName == "" && ci.UserID == "" && ci.Accounting == "" && ci.CorrelationToken == ""
}

// WithUser returns a copy of parent context with the target session user identity attached.
func WithUser(ctx context.Context, username string) context.Context {
	return context.WithValue(ctx, userContextKey, username)
}

// UserFromContext extracts the target session user identity from ctx, or returns empty string if not set.
func UserFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	if val, ok := ctx.Value(userContextKey).(string); ok {
		return val
	}
	return ""
}

// WithClientInfo returns a copy of parent context with ClientInfo attached.
func WithClientInfo(ctx context.Context, info ClientInfo) context.Context {
	return context.WithValue(ctx, clientInfoContextKey, info)
}

// ClientInfoFromContext extracts ClientInfo from ctx, or returns empty ClientInfo if not set.
func ClientInfoFromContext(ctx context.Context) ClientInfo {
	if ctx == nil {
		return ClientInfo{}
	}
	if val, ok := ctx.Value(clientInfoContextKey).(ClientInfo); ok {
		return val
	}
	return ClientInfo{}
}

// SetClientInfo updates client info registers on a *Conn, *sql.Conn, or driver.Conn.
func SetClientInfo(ctx context.Context, target any, info ClientInfo) error {
	if target == nil {
		return errors.New("db2: target connection cannot be nil")
	}

	switch c := target.(type) {
	case *Conn:
		return c.SetClientInfo(ctx, info)
	case driver.Conn:
		if setter, ok := c.(interface {
			SetClientInfo(ctx context.Context, info ClientInfo) error
		}); ok {
			return setter.SetClientInfo(ctx, info)
		}
	case *sql.Conn:
		return c.Raw(func(driverConn any) error {
			if setter, ok := driverConn.(interface {
				SetClientInfo(ctx context.Context, info ClientInfo) error
			}); ok {
				return setter.SetClientInfo(ctx, info)
			}
			return errors.New("db2: underlying driver connection does not support SetClientInfo")
		})
	case *sql.DB:
		return errors.New("db2: SetClientInfo must be called on a dedicated *sql.Conn or *db2.Conn, not on the entire pool *sql.DB")
	}

	return errors.New("db2: unsupported connection type for SetClientInfo")
}

// SwitchUser transitions the active user identity on a *Conn, *sql.Conn, or driver.Conn.
func SwitchUser(ctx context.Context, target any, newUser string, password ...string) error {
	if target == nil {
		return errors.New("db2: target connection cannot be nil")
	}

	switch c := target.(type) {
	case *Conn:
		return c.SwitchUser(ctx, newUser, password...)
	case driver.Conn:
		if switcher, ok := c.(interface {
			SwitchUser(ctx context.Context, newUser string, password ...string) error
		}); ok {
			return switcher.SwitchUser(ctx, newUser, password...)
		}
	case *sql.Conn:
		return c.Raw(func(driverConn any) error {
			if switcher, ok := driverConn.(interface {
				SwitchUser(ctx context.Context, newUser string, password ...string) error
			}); ok {
				return switcher.SwitchUser(ctx, newUser, password...)
			}
			return errors.New("db2: underlying driver connection does not support SwitchUser")
		})
	case *sql.DB:
		return errors.New("db2: SwitchUser must be called on a dedicated *sql.Conn or *db2.Conn, not on the entire pool *sql.DB")
	}

	return errors.New("db2: unsupported connection type for SwitchUser")
}
