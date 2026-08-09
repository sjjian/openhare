package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateConfig wraps duckdb_create_config.
// outConfig must be destroyed with DestroyConfig.
func CreateConfig(outConfig *Config) State {
	var config C.duckdb_config
	state := C.duckdb_create_config(&config)
	*outConfig = trackedConfig(config)
	return state
}

func ConfigCount() uint64 {
	return uint64(C.duckdb_config_count())
}

func GetConfigFlag(index uint64, outName *string, outDescription *string) State {
	var name *C.char
	var description *C.char

	state := C.duckdb_get_config_flag(C.size_t(index), &name, &description)
	*outName = C.GoString(name)
	*outDescription = C.GoString(description)
	return state
}

func SetConfig(config Config, name string, option string) State {
	cName := C.CString(name)
	defer Free(unsafe.Pointer(cName))
	cOption := C.CString(option)
	defer Free(unsafe.Pointer(cOption))
	return C.duckdb_set_config(config.data(), cName, cOption)
}

// DestroyConfig wraps duckdb_destroy_config.
func DestroyConfig(config *Config) {
	if config.Ptr == nil {
		return
	}
	releaseAllocation(configAllocation, config.Ptr)
	data := config.data()
	C.duckdb_destroy_config(&data)
	config.Ptr = nil
}
