package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// AppenderCreate wraps duckdb_appender_create.
// outAppender must be destroyed with AppenderDestroy.
// Deprecated: Use AppenderCreateExt or AppenderCreateQuery.
func AppenderCreate(conn Connection, schema string, table string, outAppender *Appender) State {
	cSchema := C.CString(schema)
	defer Free(unsafe.Pointer(cSchema))
	cTable := C.CString(table)
	defer Free(unsafe.Pointer(cTable))

	var appender C.duckdb_appender
	state := C.duckdb_appender_create(conn.data(), cSchema, cTable, &appender)
	*outAppender = trackedAppender(appender)
	return state
}

// AppenderCreateExt wraps duckdb_appender_create_ext.
// outAppender must be destroyed with AppenderDestroy.
func AppenderCreateExt(conn Connection, catalog string, schema string, table string, outAppender *Appender) State {
	cCatalog := C.CString(catalog)
	defer Free(unsafe.Pointer(cCatalog))
	cSchema := C.CString(schema)
	defer Free(unsafe.Pointer(cSchema))
	cTable := C.CString(table)
	defer Free(unsafe.Pointer(cTable))

	var appender C.duckdb_appender
	state := C.duckdb_appender_create_ext(conn.data(), cCatalog, cSchema, cTable, &appender)
	*outAppender = trackedAppender(appender)
	return state
}

// AppenderCreateQuery wraps duckdb_appender_create_query.
// outAppender must be destroyed with AppenderDestroy.
func AppenderCreateQuery(conn Connection, query string, types []LogicalType, tableName string, columnNames []string, outAppender *Appender) State {
	cQuery := C.CString(query)
	defer Free(unsafe.Pointer(cQuery))

	typesPtr := allocLogicalTypes(types)
	defer Free(unsafe.Pointer(typesPtr))

	// The table name is optional.
	cTableName := unsafe.Pointer(nil)
	if tableName != "" {
		cTableName = unsafe.Pointer(C.CString(tableName))
	}
	defer Free(cTableName)

	namesAlloc := allocNames(columnNames)
	defer freeNameList(namesAlloc)

	columnCount := IdxT(len(types))
	var appender C.duckdb_appender
	state := C.duckdb_appender_create_query(conn.data(), cQuery, columnCount, typesPtr, (*C.char)(cTableName), namesAlloc.arr, &appender)
	*outAppender = trackedAppender(appender)
	return state
}

func AppenderColumnCount(appender Appender) IdxT {
	return C.duckdb_appender_column_count(appender.data())
}

// AppenderColumnType wraps duckdb_appender_column_type.
// The return value must be destroyed with DestroyLogicalType.
func AppenderColumnType(appender Appender, index IdxT) LogicalType {
	logicalType := C.duckdb_appender_column_type(appender.data(), index)
	return trackedLogicalType(logicalType)
}

func AppenderError(appender Appender) string {
	err := C.duckdb_appender_error(appender.data())
	return C.GoString(err)
}

// AppenderErrorData wraps duckdb_appender_error_data.
// The return value must be destroyed with DestroyErrorData.
func AppenderErrorData(appender Appender) ErrorData {
	errorData := C.duckdb_appender_error_data(appender.data())
	return trackedErrorData(errorData)
}

func AppenderFlush(appender Appender) State {
	return C.duckdb_appender_flush(appender.data())
}

func AppenderClear(appender Appender) State {
	return C.duckdb_appender_clear(appender.data())
}

func AppenderClose(appender Appender) State {
	return C.duckdb_appender_close(appender.data())
}

// AppenderDestroy wraps duckdb_appender_destroy.
func AppenderDestroy(appender *Appender) State {
	if appender.Ptr == nil {
		return StateSuccess
	}
	releaseAllocation(appenderAllocation, appender.Ptr)
	data := appender.data()
	state := C.duckdb_appender_destroy(&data)
	appender.Ptr = nil
	return state
}

func AppenderAddColumn(appender Appender, name string) State {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	return C.duckdb_appender_add_column(appender.data(), cName)
}

func AppenderClearColumns(appender Appender) State {
	return C.duckdb_appender_clear_columns(appender.data())
}

// TODO:
// duckdb_appender_begin_row
// duckdb_appender_end_row
// duckdb_append_default

func AppendDefaultToChunk(appender Appender, chunk DataChunk, col IdxT, row IdxT) State {
	return C.duckdb_append_default_to_chunk(appender.data(), chunk.data(), col, row)
}

// TODO:
// duckdb_append_bool
// duckdb_append_int8
// duckdb_append_int16
// duckdb_append_int32
// duckdb_append_int64
// duckdb_append_hugeint
// duckdb_append_uint8
// duckdb_append_uint16
// duckdb_append_uint32
// duckdb_append_uint64
// duckdb_append_uhugeint
// duckdb_append_float
// duckdb_append_double
// duckdb_append_date
// duckdb_append_time
// duckdb_append_timestamp
// duckdb_append_interval
// duckdb_append_varchar
// duckdb_append_varchar_length
// duckdb_append_blob
// duckdb_append_null
// duckdb_append_value

func AppendDataChunk(appender Appender, chunk DataChunk) State {
	return C.duckdb_append_data_chunk(appender.data(), chunk.data())
}
