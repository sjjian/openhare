package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

func AddReplacementScan(db Database, callbackPtr unsafe.Pointer, extraData unsafe.Pointer, deleteCallbackPtr unsafe.Pointer) {
	callback := C.duckdb_replacement_callback_t(callbackPtr)
	deleteCallback := C.duckdb_delete_callback_t(deleteCallbackPtr)
	C.duckdb_add_replacement_scan(db.data(), callback, extraData, deleteCallback)
}

func ReplacementScanSetFunctionName(info ReplacementScanInfo, name string) {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	C.duckdb_replacement_scan_set_function_name(info.data(), cName)
}

func ReplacementScanAddParameter(info ReplacementScanInfo, v Value) {
	C.duckdb_replacement_scan_add_parameter(info.data(), v.data())
}

func ReplacementScanSetError(info ReplacementScanInfo, err string) {
	cErr := C.CString(err)
	defer Free(unsafe.Pointer(cErr))
	C.duckdb_replacement_scan_set_error(info.data(), cErr)
}
