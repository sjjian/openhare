package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// Query wraps duckdb_query.
// outRes must be destroyed with DestroyResult.
func Query(conn Connection, query string, outRes *Result) State {
	cQuery := C.CString(query)
	defer Free(unsafe.Pointer(cQuery))

	state := C.duckdb_query(conn.data(), cQuery, &outRes.data)
	trackedResult(outRes)
	return state
}

// DestroyResult wraps duckdb_destroy_result.
func DestroyResult(res *Result) {
	if res == nil || res.data.internal_data == nil {
		return
	}
	releaseAllocation(resultAllocation, res.data.internal_data)
	C.duckdb_destroy_result(&res.data)
	res.data.internal_data = nil
}

func ColumnName(res *Result, col IdxT) string {
	name := C.duckdb_column_name(&res.data, col)
	return C.GoString(name)
}

func ColumnType(res *Result, col IdxT) Type {
	return C.duckdb_column_type(&res.data, col)
}

func ResultStatementType(res Result) StatementType {
	return C.duckdb_result_statement_type(res.data)
}

// ColumnLogicalType wraps duckdb_column_logical_type.
// The return value must be destroyed with DestroyLogicalType.
func ColumnLogicalType(res *Result, col IdxT) LogicalType {
	logicalType := C.duckdb_column_logical_type(&res.data, col)
	return trackedLogicalType(logicalType)
}

// ResultGetArrowOptions wraps duckdb_result_get_arrow_options.
// The return value must be destroyed with DestroyArrowOptions.
func ResultGetArrowOptions(res *Result) ArrowOptions {
	options := C.duckdb_result_get_arrow_options(&res.data)
	return trackedArrowOptions(options)
}

func ColumnCount(res *Result) IdxT {
	return C.duckdb_column_count(&res.data)
}

func RowsChanged(res *Result) IdxT {
	return C.duckdb_rows_changed(&res.data)
}

func ResultError(res *Result) string {
	err := C.duckdb_result_error(&res.data)
	return C.GoString(err)
}

func ResultErrorType(res *Result) ErrorType {
	return C.duckdb_result_error_type(&res.data)
}

// ResultGetChunk wraps duckdb_result_get_chunk.
// The return value must be destroyed with DestroyDataChunk.
// Deprecated: See C API documentation.
func ResultGetChunk(res Result, index IdxT) DataChunk {
	chunk := C.duckdb_result_get_chunk(res.data, index)
	return trackedDataChunk(chunk)
}

// ResultIsStreaming wraps duckdb_result_is_streaming.
// Deprecated: ResultIsStreaming is deprecated.
func ResultIsStreaming(res Result) bool {
	return bool(C.duckdb_result_is_streaming(res.data))
}

// Deprecated: See C API documentation.
func ResultChunkCount(res Result) IdxT {
	return C.duckdb_result_chunk_count(res.data)
}

func ResultReturnType(res Result) ResultType {
	return C.duckdb_result_return_type(res.data)
}

// StreamFetchChunk wraps duckdb_stream_fetch_chunk.
// Returns StateSuccess with a data chunk from the streaming result.
// A StateSuccess chunk with size 0 indicates that the result is exhausted.
// A StateError return indicates that DuckDB returned NULL for an error.
// The returned data chunk must be destroyed with DestroyDataChunk after StateSuccess.
// Deprecated: StreamFetchChunk is deprecated.
func StreamFetchChunk(res Result, outChunk *DataChunk) State {
	chunk := C.duckdb_stream_fetch_chunk(res.data)
	// duckdb_stream_fetch_chunk returns NULL if the result has an error.
	if chunk == nil {
		return StateError
	}
	*outChunk = trackedDataChunk(chunk)
	return StateSuccess
}

func FetchChunk(res Result) DataChunk {
	chunk := C.duckdb_fetch_chunk(res.data)
	return trackedDataChunk(chunk)
}

// Deprecated: See C API documentation.
func ValueInt64(res *Result, col IdxT, row IdxT) int64 {
	v := C.duckdb_value_int64(&res.data, col, row)
	return int64(v)
}
