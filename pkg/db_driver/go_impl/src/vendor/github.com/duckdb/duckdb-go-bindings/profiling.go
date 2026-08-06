package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

func GetProfilingInfo(conn Connection) ProfilingInfo {
	info := C.duckdb_get_profiling_info(conn.data())
	return ProfilingInfo{
		Ptr: unsafe.Pointer(info),
	}
}

// ProfilingInfoGetValue wraps duckdb_profiling_info_get_value.
// The return value must be destroyed with DestroyValue.
func ProfilingInfoGetValue(info ProfilingInfo, key string) Value {
	cKey := C.CString(key)
	defer Free(unsafe.Pointer(cKey))
	v := C.duckdb_profiling_info_get_value(info.data(), cKey)

	return trackedValue(v)
}

// ProfilingInfoGetMetrics wraps duckdb_profiling_info_get_metrics.
// The return value must be destroyed with DestroyValue.
func ProfilingInfoGetMetrics(info ProfilingInfo) Value {
	v := C.duckdb_profiling_info_get_metrics(info.data())
	return trackedValue(v)
}

func ProfilingInfoGetChildCount(info ProfilingInfo) IdxT {
	return C.duckdb_profiling_info_get_child_count(info.data())
}

func ProfilingInfoGetChild(info ProfilingInfo, index IdxT) ProfilingInfo {
	child := C.duckdb_profiling_info_get_child(info.data(), index)
	return ProfilingInfo{
		Ptr: unsafe.Pointer(child),
	}
}
