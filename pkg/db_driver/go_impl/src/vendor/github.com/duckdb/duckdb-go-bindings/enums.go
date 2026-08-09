package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

// Type wraps duckdb_type.
type Type = C.duckdb_type

const (
	TypeInvalid        Type = C.DUCKDB_TYPE_INVALID
	TypeBoolean        Type = C.DUCKDB_TYPE_BOOLEAN
	TypeTinyInt        Type = C.DUCKDB_TYPE_TINYINT
	TypeSmallInt       Type = C.DUCKDB_TYPE_SMALLINT
	TypeInteger        Type = C.DUCKDB_TYPE_INTEGER
	TypeBigInt         Type = C.DUCKDB_TYPE_BIGINT
	TypeUTinyInt       Type = C.DUCKDB_TYPE_UTINYINT
	TypeUSmallInt      Type = C.DUCKDB_TYPE_USMALLINT
	TypeUInteger       Type = C.DUCKDB_TYPE_UINTEGER
	TypeUBigInt        Type = C.DUCKDB_TYPE_UBIGINT
	TypeFloat          Type = C.DUCKDB_TYPE_FLOAT
	TypeDouble         Type = C.DUCKDB_TYPE_DOUBLE
	TypeTimestamp      Type = C.DUCKDB_TYPE_TIMESTAMP
	TypeDate           Type = C.DUCKDB_TYPE_DATE
	TypeTime           Type = C.DUCKDB_TYPE_TIME
	TypeInterval       Type = C.DUCKDB_TYPE_INTERVAL
	TypeHugeInt        Type = C.DUCKDB_TYPE_HUGEINT
	TypeUHugeInt       Type = C.DUCKDB_TYPE_UHUGEINT
	TypeVarchar        Type = C.DUCKDB_TYPE_VARCHAR
	TypeBlob           Type = C.DUCKDB_TYPE_BLOB
	TypeDecimal        Type = C.DUCKDB_TYPE_DECIMAL
	TypeTimestampS     Type = C.DUCKDB_TYPE_TIMESTAMP_S
	TypeTimestampMS    Type = C.DUCKDB_TYPE_TIMESTAMP_MS
	TypeTimestampNS    Type = C.DUCKDB_TYPE_TIMESTAMP_NS
	TypeEnum           Type = C.DUCKDB_TYPE_ENUM
	TypeList           Type = C.DUCKDB_TYPE_LIST
	TypeStruct         Type = C.DUCKDB_TYPE_STRUCT
	TypeMap            Type = C.DUCKDB_TYPE_MAP
	TypeArray          Type = C.DUCKDB_TYPE_ARRAY
	TypeUUID           Type = C.DUCKDB_TYPE_UUID
	TypeUnion          Type = C.DUCKDB_TYPE_UNION
	TypeBit            Type = C.DUCKDB_TYPE_BIT
	TypeTimeTZ         Type = C.DUCKDB_TYPE_TIME_TZ
	TypeTimestampTZ    Type = C.DUCKDB_TYPE_TIMESTAMP_TZ
	TypeAny            Type = C.DUCKDB_TYPE_ANY
	TypeBigNum         Type = C.DUCKDB_TYPE_BIGNUM
	TypeSQLNull        Type = C.DUCKDB_TYPE_SQLNULL
	TypeStringLiteral  Type = C.DUCKDB_TYPE_STRING_LITERAL
	TypeIntegerLiteral Type = C.DUCKDB_TYPE_INTEGER_LITERAL
	TypeTimeNS         Type = C.DUCKDB_TYPE_TIME_NS
	TypeGeometry       Type = C.DUCKDB_TYPE_GEOMETRY
	TypeVariant        Type = C.DUCKDB_TYPE_VARIANT
)

// State wraps duckdb_state.
type State = C.duckdb_state

const (
	StateSuccess State = C.DuckDBSuccess
	StateError   State = C.DuckDBError
)

// PendingState wraps duckdb_pending_state.
type PendingState = C.duckdb_pending_state

const (
	PendingStateResultReady      PendingState = C.DUCKDB_PENDING_RESULT_READY
	PendingStateResultNotReady   PendingState = C.DUCKDB_PENDING_RESULT_NOT_READY
	PendingStateError            PendingState = C.DUCKDB_PENDING_ERROR
	PendingStateNoTasksAvailable PendingState = C.DUCKDB_PENDING_NO_TASKS_AVAILABLE
)

// ResultType wraps duckdb_result_type.
type ResultType = C.duckdb_result_type

const (
	ResultTypeInvalid     ResultType = C.DUCKDB_RESULT_TYPE_INVALID
	ResultTypeChangedRows ResultType = C.DUCKDB_RESULT_TYPE_CHANGED_ROWS
	ResultTypeNothing     ResultType = C.DUCKDB_RESULT_TYPE_NOTHING
	ResultTypeQueryResult ResultType = C.DUCKDB_RESULT_TYPE_QUERY_RESULT
)

// StatementType wraps duckdb_statement_type.
type StatementType = C.duckdb_statement_type

const (
	StatementTypeInvalid          StatementType = C.DUCKDB_STATEMENT_TYPE_INVALID
	StatementTypeSelect           StatementType = C.DUCKDB_STATEMENT_TYPE_SELECT
	StatementTypeInsert           StatementType = C.DUCKDB_STATEMENT_TYPE_INSERT
	StatementTypeUpdate           StatementType = C.DUCKDB_STATEMENT_TYPE_UPDATE
	StatementTypeExplain          StatementType = C.DUCKDB_STATEMENT_TYPE_EXPLAIN
	StatementTypeDelete           StatementType = C.DUCKDB_STATEMENT_TYPE_DELETE
	StatementTypePrepare          StatementType = C.DUCKDB_STATEMENT_TYPE_PREPARE
	StatementTypeCreate           StatementType = C.DUCKDB_STATEMENT_TYPE_CREATE
	StatementTypeExecute          StatementType = C.DUCKDB_STATEMENT_TYPE_EXECUTE
	StatementTypeAlter            StatementType = C.DUCKDB_STATEMENT_TYPE_ALTER
	StatementTypeTransaction      StatementType = C.DUCKDB_STATEMENT_TYPE_TRANSACTION
	StatementTypeCopy             StatementType = C.DUCKDB_STATEMENT_TYPE_COPY
	StatementTypeAnalyze          StatementType = C.DUCKDB_STATEMENT_TYPE_ANALYZE
	StatementTypeVariableSet      StatementType = C.DUCKDB_STATEMENT_TYPE_VARIABLE_SET
	StatementTypeCreateFunc       StatementType = C.DUCKDB_STATEMENT_TYPE_CREATE_FUNC
	StatementTypeDrop             StatementType = C.DUCKDB_STATEMENT_TYPE_DROP
	StatementTypeExport           StatementType = C.DUCKDB_STATEMENT_TYPE_EXPORT
	StatementTypePragma           StatementType = C.DUCKDB_STATEMENT_TYPE_PRAGMA
	StatementTypeVacuum           StatementType = C.DUCKDB_STATEMENT_TYPE_VACUUM
	StatementTypeCall             StatementType = C.DUCKDB_STATEMENT_TYPE_CALL
	StatementTypeSet              StatementType = C.DUCKDB_STATEMENT_TYPE_SET
	StatementTypeLoad             StatementType = C.DUCKDB_STATEMENT_TYPE_LOAD
	StatementTypeRelation         StatementType = C.DUCKDB_STATEMENT_TYPE_RELATION
	StatementTypeExtension        StatementType = C.DUCKDB_STATEMENT_TYPE_EXTENSION
	StatementTypeLogicalPlan      StatementType = C.DUCKDB_STATEMENT_TYPE_LOGICAL_PLAN
	StatementTypeAttach           StatementType = C.DUCKDB_STATEMENT_TYPE_ATTACH
	StatementTypeDetach           StatementType = C.DUCKDB_STATEMENT_TYPE_DETACH
	StatementTypeMulti            StatementType = C.DUCKDB_STATEMENT_TYPE_MULTI
	StatementTypeCopyDatabase     StatementType = C.DUCKDB_STATEMENT_TYPE_COPY_DATABASE
	StatementTypeUpdateExtensions StatementType = C.DUCKDB_STATEMENT_TYPE_UPDATE_EXTENSIONS
	StatementTypeMergeInto        StatementType = C.DUCKDB_STATEMENT_TYPE_MERGE_INTO
)

// ErrorType wraps duckdb_error_type.
type ErrorType = C.duckdb_error_type

const (
	ErrorTypeInvalid              ErrorType = C.DUCKDB_ERROR_INVALID
	ErrorTypeOutOfRange           ErrorType = C.DUCKDB_ERROR_OUT_OF_RANGE
	ErrorTypeConversion           ErrorType = C.DUCKDB_ERROR_CONVERSION
	ErrorTypeUnknownType          ErrorType = C.DUCKDB_ERROR_UNKNOWN_TYPE
	ErrorTypeDecimal              ErrorType = C.DUCKDB_ERROR_DECIMAL
	ErrorTypeMismatchType         ErrorType = C.DUCKDB_ERROR_MISMATCH_TYPE
	ErrorTypeDivideByZero         ErrorType = C.DUCKDB_ERROR_DIVIDE_BY_ZERO
	ErrorTypeObjectSize           ErrorType = C.DUCKDB_ERROR_OBJECT_SIZE
	ErrorTypeInvalidType          ErrorType = C.DUCKDB_ERROR_INVALID_TYPE
	ErrorTypeSerialization        ErrorType = C.DUCKDB_ERROR_SERIALIZATION
	ErrorTypeTransaction          ErrorType = C.DUCKDB_ERROR_TRANSACTION
	ErrorTypeNotImplemented       ErrorType = C.DUCKDB_ERROR_NOT_IMPLEMENTED
	ErrorTypeExpression           ErrorType = C.DUCKDB_ERROR_EXPRESSION
	ErrorTypeCatalog              ErrorType = C.DUCKDB_ERROR_CATALOG
	ErrorTypeParser               ErrorType = C.DUCKDB_ERROR_PARSER
	ErrorTypePlanner              ErrorType = C.DUCKDB_ERROR_PLANNER
	ErrorTypeScheduler            ErrorType = C.DUCKDB_ERROR_SCHEDULER
	ErrorTypeExecutor             ErrorType = C.DUCKDB_ERROR_EXECUTOR
	ErrorTypeConstraint           ErrorType = C.DUCKDB_ERROR_CONSTRAINT
	ErrorTypeIndex                ErrorType = C.DUCKDB_ERROR_INDEX
	ErrorTypeStat                 ErrorType = C.DUCKDB_ERROR_STAT
	ErrorTypeConnection           ErrorType = C.DUCKDB_ERROR_CONNECTION
	ErrorTypeSyntax               ErrorType = C.DUCKDB_ERROR_SYNTAX
	ErrorTypeSettings             ErrorType = C.DUCKDB_ERROR_SETTINGS
	ErrorTypeBinder               ErrorType = C.DUCKDB_ERROR_BINDER
	ErrorTypeNetwork              ErrorType = C.DUCKDB_ERROR_NETWORK
	ErrorTypeOptimizer            ErrorType = C.DUCKDB_ERROR_OPTIMIZER
	ErrorTypeNullPointer          ErrorType = C.DUCKDB_ERROR_NULL_POINTER
	ErrorTypeErrorIO              ErrorType = C.DUCKDB_ERROR_IO
	ErrorTypeInterrupt            ErrorType = C.DUCKDB_ERROR_INTERRUPT
	ErrorTypeFatal                ErrorType = C.DUCKDB_ERROR_FATAL
	ErrorTypeInternal             ErrorType = C.DUCKDB_ERROR_INTERNAL
	ErrorTypeInvalidInput         ErrorType = C.DUCKDB_ERROR_INVALID_INPUT
	ErrorTypeOutOfMemory          ErrorType = C.DUCKDB_ERROR_OUT_OF_MEMORY
	ErrorTypePermission           ErrorType = C.DUCKDB_ERROR_PERMISSION
	ErrorTypeParameterNotResolved ErrorType = C.DUCKDB_ERROR_PARAMETER_NOT_RESOLVED
	ErrorTypeParameterNotAllowed  ErrorType = C.DUCKDB_ERROR_PARAMETER_NOT_ALLOWED
	ErrorTypeDependency           ErrorType = C.DUCKDB_ERROR_DEPENDENCY
	ErrorTypeHTTP                 ErrorType = C.DUCKDB_ERROR_HTTP
	ErrorTypeMissingExtension     ErrorType = C.DUCKDB_ERROR_MISSING_EXTENSION
	ErrorTypeAutoload             ErrorType = C.DUCKDB_ERROR_AUTOLOAD
	ErrorTypeSequence             ErrorType = C.DUCKDB_ERROR_SEQUENCE
	ErrorTypeInvalidConfiguration ErrorType = C.DUCKDB_INVALID_CONFIGURATION
)

// CastMode wraps duckdb_cast_mode.
type CastMode = C.duckdb_cast_mode

const (
	CastModeNormal CastMode = C.DUCKDB_CAST_NORMAL
	CastModeTry    CastMode = C.DUCKDB_CAST_TRY
)
