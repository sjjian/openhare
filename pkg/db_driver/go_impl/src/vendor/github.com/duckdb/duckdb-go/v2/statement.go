package duckdb

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"errors"
	"fmt"
	"math/big"
	"reflect"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

type StmtType mapping.StatementType

const (
	STATEMENT_TYPE_INVALID      = StmtType(mapping.StatementTypeInvalid)
	STATEMENT_TYPE_SELECT       = StmtType(mapping.StatementTypeSelect)
	STATEMENT_TYPE_INSERT       = StmtType(mapping.StatementTypeInsert)
	STATEMENT_TYPE_UPDATE       = StmtType(mapping.StatementTypeUpdate)
	STATEMENT_TYPE_EXPLAIN      = StmtType(mapping.StatementTypeExplain)
	STATEMENT_TYPE_DELETE       = StmtType(mapping.StatementTypeDelete)
	STATEMENT_TYPE_PREPARE      = StmtType(mapping.StatementTypePrepare)
	STATEMENT_TYPE_CREATE       = StmtType(mapping.StatementTypeCreate)
	STATEMENT_TYPE_EXECUTE      = StmtType(mapping.StatementTypeExecute)
	STATEMENT_TYPE_ALTER        = StmtType(mapping.StatementTypeAlter)
	STATEMENT_TYPE_TRANSACTION  = StmtType(mapping.StatementTypeTransaction)
	STATEMENT_TYPE_COPY         = StmtType(mapping.StatementTypeCopy)
	STATEMENT_TYPE_ANALYZE      = StmtType(mapping.StatementTypeAnalyze)
	STATEMENT_TYPE_VARIABLE_SET = StmtType(mapping.StatementTypeVariableSet)
	STATEMENT_TYPE_CREATE_FUNC  = StmtType(mapping.StatementTypeCreateFunc)
	STATEMENT_TYPE_DROP         = StmtType(mapping.StatementTypeDrop)
	STATEMENT_TYPE_EXPORT       = StmtType(mapping.StatementTypeExport)
	STATEMENT_TYPE_PRAGMA       = StmtType(mapping.StatementTypePragma)
	STATEMENT_TYPE_VACUUM       = StmtType(mapping.StatementTypeVacuum)
	STATEMENT_TYPE_CALL         = StmtType(mapping.StatementTypeCall)
	STATEMENT_TYPE_SET          = StmtType(mapping.StatementTypeSet)
	STATEMENT_TYPE_LOAD         = StmtType(mapping.StatementTypeLoad)
	STATEMENT_TYPE_RELATION     = StmtType(mapping.StatementTypeRelation)
	STATEMENT_TYPE_EXTENSION    = StmtType(mapping.StatementTypeExtension)
	STATEMENT_TYPE_LOGICAL_PLAN = StmtType(mapping.StatementTypeLogicalPlan)
	STATEMENT_TYPE_ATTACH       = StmtType(mapping.StatementTypeAttach)
	STATEMENT_TYPE_DETACH       = StmtType(mapping.StatementTypeDetach)
	STATEMENT_TYPE_MULTI        = StmtType(mapping.StatementTypeMulti)
)

// Stmt implements the driver.Stmt interface.
type Stmt struct {
	conn             *Conn
	preparedStmt     *mapping.PreparedStatement
	closeOnRowsClose bool
	bound            bool
	closed           bool
	rows             bool
}

// checkState checks if the statement is closed or uninitialized.
func (s *Stmt) checkState() error {
	if s.closed {
		return errClosedStmt
	}
	if s.preparedStmt == nil {
		return errUninitializedStmt
	}
	return nil
}

// Close the statement.
// Implements the driver.Stmt interface.
func (s *Stmt) Close() error {
	if s.rows {
		panic("database/sql/driver: misuse of duckdb driver: Close with active Rows")
	}
	if s.closed {
		panic("database/sql/driver: misuse of duckdb driver: double Close of Stmt")
	}

	s.closed = true
	mapping.DestroyPrepare(s.preparedStmt)
	return nil
}

// NumInput returns the number of placeholder parameters.
// Implements the driver.Stmt interface.
func (s *Stmt) NumInput() int {
	if s.closed {
		panic("database/sql/driver: misuse of duckdb driver: NumInput after Close")
	}
	count := mapping.NParams(*s.preparedStmt)
	return int(count)
}

// ParamName returns the name of the parameter at the given index (1-based).
func (s *Stmt) ParamName(n int) (string, error) {
	if err := s.checkState(); err != nil {
		return "", err
	}

	count := mapping.NParams(*s.preparedStmt)
	if n == 0 || n > int(count) {
		return "", getError(errAPI, paramIndexError(n, uint64(count)))
	}

	name := mapping.ParameterName(*s.preparedStmt, mapping.IdxT(n))
	return name, nil
}

// ParamType returns the expected type of the parameter at the given index (1-based).
func (s *Stmt) ParamType(n int) (Type, error) {
	if err := s.checkState(); err != nil {
		return TYPE_INVALID, err
	}

	count := mapping.NParams(*s.preparedStmt)
	if n == 0 || n > int(count) {
		return TYPE_INVALID, getError(errAPI, paramIndexError(n, uint64(count)))
	}

	t := mapping.ParamType(*s.preparedStmt, mapping.IdxT(n))
	return t, nil
}

func (s *Stmt) paramLogicalType(n int) (mapping.LogicalType, error) {
	var lt mapping.LogicalType
	if err := s.checkState(); err != nil {
		return lt, err
	}

	count := mapping.NParams(*s.preparedStmt)
	if n == 0 || n > int(count) {
		return lt, getError(errAPI, paramIndexError(n, uint64(count)))
	}

	return mapping.ParamLogicalType(*s.preparedStmt, mapping.IdxT(n)), nil
}

// StatementType returns the type of the statement.
func (s *Stmt) StatementType() (StmtType, error) {
	if err := s.checkState(); err != nil {
		return STATEMENT_TYPE_INVALID, err
	}

	t := mapping.PreparedStatementType(*s.preparedStmt)
	return StmtType(t), nil
}

// Bind the parameters to the statement.
// WARNING: This is a low-level API and should be used with caution.
func (s *Stmt) Bind(args []driver.NamedValue) error {
	return s.BindWithCtx(context.Background(), args)
}

// BindWithCtx takes a context and binds the parameters to the statement.
// WARNING: This is a low-level API and should be used with caution.
func (s *Stmt) BindWithCtx(ctx context.Context, args []driver.NamedValue) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	if s.closed {
		return errors.Join(errCouldNotBind, errClosedStmt)
	}
	if s.preparedStmt == nil {
		return errors.Join(errCouldNotBind, errUninitializedStmt)
	}

	return s.bind(args)
}

func (s *Stmt) bindHugeint(val *big.Int, n int) (mapping.State, error) {
	hugeint, err := hugeIntFromNative(val)
	if err != nil {
		return mapping.StateError, err
	}
	state := mapping.BindHugeInt(*s.preparedStmt, mapping.IdxT(n+1), hugeint)
	return state, nil
}

func (s *Stmt) bindUhugeint(val *big.Int, n int) (mapping.State, error) {
	uhugeint, err := uhugeIntFromNative(val)
	if err != nil {
		return mapping.StateError, err
	}
	state := mapping.BindUHugeInt(*s.preparedStmt, mapping.IdxT(n+1), uhugeint)
	return state, nil
}

func (s *Stmt) bindBigNum(val *big.Int, n int) (mapping.State, error) {
	bignum := bigNumFromNative(val)
	defer mapping.DestroyBigNum(&bignum)
	v := mapping.CreateBigNum(bignum)
	defer mapping.DestroyValue(&v)
	state := mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), v)
	return state, nil
}

func (s *Stmt) bindTimestamp(val driver.NamedValue, t Type, n int) (mapping.State, error) {
	var state mapping.State
	switch t {
	case TYPE_TIMESTAMP:
		v, err := inferTimestamp(t, val.Value)
		if err != nil {
			return mapping.StateError, err
		}
		state = mapping.BindTimestamp(*s.preparedStmt, mapping.IdxT(n+1), v)
	case TYPE_TIMESTAMP_TZ:
		v, err := inferTimestamp(t, val.Value)
		if err != nil {
			return mapping.StateError, err
		}
		state = mapping.BindTimestampTZ(*s.preparedStmt, mapping.IdxT(n+1), v)
	case TYPE_TIMESTAMP_S:
		v, err := inferTimestampS(val.Value)
		if err != nil {
			return mapping.StateError, err
		}
		tS := mapping.CreateTimestampS(v)
		state = mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), tS)
		mapping.DestroyValue(&tS)
	case TYPE_TIMESTAMP_MS:
		v, err := inferTimestampMS(val.Value)
		if err != nil {
			return mapping.StateError, err
		}
		tMS := mapping.CreateTimestampMS(v)
		state = mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), tMS)
		mapping.DestroyValue(&tMS)
	case TYPE_TIMESTAMP_NS:
		v, err := inferTimestampNS(val.Value)
		if err != nil {
			return mapping.StateError, err
		}
		tMS := mapping.CreateTimestampNS(v)
		state = mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), tMS)
		mapping.DestroyValue(&tMS)
	}
	return state, nil
}

func (s *Stmt) bindDate(val driver.NamedValue, n int) (mapping.State, error) {
	date, err := inferDate(val.Value)
	if err != nil {
		return mapping.StateError, err
	}
	state := mapping.BindDate(*s.preparedStmt, mapping.IdxT(n+1), date)
	return state, nil
}

func (s *Stmt) bindTime(val driver.NamedValue, t Type, n int) (mapping.State, error) {
	ticks, err := getTimeTicks(val.Value)
	if err != nil {
		return mapping.StateError, err
	}

	if t == TYPE_TIME {
		ti := mapping.NewTime(ticks)
		state := mapping.BindTime(*s.preparedStmt, mapping.IdxT(n+1), ti)
		return state, nil
	}

	// TYPE_TIME_TZ: Preserve the UTC offset from the input time.
	goTime, _ := castToTime(val.Value)
	_, offset := goTime.Zone()
	ti := mapping.CreateTimeTZ(ticks, int32(offset))
	v := mapping.CreateTimeTZValue(ti)
	state := mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), v)
	mapping.DestroyValue(&v)
	return state, nil
}

func (s *Stmt) bindJSON(val driver.NamedValue, n int) (mapping.State, error) {
	switch v := val.Value.(type) {
	case []byte:
		return mapping.BindVarcharLength(*s.preparedStmt, mapping.IdxT(n+1), string(v), mapping.IdxT(len(v))), nil
	case string:
		return mapping.BindVarcharLength(*s.preparedStmt, mapping.IdxT(n+1), v, mapping.IdxT(len(v))), nil
	case nil:
		return mapping.BindNull(*s.preparedStmt, mapping.IdxT(n+1)), nil
	}
	return mapping.StateError, addIndexToError(unsupportedTypeError("JSON interface, need []byte, string or nil"), n+1)
}

func (s *Stmt) bindUUID(val driver.NamedValue, n int) (mapping.State, error) {
	// Check if the interface contains a nil pointer using reflection
	v := reflect.ValueOf(val.Value)
	if v.Kind() == reflect.Pointer && v.IsNil() {
		return mapping.BindNull(*s.preparedStmt, mapping.IdxT(n+1)), nil
	}

	if ss, ok := val.Value.(fmt.Stringer); ok {
		str := ss.String()
		return mapping.BindVarcharLength(*s.preparedStmt, mapping.IdxT(n+1), str, mapping.IdxT(len(str))), nil
	}
	return mapping.StateError, addIndexToError(unsupportedTypeError(unknownTypeErrMsg), n+1)
}

func (s *Stmt) bindBit(val *Bit, n int) (mapping.State, error) {
	if err := val.Validate(); err != nil {
		return mapping.StateError, err
	}
	bit := mapping.NewBit(val.Data)
	defer mapping.DestroyBit(&bit)
	v := mapping.CreateBit(bit)
	defer mapping.DestroyValue(&v)
	state := mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), v)
	return state, nil
}

// Used for binding Array, List, Struct, Map. In the future, Union.
func (s *Stmt) bindCompositeValue(val driver.NamedValue, n int) (mapping.State, error) {
	lt, err := s.paramLogicalType(n + 1)
	defer mapping.DestroyLogicalType(&lt)
	if err != nil {
		return mapping.StateError, err
	}

	mappedVal, err := createValue(lt, val.Value)
	defer mapping.DestroyValue(&mappedVal)
	if err != nil {
		return mapping.StateError, addIndexToError(err, n+1)
	}

	state := mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), mappedVal)
	return state, nil
}

func (s *Stmt) tryBindComplexValue(val driver.NamedValue, n int) (mapping.State, error) {
	lt, mappedVal, err := inferLogicalTypeAndValue(val.Value)
	defer mapping.DestroyLogicalType(&lt)
	defer mapping.DestroyValue(&mappedVal)
	if err != nil {
		return mapping.StateError, addIndexToError(err, n+1)
	}
	state := mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), mappedVal)
	return state, nil
}

func (s *Stmt) bindComplexValue(val driver.NamedValue, n int, t Type, name string) (mapping.State, error) {
	// We could not resolve this parameter when binding the query.
	// Fall back to the Go type.
	if t == TYPE_INVALID {
		return s.tryBindComplexValue(val, n)
	}

	switch t {
	case TYPE_UUID:
		return s.bindUUID(val, n)
	case TYPE_TIMESTAMP, TYPE_TIMESTAMP_TZ, TYPE_TIMESTAMP_S, TYPE_TIMESTAMP_MS, TYPE_TIMESTAMP_NS:
		return s.bindTimestamp(val, t, n)
	case TYPE_DATE:
		return s.bindDate(val, n)
	case TYPE_TIME, TYPE_TIME_TZ:
		return s.bindTime(val, t, n)
	case TYPE_ARRAY, TYPE_LIST, TYPE_STRUCT, TYPE_MAP:
		return s.bindCompositeValue(val, n)
	case TYPE_ENUM, TYPE_UNION:
		// FIXME: for other types: duckdb_param_logical_type once available, then create duckdb_value + duckdb_bind_value
		// FIXME: for other types: use NamedValueChecker to support.
		return mapping.StateError, addIndexToError(unsupportedTypeError(name), n+1)
	}
	return mapping.StateError, addIndexToError(unsupportedTypeError(unknownTypeErrMsg), n+1)
}

func (s *Stmt) bindTypedValue(val TypedValue, n int) (mapping.State, error) {
	value := val.value
	// Unwrap driver.Valuer unless the caller already signalled NULL.
	// Calling Value() on a typed-nil receiver can panic.
	if val.typ != TYPE_SQLNULL && !isNil(value) {
		if valuer, ok := value.(driver.Valuer); ok {
			driverVal, err := valuer.Value()
			if err != nil {
				return mapping.StateError, addIndexToError(err, n+1)
			}
			value = driverVal
		}
	}

	coerced, err := coerceTypedValue(val.typ, value)
	if err != nil {
		return mapping.StateError, addIndexToError(err, n+1)
	}
	if coerced == nil {
		return mapping.BindNull(*s.preparedStmt, mapping.IdxT(n+1)), nil
	}

	mappedVal, err := createPrimitiveValue(val.typ, coerced)
	defer mapping.DestroyValue(&mappedVal)
	if err != nil {
		return mapping.StateError, addIndexToError(err, n+1)
	}

	return mapping.BindValue(*s.preparedStmt, mapping.IdxT(n+1), mappedVal), nil
}

//nolint:gocyclo
func (s *Stmt) bindValue(val driver.NamedValue, n int) (mapping.State, error) {
	switch explicit := val.Value.(type) {
	case TypedValue:
		return s.bindTypedValue(explicit, n)
	case *TypedValue:
		if explicit == nil {
			return mapping.BindNull(*s.preparedStmt, mapping.IdxT(n+1)), nil
		}
		return s.bindTypedValue(*explicit, n)
	}

	// For some queries, we cannot resolve the parameter type when preparing the query.
	// E.g., for "SELECT * FROM (VALUES (?, ?)) t(a, b)", we cannot know the parameter types from the SQL statement alone.
	// For these cases, ParamType returns TYPE_INVALID.
	t, err := s.ParamType(n + 1)
	if err != nil {
		return mapping.StateError, err
	}

	name, ok := unsupportedValueTypeToStringMap[t]
	if ok && t != TYPE_INVALID {
		// TODO: DuckDB can coerce primitive scalar binds into VARIANT columns
		// when callers use the low-level bind functions; duckdb-rs relies on
		// that behavior. Keep this blocked until tests prove this path can
		// delegate primitive binds without falling through to Go-side VARIANT
		// value creation, which has no C API helpers yet.
		return mapping.StateError, addIndexToError(unsupportedTypeError(name), n+1)
	}

	if t != TYPE_INVALID {
		lt, e := s.paramLogicalType(n + 1)
		defer mapping.DestroyLogicalType(&lt)
		if e != nil {
			return mapping.StateError, e
		}
		alias := mapping.LogicalTypeGetAlias(lt)
		if alias == aliasJSON {
			return s.bindJSON(val, n)
		}
	}

	// Check for driver.Valuer interface first (takes precedence over type switching)
	valueToBind := val.Value
	isDriverValue := false
	if valuer, ok := val.Value.(driver.Valuer); ok {
		driverVal, err := valuer.Value()
		if err != nil {
			return mapping.StateError, addIndexToError(err, n+1)
		}
		valueToBind = driverVal
		isDriverValue = true
	}

	switch v := valueToBind.(type) {
	case bool:
		return mapping.BindBoolean(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case int8:
		return mapping.BindInt8(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case int16:
		return mapping.BindInt16(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case int32:
		return mapping.BindInt32(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case int64:
		return mapping.BindInt64(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case int:
		// int is at least 32 bits.
		return mapping.BindInt64(*s.preparedStmt, mapping.IdxT(n+1), int64(v)), nil
	case *big.Int:
		if t == TYPE_HUGEINT {
			return s.bindHugeint(v, n)
		}
		if t == TYPE_UHUGEINT {
			return s.bindUhugeint(v, n)
		}
		return s.bindBigNum(v, n)
	case Decimal:
		// FIXME: use NamedValueChecker to support this type.
		name := typeToStringMap[TYPE_DECIMAL]
		return mapping.StateError, addIndexToError(unsupportedTypeError(name), n+1)
	case uint8:
		return mapping.BindUInt8(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case uint16:
		return mapping.BindUInt16(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case uint32:
		return mapping.BindUInt32(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case uint64:
		return mapping.BindUInt64(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case float32:
		return mapping.BindFloat(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case float64:
		return mapping.BindDouble(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case string:
		return mapping.BindVarcharLength(*s.preparedStmt, mapping.IdxT(n+1), v, mapping.IdxT(len(v))), nil
	case []byte:
		return mapping.BindBlob(*s.preparedStmt, mapping.IdxT(n+1), v), nil
	case Interval:
		i, inferErr := inferInterval(v)
		if inferErr != nil {
			return mapping.StateError, inferErr
		}
		return mapping.BindInterval(*s.preparedStmt, mapping.IdxT(n+1), i), nil
	case Bit:
		return s.bindBit(&v, n)
	case *Bit:
		if v == nil {
			return mapping.BindNull(*s.preparedStmt, mapping.IdxT(n+1)), nil
		}
		return s.bindBit(v, n)
	case nil:
		return mapping.BindNull(*s.preparedStmt, mapping.IdxT(n+1)), nil
	}

	// For other types after driver.Valuer conversion, fall back to reflection-based binding
	if isDriverValue {
		return s.tryBindComplexValue(driver.NamedValue{
			Name:    val.Name,
			Ordinal: val.Ordinal,
			Value:   valueToBind,
		}, n)
	}

	return s.bindComplexValue(val, n, t, name)
}

func (s *Stmt) bind(args []driver.NamedValue) error {
	if s.NumInput() > len(args) {
		return fmt.Errorf("incorrect argument count for command: have %d want %d", len(args), s.NumInput())
	}

	byOrdinal := make(map[int]driver.NamedValue, len(args))
	byName := make(map[string]driver.NamedValue, len(args))
	for _, v := range args {
		if v.Ordinal != 0 {
			byOrdinal[v.Ordinal] = v
		}
		if v.Name != "" {
			byName[v.Name] = v
		}
	}

	// relaxed length check allow for unused parameters.
	for i := range s.NumInput() {
		name := mapping.ParameterName(*s.preparedStmt, mapping.IdxT(i+1))

		// fallback on index position
		arg := args[i]

		// override with ordinal if set
		if v, ok := byOrdinal[i+1]; ok {
			arg = v
		}

		// override with name if set
		if v, ok := byName[name]; ok {
			arg = v
		}

		state, err := s.bindValue(arg, i)
		if state == mapping.StateError {
			errMsg := mapping.PrepareError(*s.preparedStmt)
			err = errors.Join(err, getDuckDBError(errMsg))
			return errors.Join(errCouldNotBind, err)
		}
	}

	s.bound = true
	return nil
}

// Deprecated: Use ExecContext instead.
func (s *Stmt) Exec(args []driver.Value) (driver.Result, error) {
	return s.ExecContext(context.Background(), argsToNamedArgs(args))
}

// ExecContext executes a query that doesn't return rows, such as an INSERT or UPDATE.
// It implements the driver.StmtExecContext interface.
func (s *Stmt) ExecContext(ctx context.Context, nargs []driver.NamedValue) (driver.Result, error) {
	cleanupCtx := s.conn.setContext(ctx)
	defer cleanupCtx()

	var res *mapping.Result
	if err := runWithCtxInterrupt(ctx, s.conn.conn, func(wctx context.Context) error {
		var executeErr error
		res, executeErr = s.execute(wctx, nargs)
		return executeErr
	}); err != nil {
		return nil, err
	}
	defer mapping.DestroyResult(res)

	ra := int64(mapping.RowsChanged(res))
	return &result{ra}, nil
}

// ColumnCount returns the number of columns that will be returned by executing the prepared statement.
// If any of the column types is invalid (which can happen when the type is ambiguous), the result will be 1.
// Returns an error if the statement is closed or uninitialized.
func (s *Stmt) ColumnCount() (int, error) {
	if err := s.checkState(); err != nil {
		return 0, err
	}

	count := mapping.PreparedStatementColumnCount(*s.preparedStmt)
	return int(count), nil
}

// ColumnType returns the type of the column at the given index (0-based).
// Returns TYPE_INVALID and a columnIndexError if the column is out of range.
// Returns an error if the statement is closed or uninitialized.
func (s *Stmt) ColumnType(n int) (Type, error) {
	if err := s.checkState(); err != nil {
		return TYPE_INVALID, err
	}

	count := mapping.PreparedStatementColumnCount(*s.preparedStmt)
	if n < 0 || n >= int(count) {
		return TYPE_INVALID, getError(errAPI, columnIndexError(n, uint64(count)))
	}

	t := mapping.PreparedStatementColumnType(*s.preparedStmt, mapping.IdxT(n))
	return t, nil
}

// ColumnTypeInfo returns the TypeInfo of the column at the given index (0-based).
// TypeInfo provides detailed type information including nested structures, DECIMAL precision,
// ENUM values, etc.
// Returns a TypeInfo with internalType TYPE_INVALID and a columnIndexError if the column is out of range.
// Returns an error if the statement is closed or uninitialized.
func (s *Stmt) ColumnTypeInfo(n int) (TypeInfo, error) {
	if err := s.checkState(); err != nil {
		return nil, err
	}

	count := mapping.PreparedStatementColumnCount(*s.preparedStmt)
	if n < 0 || n >= int(count) {
		return nil, getError(errAPI, columnIndexError(n, uint64(count)))
	}

	lt := mapping.PreparedStatementColumnLogicalType(*s.preparedStmt, mapping.IdxT(n))
	defer mapping.DestroyLogicalType(&lt)

	return newTypeInfoFromLogicalType(lt)
}

// ColumnName returns the name of the column at the given index (0-based).
// Returns "" and a columnIndexError if the column is out of range.
// Returns an error if the statement is closed or uninitialized.
func (s *Stmt) ColumnName(n int) (string, error) {
	if err := s.checkState(); err != nil {
		return "", err
	}

	count := mapping.PreparedStatementColumnCount(*s.preparedStmt)
	if n < 0 || n >= int(count) {
		return "", getError(errAPI, columnIndexError(n, uint64(count)))
	}

	name := mapping.PreparedStatementColumnName(*s.preparedStmt, mapping.IdxT(n))
	return name, nil
}

// ExecBound executes a bound query that doesn't return rows, such as an INSERT or UPDATE.
// It can only be used after Bind has been called.
// WARNING: This is a low-level API and should be used with caution.
func (s *Stmt) ExecBound(ctx context.Context) (driver.Result, error) {
	if s.closed {
		return nil, errClosedCon
	}
	if s.rows {
		return nil, errActiveRows
	}
	if !s.bound {
		return nil, errNotBound
	}

	cleanupCtx := s.conn.setContext(ctx)
	defer cleanupCtx()

	var res *mapping.Result
	if err := runWithCtxInterrupt(ctx, s.conn.conn, func(wctx context.Context) error {
		var executeBoundErr error
		res, executeBoundErr = s.executeBound(wctx)
		return executeBoundErr
	}); err != nil {
		return nil, err
	}
	defer mapping.DestroyResult(res)

	ra := int64(mapping.RowsChanged(res))
	return &result{ra}, nil
}

// Deprecated: Use QueryContext instead.
func (s *Stmt) Query(args []driver.Value) (driver.Rows, error) {
	return s.QueryContext(context.Background(), argsToNamedArgs(args))
}

// QueryContext executes a query that may return rows, such as a SELECT.
// It implements the driver.StmtQueryContext interface.
func (s *Stmt) QueryContext(ctx context.Context, nargs []driver.NamedValue) (driver.Rows, error) {
	cleanupCtx := s.conn.setContext(ctx)
	defer cleanupCtx()

	var res *mapping.Result
	if err := runWithCtxInterrupt(ctx, s.conn.conn, func(wctx context.Context) error {
		var executeErr error
		res, executeErr = s.execute(wctx, nargs)
		return executeErr
	}); err != nil {
		return nil, err
	}
	s.rows = true
	return newRowsWithStmt(*res, s), nil
}

// QueryBound executes a bound query that may return rows, such as a SELECT.
// It can only be used after Bind has been called.
// WARNING: This is a low-level API and should be used with caution.
func (s *Stmt) QueryBound(ctx context.Context) (driver.Rows, error) {
	if s.closed {
		return nil, errClosedCon
	}
	if s.rows {
		return nil, errActiveRows
	}
	if !s.bound {
		return nil, errNotBound
	}

	cleanupCtx := s.conn.setContext(ctx)
	defer cleanupCtx()

	var res *mapping.Result
	if err := runWithCtxInterrupt(ctx, s.conn.conn, func(wctx context.Context) error {
		var executeBoundErr error
		res, executeBoundErr = s.executeBound(wctx)
		return executeBoundErr
	}); err != nil {
		return nil, err
	}

	s.rows = true
	return newRowsWithStmt(*res, s), nil
}

// This method executes the query in steps and checks if context is cancelled before executing each step.
// It uses Pending Result Interface C APIs to achieve this. Reference - https://duckdb.org/docs/api/c/api#pending-result-interface
func (s *Stmt) execute(ctx context.Context, args []driver.NamedValue) (*mapping.Result, error) {
	if s.closed {
		panic("database/sql/driver: misuse of duckdb driver: ExecContext or QueryContext after Close")
	}
	if s.rows {
		panic("database/sql/driver: misuse of duckdb driver: ExecContext or QueryContext with active Rows")
	}

	if err := s.BindWithCtx(ctx, args); err != nil {
		return nil, err
	}
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	return s.executeBound(ctx)
}

// interruptRoutine sends at most one interrupt when ctx is canceled before
// mainDoneCh closes. Query execution uses runWithCtxInterrupt when it needs to
// reassert interrupts on a timer.
func interruptRoutine(mainDoneCh, bgDoneCh *chan struct{}, ctx context.Context, conn *Conn) {
	select {
	// Await an interrupt on the context.
	case <-ctx.Done():
		mapping.Interrupt(conn.conn)
		break
	// Await a done-signal on the main channel.
	// Reading from a closed channel succeeds immediately.
	case <-*mainDoneCh:
		break
	}
	close(*bgDoneCh)
}

func (s *Stmt) executeBound(ctx context.Context) (*mapping.Result, error) {
	var pendingRes mapping.PendingResult
	// Phase 1: create pending result
	if mapping.PendingPrepared(*s.preparedStmt, &pendingRes) == mapping.StateError {
		dbErr := getDuckDBError(mapping.PendingError(pendingRes))
		mapping.DestroyPending(&pendingRes)
		return nil, dbErr
	}
	defer mapping.DestroyPending(&pendingRes)

	// Short-circuit before execution
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	// Phase 2: execute pending
	var res mapping.Result
	state := mapping.ExecutePending(pendingRes, &res)
	if state == mapping.StateError {
		err := errors.Join(ctx.Err(), getDuckDBError(mapping.ResultError(&res)))
		mapping.DestroyResult(&res)
		return nil, err
	}

	return &res, nil
}

func argsToNamedArgs(values []driver.Value) []driver.NamedValue {
	args := make([]driver.NamedValue, len(values))
	for n, param := range values {
		if np, ok := param.(sql.NamedArg); ok {
			args[n].Name = np.Name
			param = np.Value
		}
		args[n].Value = param
		args[n].Ordinal = n + 1
	}
	return args
}
