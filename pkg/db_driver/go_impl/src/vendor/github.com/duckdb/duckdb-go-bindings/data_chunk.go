package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateDataChunk wraps duckdb_create_data_chunk.
// The return value must be destroyed with DestroyDataChunk.
func CreateDataChunk(types []LogicalType) DataChunk {
	typesPtr := allocLogicalTypes(types)
	defer Free(unsafe.Pointer(typesPtr))

	chunk := C.duckdb_create_data_chunk(typesPtr, IdxT(len(types)))

	return trackedDataChunk(chunk)
}

// DestroyDataChunk wraps duckdb_destroy_data_chunk.
func DestroyDataChunk(chunk *DataChunk) {
	if chunk.Ptr == nil {
		return
	}
	releaseAllocation(dataChunkAllocation, chunk.Ptr)
	data := chunk.data()
	C.duckdb_destroy_data_chunk(&data)
	chunk.Ptr = nil
}

func DataChunkReset(chunk DataChunk) {
	C.duckdb_data_chunk_reset(chunk.data())
}

func DataChunkGetColumnCount(chunk DataChunk) IdxT {
	return C.duckdb_data_chunk_get_column_count(chunk.data())
}

func DataChunkGetVector(chunk DataChunk, index IdxT) Vector {
	vec := C.duckdb_data_chunk_get_vector(chunk.data(), index)
	return Vector{
		Ptr: unsafe.Pointer(vec),
	}
}

func DataChunkGetSize(chunk DataChunk) IdxT {
	return C.duckdb_data_chunk_get_size(chunk.data())
}

func DataChunkSetSize(chunk DataChunk, size IdxT) {
	C.duckdb_data_chunk_set_size(chunk.data(), size)
}
