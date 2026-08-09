package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateTableFunction wraps duckdb_create_table_function.
// The return value must be destroyed with DestroyTableFunction.
func CreateTableFunction() TableFunction {
	f := C.duckdb_create_table_function()
	return trackedTableFunction(f)
}

// DestroyTableFunction wraps duckdb_destroy_table_function.
func DestroyTableFunction(f *TableFunction) {
	if f.Ptr == nil {
		return
	}
	releaseAllocation(tableFunctionAllocation, f.Ptr)
	data := f.data()
	C.duckdb_destroy_table_function(&data)
	f.Ptr = nil
}

func TableFunctionSetName(f TableFunction, name string) {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	C.duckdb_table_function_set_name(f.data(), cName)
}

func TableFunctionAddParameter(f TableFunction, logicalType LogicalType) {
	C.duckdb_table_function_add_parameter(f.data(), logicalType.data())
}

func TableFunctionAddNamedParameter(f TableFunction, name string, logicalType LogicalType) {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	C.duckdb_table_function_add_named_parameter(f.data(), cName, logicalType.data())
}

func TableFunctionSetExtraInfo(f TableFunction, extraInfoPtr unsafe.Pointer, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_delete_callback_t(callbackPtr)
	C.duckdb_table_function_set_extra_info(f.data(), extraInfoPtr, callback)
}

func TableFunctionSetBind(f TableFunction, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_table_function_bind_t(callbackPtr)
	C.duckdb_table_function_set_bind(f.data(), callback)
}

func TableFunctionSetInit(f TableFunction, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_table_function_init_t(callbackPtr)
	C.duckdb_table_function_set_init(f.data(), callback)
}

func TableFunctionSetLocalInit(f TableFunction, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_table_function_init_t(callbackPtr)
	C.duckdb_table_function_set_local_init(f.data(), callback)
}

func TableFunctionSetFunction(f TableFunction, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_table_function_t(callbackPtr)
	C.duckdb_table_function_set_function(f.data(), callback)
}

func TableFunctionSupportsProjectionPushdown(f TableFunction, pushdown bool) {
	C.duckdb_table_function_supports_projection_pushdown(f.data(), C.bool(pushdown))
}

func RegisterTableFunction(conn Connection, f TableFunction) State {
	return C.duckdb_register_table_function(conn.data(), f.data())
}

func BindGetExtraInfo(info BindInfo) unsafe.Pointer {
	return C.duckdb_bind_get_extra_info(info.data())
}

// TableFunctionGetClientContext wraps duckdb_table_function_get_client_context.
// outCtx must be destroyed with DestroyClientContext.
func TableFunctionGetClientContext(info BindInfo, outCtx *ClientContext) {
	var ctx C.duckdb_client_context
	C.duckdb_table_function_get_client_context(info.data(), &ctx)
	*outCtx = trackedClientContext(ctx)
}

func BindAddResultColumn(info BindInfo, name string, logicalType LogicalType) {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	C.duckdb_bind_add_result_column(info.data(), cName, logicalType.data())
}

func BindGetParameterCount(info BindInfo) IdxT {
	return C.duckdb_bind_get_parameter_count(info.data())
}

// BindGetParameter wraps duckdb_bind_get_parameter.
// The return value must be destroyed with DestroyValue.
func BindGetParameter(info BindInfo, index IdxT) Value {
	v := C.duckdb_bind_get_parameter(info.data(), index)
	return trackedValue(v)
}

// BindGetNamedParameter wraps duckdb_bind_get_named_parameter.
// The return value must be destroyed with DestroyValue.
func BindGetNamedParameter(info BindInfo, name string) Value {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	v := C.duckdb_bind_get_named_parameter(info.data(), cName)
	return trackedValue(v)
}

func BindSetBindData(info BindInfo, bindDataPtr unsafe.Pointer, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_delete_callback_t(callbackPtr)
	C.duckdb_bind_set_bind_data(info.data(), bindDataPtr, callback)
}

func BindSetCardinality(info BindInfo, cardinality IdxT, exact bool) {
	C.duckdb_bind_set_cardinality(info.data(), cardinality, C.bool(exact))
}

func BindSetError(info BindInfo, err string) {
	cErr := C.CString(err)
	defer Free(unsafe.Pointer(cErr))
	C.duckdb_bind_set_error(info.data(), cErr)
}

func InitGetExtraInfo(info InitInfo) unsafe.Pointer {
	return C.duckdb_init_get_extra_info(info.data())
}

func InitGetBindData(info InitInfo) unsafe.Pointer {
	return C.duckdb_init_get_bind_data(info.data())
}

func InitSetInitData(info InitInfo, initDataPtr unsafe.Pointer, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_delete_callback_t(callbackPtr)
	C.duckdb_init_set_init_data(info.data(), initDataPtr, callback)
}

func InitGetColumnCount(info InitInfo) IdxT {
	return C.duckdb_init_get_column_count(info.data())
}

func InitGetColumnIndex(info InitInfo, index IdxT) IdxT {
	return C.duckdb_init_get_column_index(info.data(), index)
}

func InitSetMaxThreads(info InitInfo, max IdxT) {
	C.duckdb_init_set_max_threads(info.data(), max)
}

func InitSetError(info InitInfo, err string) {
	cStr := C.CString(err)
	defer Free(unsafe.Pointer(cStr))
	C.duckdb_init_set_error(info.data(), cStr)
}

func FunctionGetExtraInfo(info FunctionInfo) unsafe.Pointer {
	return C.duckdb_function_get_extra_info(info.data())
}

func FunctionGetBindData(info FunctionInfo) unsafe.Pointer {
	return C.duckdb_function_get_bind_data(info.data())
}

func FunctionGetInitData(info FunctionInfo) unsafe.Pointer {
	return C.duckdb_function_get_init_data(info.data())
}

func FunctionGetLocalInitData(info FunctionInfo) unsafe.Pointer {
	return C.duckdb_function_get_local_init_data(info.data())
}

func FunctionSetError(info FunctionInfo, err string) {
	cErr := C.CString(err)
	defer Free(unsafe.Pointer(cErr))
	C.duckdb_function_set_error(info.data(), cErr)
}
