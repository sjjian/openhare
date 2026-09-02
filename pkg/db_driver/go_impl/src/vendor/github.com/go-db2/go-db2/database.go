package db2

import (
	"context"
	"database/sql"
	"fmt"
	"regexp"
	"strings"
	"time"
)

const defaultAdminTimeout = 60 * time.Second

// validSQLIdentRegex enforces strict alphanumeric and Db2 identifier rules.
var validSQLIdentRegex = regexp.MustCompile(`^[a-zA-Z0-9_#$]{1,128}$`)

func validateSQLIdentifier(val, fieldName string) error {
	trimmed := strings.TrimSpace(val)
	if trimmed == "" {
		return fmt.Errorf("db2: %s cannot be empty", fieldName)
	}
	if !validSQLIdentRegex.MatchString(trimmed) {
		return fmt.Errorf("db2: invalid %s identifier %q (must be alphanumeric or _, #, $)", fieldName, val)
	}
	return nil
}

// CreateDb creates a new database on the IBM Db2 server specified in connStr.
// Optional options can be provided in "key=value" format (e.g. "codeset=UTF-8", "territory=US", "mode=...").
func CreateDb(dbname string, connStr string, options ...string) (bool, error) {
	if err := validateSQLIdentifier(dbname, "database name"); err != nil {
		return false, err
	}
	if strings.TrimSpace(connStr) == "" {
		return false, fmt.Errorf("db2: connection string cannot be empty")
	}

	var codeset, territory, mode string
	for _, opt := range options {
		parts := strings.SplitN(opt, "=", 2)
		if len(parts) != 2 {
			return false, fmt.Errorf("db2: invalid option format %q (expected key=value)", opt)
		}
		key := strings.ToLower(strings.TrimSpace(parts[0]))
		val := strings.TrimSpace(parts[1])
		switch key {
		case "codeset":
			if err := validateSQLIdentifier(val, "codeset"); err != nil {
				return false, err
			}
			codeset = val
		case "territory":
			if err := validateSQLIdentifier(val, "territory"); err != nil {
				return false, err
			}
			territory = val
		case "mode":
			if err := validateSQLIdentifier(val, "mode"); err != nil {
				return false, err
			}
			mode = val
		default:
			return false, fmt.Errorf("db2: unsupported option %q", key)
		}
	}

	db, err := sql.Open("db2", connStr)
	if err != nil {
		return false, fmt.Errorf("db2: failed to open connection: %w", err)
	}
	defer db.Close()

	ctx, cancel := context.WithTimeout(context.Background(), defaultAdminTimeout)
	defer cancel()

	var sb strings.Builder
	sb.WriteString(fmt.Sprintf("CREATE DATABASE %s", dbname))
	if codeset != "" {
		sb.WriteString(fmt.Sprintf(" CODESET %s", codeset))
	}
	if territory != "" {
		sb.WriteString(fmt.Sprintf(" TERRITORY %s", territory))
	}
	if mode != "" {
		sb.WriteString(fmt.Sprintf(" %s", mode))
	}

	createSQL := sb.String()
	_, err = db.ExecContext(ctx, createSQL)
	if err != nil {
		// Also try via SYSPROC.ADMIN_CMD if direct DDL requires administrative routing
		if _, adminErr := ExecAdminCmd(ctx, db, createSQL); adminErr == nil {
			return true, nil
		}
		return false, fmt.Errorf("db2: failed to create database %q: %w", dbname, err)
	}

	return true, nil
}

// DropDb drops the specified database from the IBM Db2 server.
func DropDb(dbname string, connStr string) (bool, error) {
	if err := validateSQLIdentifier(dbname, "database name"); err != nil {
		return false, err
	}
	if strings.TrimSpace(connStr) == "" {
		return false, fmt.Errorf("db2: connection string cannot be empty")
	}

	db, err := sql.Open("db2", connStr)
	if err != nil {
		return false, fmt.Errorf("db2: failed to open connection: %w", err)
	}
	defer db.Close()

	ctx, cancel := context.WithTimeout(context.Background(), defaultAdminTimeout)
	defer cancel()

	dropSQL := fmt.Sprintf("DROP DATABASE %s", dbname)
	_, err = db.ExecContext(ctx, dropSQL)
	if err != nil {
		if _, adminErr := ExecAdminCmd(ctx, db, dropSQL); adminErr == nil {
			return true, nil
		}
		return false, fmt.Errorf("db2: failed to drop database %q: %w", dbname, err)
	}

	return true, nil
}

// ExecAdminCmd executes an administrative command via Db2's SYSPROC.ADMIN_CMD stored procedure.
// It uses parameterized procedure execution or safe escaping and returns sql.Result with execution status.
func ExecAdminCmd(ctx context.Context, db *sql.DB, command string) (sql.Result, error) {
	trimmed := strings.TrimSpace(command)
	if trimmed == "" {
		return nil, fmt.Errorf("db2: admin command cannot be empty")
	}
	// Try parameterized CALL SYSPROC.ADMIN_CMD(?) first
	if res, err := db.ExecContext(ctx, "CALL SYSPROC.ADMIN_CMD(?)", trimmed); err == nil {
		return res, nil
	}
	// Fallback with safe quote escaping
	stmt := fmt.Sprintf("CALL SYSPROC.ADMIN_CMD('%s')", strings.ReplaceAll(trimmed, "'", "''"))
	return db.ExecContext(ctx, stmt)
}
