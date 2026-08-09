package duckdb

/*
void write_log_entry_callback(void *, void *, void *, void *, void *);
typedef void (*write_log_entry_callback_t)(void *, void *, void *, void *, void *);

void log_storage_delete_callback(void *);
typedef void (*log_storage_delete_callback_t)(void *);
*/
import "C"

import (
	"runtime"
	"runtime/cgo"
	"unsafe"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// DefaultLoggerCallbackFn defines the signature of a logging callback.
type DefaultLoggerCallbackFn func(level, logType, logMsg string)

// LoggerCallbacks exposes possible logging callback functions.
type LoggerCallbacks struct {
	DefaultLoggerCallback DefaultLoggerCallbackFn
}

type extraData struct {
	callbacks LoggerCallbacks
}

// RegisterLogStorage enables the user to register a custom log storage on the database instance.
// After enabling that log storage via "SET logging_storage = 'MyCustomStorage'",
// DuckDB forwards all log calls to the registered callback function(s).
func RegisterLogStorage(c *Connector, name string, callbacks LoggerCallbacks) error {
	// Create the log storage.
	logStorage := mapping.CreateLogStorage()
	defer mapping.DestroyLogStorage(&logStorage)

	// Set the write-entry callback and the name.
	writeEntryPtr := unsafe.Pointer(C.write_log_entry_callback_t(C.write_log_entry_callback))
	mapping.LogStorageSetWriteLogEntry(logStorage, writeEntryPtr)
	mapping.LogStorageSetName(logStorage, name)

	// Pin the extra data.
	value := pinnedValue[*extraData]{
		pinner: &runtime.Pinner{},
		value:  &extraData{callbacks: callbacks},
	}
	h := cgo.NewHandle(value)
	value.pinner.Pin(&h)

	// Set the extra data.
	deleteCallbackPtr := unsafe.Pointer(C.log_storage_delete_callback_t(C.log_storage_delete_callback))
	mapping.LogStorageSetExtraData(logStorage, unsafe.Pointer(&h), deleteCallbackPtr)

	// Register the log storage.
	state := mapping.RegisterLogStorage(c.db, logStorage)
	if state == mapping.StateError {
		return errFailedToRegisterLogStorage
	}
	return nil
}

//export write_log_entry_callback
func write_log_entry_callback(extraDataPtr, timestampPtr, levelPtr, logTypePtr, logMsgPtr unsafe.Pointer) {
	data := getPinned[*extraData](extraDataPtr)

	level := C.GoString((*C.char)(levelPtr))
	logType := C.GoString((*C.char)(logTypePtr))
	logMsg := C.GoString((*C.char)(logMsgPtr))

	data.callbacks.DefaultLoggerCallback(level, logType, logMsg)
}

//export log_storage_delete_callback
func log_storage_delete_callback(info unsafe.Pointer) {
	h := *(*cgo.Handle)(info)
	h.Value().(unpinner).unpin()
	h.Delete()
}
