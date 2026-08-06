package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateErrorData wraps duckdb_create_error_data.
// The return value must be destroyed with DestroyErrorData.
func CreateErrorData(t ErrorType, msg string) ErrorData {
	cMsg := C.CString(msg)
	defer Free(unsafe.Pointer(cMsg))

	errorData := C.duckdb_create_error_data(t, cMsg)
	return trackedErrorData(errorData)
}

// DestroyErrorData wraps duckdb_destroy_error_data.
func DestroyErrorData(errorData *ErrorData) {
	if errorData.Ptr == nil {
		return
	}
	releaseAllocation(errorDataAllocation, errorData.Ptr)
	data := errorData.data()
	C.duckdb_destroy_error_data(&data)
	errorData.Ptr = nil
}

func ErrorDataErrorType(errorData ErrorData) ErrorType {
	return C.duckdb_error_data_error_type(errorData.data())
}

func ErrorDataMessage(errorData ErrorData) string {
	msg := C.duckdb_error_data_message(errorData.data())
	return C.GoString(msg)
}

func ErrorDataHasError(errorData ErrorData) bool {
	return bool(C.duckdb_error_data_has_error(errorData.data()))
}
