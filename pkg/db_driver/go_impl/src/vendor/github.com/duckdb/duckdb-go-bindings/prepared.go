package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// Prepare wraps duckdb_prepare.
// outPreparedStmt must be destroyed with DestroyPrepare.
func Prepare(conn Connection, query string, outPreparedStmt *PreparedStatement) State {
	cQuery := C.CString(query)
	defer Free(unsafe.Pointer(cQuery))

	var preparedStmt C.duckdb_prepared_statement
	state := C.duckdb_prepare(conn.data(), cQuery, &preparedStmt)
	*outPreparedStmt = trackedPreparedStatement(preparedStmt)
	return state
}

// DestroyPrepare wraps duckdb_destroy_prepare.
func DestroyPrepare(preparedStmt *PreparedStatement) {
	if preparedStmt.Ptr == nil {
		return
	}
	releaseAllocation(preparedStatementAllocation, preparedStmt.Ptr)
	data := preparedStmt.data()
	C.duckdb_destroy_prepare(&data)
	preparedStmt.Ptr = nil
}

func PrepareError(preparedStmt PreparedStatement) string {
	err := C.duckdb_prepare_error(preparedStmt.data())
	return C.GoString(err)
}

func NParams(preparedStmt PreparedStatement) IdxT {
	return C.duckdb_nparams(preparedStmt.data())
}

func ParameterName(preparedStmt PreparedStatement, index IdxT) string {
	cName := C.duckdb_parameter_name(preparedStmt.data(), index)
	defer Free(unsafe.Pointer(cName))
	return C.GoString(cName)
}

func ParamType(preparedStmt PreparedStatement, index IdxT) Type {
	return C.duckdb_param_type(preparedStmt.data(), index)
}

// ParamLogicalType wraps duckdb_param_logical_type.
// The return value must be destroyed with DestroyLogicalType.
func ParamLogicalType(preparedStmt PreparedStatement, index IdxT) LogicalType {
	logicalType := C.duckdb_param_logical_type(preparedStmt.data(), index)
	return trackedLogicalType(logicalType)
}

func ClearBindings(preparedStmt PreparedStatement) State {
	return C.duckdb_clear_bindings(preparedStmt.data())
}

func PreparedStatementType(preparedStmt PreparedStatement) StatementType {
	return C.duckdb_prepared_statement_type(preparedStmt.data())
}

func PreparedStatementColumnCount(preparedStmt PreparedStatement) IdxT {
	return C.duckdb_prepared_statement_column_count(preparedStmt.data())
}

func PreparedStatementColumnName(preparedStmt PreparedStatement, index IdxT) string {
	name := C.duckdb_prepared_statement_column_name(preparedStmt.data(), index)
	defer Free(unsafe.Pointer(name))
	return C.GoString(name)
}

// PreparedStatementColumnLogicalType wraps duckdb_prepared_statement_column_logical_type.
// The return value must be destroyed with DestroyLogicalType.
func PreparedStatementColumnLogicalType(preparedStmt PreparedStatement, index IdxT) LogicalType {
	logicalType := C.duckdb_prepared_statement_column_logical_type(preparedStmt.data(), index)
	return trackedLogicalType(logicalType)
}

func PreparedStatementColumnType(preparedStmt PreparedStatement, index IdxT) Type {
	return C.duckdb_prepared_statement_column_type(preparedStmt.data(), index)
}

func BindValue(preparedStmt PreparedStatement, index IdxT, v Value) State {
	return C.duckdb_bind_value(preparedStmt.data(), index, v.data())
}

func BindParameterIndex(preparedStmt PreparedStatement, outIndex *IdxT, name string) State {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	return C.duckdb_bind_parameter_index(preparedStmt.data(), outIndex, cName)
}

func BindBoolean(preparedStmt PreparedStatement, index IdxT, v bool) State {
	return C.duckdb_bind_boolean(preparedStmt.data(), index, C.bool(v))
}

func BindInt8(preparedStmt PreparedStatement, index IdxT, v int8) State {
	return C.duckdb_bind_int8(preparedStmt.data(), index, C.int8_t(v))
}

func BindInt16(preparedStmt PreparedStatement, index IdxT, v int16) State {
	return C.duckdb_bind_int16(preparedStmt.data(), index, C.int16_t(v))
}

func BindInt32(preparedStmt PreparedStatement, index IdxT, v int32) State {
	return C.duckdb_bind_int32(preparedStmt.data(), index, C.int32_t(v))
}

func BindInt64(preparedStmt PreparedStatement, index IdxT, v int64) State {
	return C.duckdb_bind_int64(preparedStmt.data(), index, C.int64_t(v))
}

func BindHugeInt(preparedStmt PreparedStatement, index IdxT, v HugeInt) State {
	return C.duckdb_bind_hugeint(preparedStmt.data(), index, v)
}

func BindUHugeInt(preparedStmt PreparedStatement, index IdxT, v UHugeInt) State {
	return C.duckdb_bind_uhugeint(preparedStmt.data(), index, v)
}

func BindDecimal(preparedStmt PreparedStatement, index IdxT, v Decimal) State {
	return C.duckdb_bind_decimal(preparedStmt.data(), index, v)
}

func BindUInt8(preparedStmt PreparedStatement, index IdxT, v uint8) State {
	return C.duckdb_bind_uint8(preparedStmt.data(), index, C.uint8_t(v))
}

func BindUInt16(preparedStmt PreparedStatement, index IdxT, v uint16) State {
	return C.duckdb_bind_uint16(preparedStmt.data(), index, C.uint16_t(v))
}

func BindUInt32(preparedStmt PreparedStatement, index IdxT, v uint32) State {
	return C.duckdb_bind_uint32(preparedStmt.data(), index, C.uint32_t(v))
}

func BindUInt64(preparedStmt PreparedStatement, index IdxT, v uint64) State {
	return C.duckdb_bind_uint64(preparedStmt.data(), index, C.uint64_t(v))
}

func BindFloat(preparedStmt PreparedStatement, index IdxT, v float32) State {
	return C.duckdb_bind_float(preparedStmt.data(), index, C.float(v))
}

func BindDouble(preparedStmt PreparedStatement, index IdxT, v float64) State {
	return C.duckdb_bind_double(preparedStmt.data(), index, C.double(v))
}

func BindDate(preparedStmt PreparedStatement, index IdxT, v Date) State {
	return C.duckdb_bind_date(preparedStmt.data(), index, v)
}

func BindTime(preparedStmt PreparedStatement, index IdxT, v Time) State {
	return C.duckdb_bind_time(preparedStmt.data(), index, v)
}

func BindTimestamp(preparedStmt PreparedStatement, index IdxT, v Timestamp) State {
	return C.duckdb_bind_timestamp(preparedStmt.data(), index, v)
}

func BindTimestampTZ(preparedStmt PreparedStatement, index IdxT, v Timestamp) State {
	return C.duckdb_bind_timestamp_tz(preparedStmt.data(), index, v)
}

func BindInterval(preparedStmt PreparedStatement, index IdxT, v Interval) State {
	return C.duckdb_bind_interval(preparedStmt.data(), index, v)
}

func BindVarchar(preparedStmt PreparedStatement, index IdxT, v string) State {
	return BindVarcharLength(preparedStmt, index, v, IdxT(len(v)))
}

func BindVarcharLength(preparedStmt PreparedStatement, index IdxT, v string, length IdxT) State {
	var cStr *C.char
	if length > 0 {
		cStr = (*C.char)(unsafe.Pointer(unsafe.StringData(v)))
	}
	return C.duckdb_bind_varchar_length(preparedStmt.data(), index, cStr, length)
}

func BindBlob(preparedStmt PreparedStatement, index IdxT, v []byte) State {
	var data unsafe.Pointer
	if len(v) > 0 {
		data = unsafe.Pointer(&v[0])
	}
	return C.duckdb_bind_blob(preparedStmt.data(), index, data, IdxT(len(v)))
}

func BindNull(preparedStmt PreparedStatement, index IdxT) State {
	return C.duckdb_bind_null(preparedStmt.data(), index)
}

// ExecutePrepared wraps duckdb_execute_prepared.
// outRes must be destroyed with DestroyResult.
func ExecutePrepared(preparedStmt PreparedStatement, outRes *Result) State {
	state := C.duckdb_execute_prepared(preparedStmt.data(), &outRes.data)
	trackedResult(outRes)
	return state
}

// ExecutePreparedStreaming wraps duckdb_execute_prepared_streaming.
// outRes must be destroyed with DestroyResult.
// Deprecated: ExecutePreparedStreaming is deprecated.
func ExecutePreparedStreaming(preparedStmt PreparedStatement, outRes *Result) State {
	state := C.duckdb_execute_prepared_streaming(preparedStmt.data(), &outRes.data)
	trackedResult(outRes)
	return state
}

// ExtractStatements wraps duckdb_extract_statements.
// outExtractedStmts must be destroyed with DestroyExtracted.
func ExtractStatements(conn Connection, query string, outExtractedStmts *ExtractedStatements) IdxT {
	cQuery := C.CString(query)
	defer Free(unsafe.Pointer(cQuery))

	var extractedStmts C.duckdb_extracted_statements
	count := C.duckdb_extract_statements(conn.data(), cQuery, &extractedStmts)
	*outExtractedStmts = trackedExtractedStatements(extractedStmts)
	return count
}

// PrepareExtractedStatement wraps duckdb_prepare_extracted_statement.
// outPreparedStmt must be destroyed with DestroyPrepare.
func PrepareExtractedStatement(conn Connection, extractedStmts ExtractedStatements, index IdxT, outPreparedStmt *PreparedStatement) State {
	var preparedStmt C.duckdb_prepared_statement
	state := C.duckdb_prepare_extracted_statement(conn.data(), extractedStmts.data(), index, &preparedStmt)
	*outPreparedStmt = trackedPreparedStatement(preparedStmt)
	return state
}

func ExtractStatementsError(extractedStmts ExtractedStatements) string {
	err := C.duckdb_extract_statements_error(extractedStmts.data())
	return C.GoString(err)
}

// DestroyExtracted wraps duckdb_destroy_extracted.
func DestroyExtracted(extractedStmts *ExtractedStatements) {
	if extractedStmts.Ptr == nil {
		return
	}
	releaseAllocation(extractedStatementsAllocation, extractedStmts.Ptr)
	data := extractedStmts.data()
	C.duckdb_destroy_extracted(&data)
	extractedStmts.Ptr = nil
}

// PendingPrepared wraps duckdb_pending_prepared.
// outPendingRes must be destroyed with DestroyPending.
func PendingPrepared(preparedStmt PreparedStatement, outPendingRes *PendingResult) State {
	var pendingRes C.duckdb_pending_result
	state := C.duckdb_pending_prepared(preparedStmt.data(), &pendingRes)
	*outPendingRes = trackedPendingResult(pendingRes)
	return state
}

// PendingPreparedStreaming wraps duckdb_pending_prepared_streaming.
// outPendingRes must be destroyed with DestroyPending.
// Deprecated: PendingPreparedStreaming is deprecated.
func PendingPreparedStreaming(preparedStmt PreparedStatement, outPendingRes *PendingResult) State {
	var pendingRes C.duckdb_pending_result
	state := C.duckdb_pending_prepared_streaming(preparedStmt.data(), &pendingRes)
	*outPendingRes = trackedPendingResult(pendingRes)
	return state
}

// DestroyPending wraps duckdb_destroy_pending.
func DestroyPending(pendingRes *PendingResult) {
	if pendingRes.Ptr == nil {
		return
	}
	releaseAllocation(pendingResultAllocation, pendingRes.Ptr)
	data := pendingRes.data()
	C.duckdb_destroy_pending(&data)
	pendingRes.Ptr = nil
}

func PendingError(pendingRes PendingResult) string {
	err := C.duckdb_pending_error(pendingRes.data())
	return C.GoString(err)
}

func PendingExecuteTask(pendingRes PendingResult) PendingState {
	return C.duckdb_pending_execute_task(pendingRes.data())
}

func PendingExecuteCheckState(pendingRes PendingResult) PendingState {
	return C.duckdb_pending_execute_check_state(pendingRes.data())
}

// ExecutePending wraps duckdb_execute_pending.
// outRes must be destroyed with DestroyResult.
func ExecutePending(res PendingResult, outRes *Result) State {
	state := C.duckdb_execute_pending(res.data(), &outRes.data)
	trackedResult(outRes)
	return state
}

func PendingExecutionIsFinished(state PendingState) bool {
	return bool(C.duckdb_pending_execution_is_finished(state))
}
