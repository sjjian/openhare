package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateLogStorage wraps duckdb_create_log_storage.
// The return value must be destroyed with DestroyLogStorage.
func CreateLogStorage() LogStorage {
	logStorage := C.duckdb_create_log_storage()
	return trackedLogStorage(logStorage)
}

// DestroyLogStorage wraps duckdb_destroy_log_storage.
func DestroyLogStorage(logStorage *LogStorage) {
	if logStorage.Ptr == nil {
		return
	}
	releaseAllocation(logStorageAllocation, logStorage.Ptr)
	data := logStorage.data()
	C.duckdb_destroy_log_storage(&data)
	logStorage.Ptr = nil
}

func LogStorageSetWriteLogEntry(logStorage LogStorage, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_logger_write_log_entry_t(callbackPtr)
	C.duckdb_log_storage_set_write_log_entry(logStorage.data(), callback)
}

func LogStorageSetExtraData(logStorage LogStorage, extraDataPtr unsafe.Pointer, callbackPtr unsafe.Pointer) {
	callback := C.duckdb_delete_callback_t(callbackPtr)
	C.duckdb_log_storage_set_extra_data(logStorage.data(), extraDataPtr, callback)
}

func LogStorageSetName(logStorage LogStorage, name string) {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	C.duckdb_log_storage_set_name(logStorage.data(), cName)
}

func RegisterLogStorage(db Database, logStorage LogStorage) State {
	return C.duckdb_register_log_storage(db.data(), logStorage.data())
}
