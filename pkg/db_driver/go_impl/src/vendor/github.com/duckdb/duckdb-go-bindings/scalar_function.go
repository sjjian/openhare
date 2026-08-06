package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateScalarFunction wraps duckdb_create_scalar_function.
// The return value must be destroyed with DestroyScalarFunction.
func CreateScalarFunction() ScalarFunction {
	f := C.duckdb_create_scalar_function()
	return trackedScalarFunction(f)
}

// DestroyScalarFunction wraps duckdb_destroy_scalar_function.
func DestroyScalarFunction(f *ScalarFunction) {
	if f.Ptr == nil {
		return
	}
	releaseAllocation(scalarFunctionAllocation, f.Ptr)
	data := f.data()
	C.duckdb_destroy_scalar_function(&data)
	f.Ptr = nil
}

func ScalarFunctionSetName(f ScalarFunction, name string) {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	C.duckdb_scalar_function_set_name(f.data(), cName)
}

func ScalarFunctionSetVarargs(f ScalarFunction, logicalType LogicalType) {
	C.duckdb_scalar_function_set_varargs(f.data(), logicalType.data())
}

func ScalarFunctionSetSpecialHandling(f ScalarFunction) {
	C.duckdb_scalar_function_set_special_handling(f.data())
}

func ScalarFunctionSetVolatile(f ScalarFunction) {
	C.duckdb_scalar_function_set_volatile(f.data())
}

func ScalarFunctionAddParameter(f ScalarFunction, logicalType LogicalType) {
	C.duckdb_scalar_function_add_parameter(f.data(), logicalType.data())
}

func ScalarFunctionSetReturnType(f ScalarFunction, logicalType LogicalType) {
	C.duckdb_scalar_function_set_return_type(f.data(), logicalType.data())
}

func ScalarFunctionSetExtraInfo(f ScalarFunction, extraInfoPtr unsafe.Pointer, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_delete_callback_t(callbackPtr)
	C.duckdb_scalar_function_set_extra_info(f.data(), extraInfoPtr, callback)
}

func ScalarFunctionSetBind(f ScalarFunction, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_scalar_function_bind_t(callbackPtr)
	C.duckdb_scalar_function_set_bind(f.data(), callback)
}

func ScalarFunctionSetBindData(info BindInfo, bindDataPtr unsafe.Pointer, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_delete_callback_t(callbackPtr)
	C.duckdb_scalar_function_set_bind_data(info.data(), bindDataPtr, callback)
}

func ScalarFunctionSetBindDataCopy(info BindInfo, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_copy_callback_t(callbackPtr)
	C.duckdb_scalar_function_set_bind_data_copy(info.data(), callback)
}

func ScalarFunctionBindSetError(info BindInfo, err string) {
	cErr := C.CString(err)
	defer Free(unsafe.Pointer(cErr))
	C.duckdb_scalar_function_bind_set_error(info.data(), cErr)
}

func ScalarFunctionSetFunction(f ScalarFunction, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_scalar_function_t(callbackPtr)
	C.duckdb_scalar_function_set_function(f.data(), callback)
}

func RegisterScalarFunction(conn Connection, f ScalarFunction) State {
	return C.duckdb_register_scalar_function(conn.data(), f.data())
}

func ScalarFunctionGetExtraInfo(info FunctionInfo) unsafe.Pointer {
	return C.duckdb_scalar_function_get_extra_info(info.data())
}

func ScalarFunctionBindGetExtraInfo(info BindInfo) unsafe.Pointer {
	return C.duckdb_scalar_function_bind_get_extra_info(info.data())
}

func ScalarFunctionGetBindData(info FunctionInfo) unsafe.Pointer {
	return C.duckdb_scalar_function_get_bind_data(info.data())
}

// ScalarFunctionGetClientContext wraps duckdb_scalar_function_get_client_context.
// outCtx must be destroyed with DestroyClientContext.
func ScalarFunctionGetClientContext(info BindInfo, outCtx *ClientContext) {
	var ctx C.duckdb_client_context
	C.duckdb_scalar_function_get_client_context(info.data(), &ctx)
	*outCtx = trackedClientContext(ctx)
}

func ScalarFunctionSetError(info FunctionInfo, err string) {
	cErr := C.CString(err)
	defer Free(unsafe.Pointer(cErr))
	C.duckdb_scalar_function_set_error(info.data(), cErr)
}

// CreateScalarFunctionSet wraps duckdb_create_scalar_function_set.
// The return value must be destroyed with DestroyScalarFunctionSet.
func CreateScalarFunctionSet(name string) ScalarFunctionSet {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))

	set := C.duckdb_create_scalar_function_set(cName)
	return trackedScalarFunctionSet(set)
}

// DestroyScalarFunctionSet wraps duckdb_destroy_scalar_function_set.
func DestroyScalarFunctionSet(set *ScalarFunctionSet) {
	if set.Ptr == nil {
		return
	}
	releaseAllocation(scalarFunctionSetAllocation, set.Ptr)
	data := set.data()
	C.duckdb_destroy_scalar_function_set(&data)
	set.Ptr = nil
}

func AddScalarFunctionToSet(set ScalarFunctionSet, f ScalarFunction) State {
	return C.duckdb_add_scalar_function_to_set(set.data(), f.data())
}

func RegisterScalarFunctionSet(conn Connection, f ScalarFunctionSet) State {
	return C.duckdb_register_scalar_function_set(conn.data(), f.data())
}

func ScalarFunctionBindGetArgumentCount(info BindInfo) IdxT {
	return C.duckdb_scalar_function_bind_get_argument_count(info.data())
}

// ScalarFunctionBindGetArgument wraps duckdb_scalar_function_bind_get_argument.
// The return value must be destroyed with DestroyExpression.
func ScalarFunctionBindGetArgument(info BindInfo, index IdxT) Expression {
	expr := C.duckdb_scalar_function_bind_get_argument(info.data(), index)
	return trackedExpression(expr)
}
