//go:build duckdb_arrow

package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <duckdb_go_bindings.h>

#ifndef ARROW_C_DATA_INTERFACE
#define ARROW_C_DATA_INTERFACE

#include <stdint.h>
#define ARROW_FLAG_DICTIONARY_ORDERED 1
#define ARROW_FLAG_NULLABLE 2
#define ARROW_FLAG_MAP_KEYS_SORTED 4

struct ArrowSchema {
  // Array type description
  const char* format;
  const char* name;
  const char* metadata;
  int64_t flags;
  int64_t n_children;
  struct ArrowSchema** children;
  struct ArrowSchema* dictionary;

  // Release callback
  void (*release)(struct ArrowSchema*);
  // Opaque producer-specific data
  void* private_data;
};

struct ArrowArray {
  // Array data description
  int64_t length;
  int64_t null_count;
  int64_t offset;
  int64_t n_buffers;
  int64_t n_children;
  const void** buffers;
  struct ArrowArray** children;
  struct ArrowArray* dictionary;

  // Release callback
  void (*release)(struct ArrowArray*);
  // Opaque producer-specific data
  void* private_data;
};

struct ArrowArrayStream {
	void (*get_schema)(struct ArrowArrayStream*);
	void (*get_next)(struct ArrowArrayStream*);
	void (*get_last_error)(struct ArrowArrayStream*);
	void (*release)(struct ArrowArrayStream*);
	void* private_data;
};

#endif  // ARROW_C_DATA_INTERFACE
*/
import "C"

import (
	"unsafe"

	"github.com/apache/arrow-go/v18/arrow"
	"github.com/apache/arrow-go/v18/arrow/cdata"
)

// NewArrowSchema creates a new ArrowSchema from an array of DuckDB logical types and column names.
// The returned ErrorData must be checked for errors and destroyed with DestroyErrorData.
func NewArrowSchema(options ArrowOptions, types []LogicalType, names []string) (*arrow.Schema, ErrorData) {
	cTypes := allocLogicalTypes(types)
	defer Free(unsafe.Pointer(cTypes))

	cNames := allocNames(names)
	defer freeNameList(cNames)

	arr := C.calloc(1, C.sizeof_struct_ArrowSchema)
	defer func() {
		cdata.ReleaseCArrowSchema((*cdata.CArrowSchema)(arr))
		C.free(arr)
	}()

	ed := C.duckdb_to_arrow_schema(options.data(), cTypes, cNames.arr, C.idx_t(len(names)), (*C.struct_ArrowSchema)(arr))
	errData := trackedErrorData(ed)
	if ErrorDataHasError(errData) {
		return nil, errData
	}

	schema, err := cdata.ImportCArrowSchema((*cdata.CArrowSchema)(arr))
	if err != nil {
		return nil, CreateErrorData(ErrorTypeUnknownType, err.Error())
	}
	return schema, errData
}

// DataChunkToArrowArray converts a DuckDB DataChunk to an Arrow RecordBatch using the provided ArrowOptions and schema.
// The returned ErrorData must be checked for errors and destroyed with DestroyErrorData.
func DataChunkToArrowArray(options ArrowOptions, schema *arrow.Schema, chunk DataChunk) (arrow.RecordBatch, ErrorData) {
	arr := C.calloc(1, C.sizeof_struct_ArrowArray)
	defer func() {
		cdata.ReleaseCArrowArray((*cdata.CArrowArray)(arr))
		C.free(arr)
	}()

	ed := C.duckdb_data_chunk_to_arrow(options.data(), chunk.data(), (*C.struct_ArrowArray)(arr))
	errData := trackedErrorData(ed)
	if ErrorDataHasError(errData) {
		return nil, errData
	}
	rec, err := cdata.ImportCRecordBatchWithSchema((*cdata.CArrowArray)(arr), schema)
	if err != nil {
		return nil, CreateErrorData(ErrorTypeUnknownType, err.Error())
	}
	return rec, errData
}

// SchemaFromArrow converts an Arrow Schema to a DuckDB ArrowConvertedSchema using the provided Connection.
// The returned ArrowConvertedSchema must be destroyed with DestroyArrowConvertedSchema.
// The returned ErrorData must be checked for errors and destroyed with DestroyErrorData.
func SchemaFromArrow(conn Connection, schema *arrow.Schema) (ArrowConvertedSchema, ErrorData) {
	arr := C.calloc(1, C.sizeof_struct_ArrowSchema)
	cdata.ExportArrowSchema(schema, (*cdata.CArrowSchema)(arr))
	defer func() {
		cdata.ReleaseCArrowSchema((*cdata.CArrowSchema)(arr))
		C.free(arr)
	}()

	var convertedSchema C.duckdb_arrow_converted_schema
	ed := C.duckdb_schema_from_arrow(conn.data(), (*C.struct_ArrowSchema)(arr), &convertedSchema)
	errData := trackedErrorData(ed)
	return trackedArrowConvertedSchema(convertedSchema), errData
}

// DataChunkFromArrow converts an Arrow RecordBatch to a DuckDB DataChunk using the provided Connection and ArrowConvertedSchema.
// The returned DataChunk must be destroyed with DestroyDataChunk.
// The returned ErrorData must be checked for errors and destroyed with DestroyErrorData.
func DataChunkFromArrow(conn Connection, rec arrow.RecordBatch, schema ArrowConvertedSchema) (DataChunk, ErrorData) {
	arr := C.calloc(1, C.sizeof_struct_ArrowArray)
	defer func() {
		cdata.ReleaseCArrowArray((*cdata.CArrowArray)(arr))
		C.free(arr)
	}()
	arrs := C.calloc(1, C.sizeof_struct_ArrowSchema)
	defer func() {
		cdata.ReleaseCArrowSchema((*cdata.CArrowSchema)(arrs))
		C.free(arrs)
	}()
	cdata.ExportArrowRecordBatch(rec, (*cdata.CArrowArray)(arr), (*cdata.CArrowSchema)(arrs))

	var chunk C.duckdb_data_chunk
	ed := C.duckdb_data_chunk_from_arrow(conn.data(), (*C.struct_ArrowArray)(arr), schema.data(), &chunk)
	errData := trackedErrorData(ed)
	return trackedDataChunk(chunk), errData
}

// DestroyArrowConvertedSchema wraps duckdb_destroy_arrow_converted_schema.
func DestroyArrowConvertedSchema(schema *ArrowConvertedSchema) {
	if schema.Ptr == nil {
		return
	}
	releaseAllocation(arrowConvertedSchemaAllocation, schema.Ptr)
	data := schema.data()
	C.duckdb_destroy_arrow_converted_schema(&data)
	schema.Ptr = nil
}

// Deprecated: use new Arrow interface functions instead. (NewArrowSchema, DataChunkToArrowArray, SchemaFromArrow, DataChunkFromArrow, DestroyArrowConvertedSchema)
func QueryArrowSchema(arrow Arrow, outSchema *ArrowSchema) State {
	return C.duckdb_query_arrow_schema(arrow.data(), (*C.duckdb_arrow_schema)(outSchema.Ptr))
}

// Deprecated: use new Arrow interface functions instead. (NewArrowSchema, DataChunkToArrowArray, SchemaFromArrow, DataChunkFromArrow, DestroyArrowConvertedSchema)
func QueryArrowArray(arrow Arrow, outArray *ArrowArray) State {
	return C.duckdb_query_arrow_array(arrow.data(), (*C.duckdb_arrow_array)(outArray.Ptr))
}

// Deprecated: use new Arrow interface functions instead. (NewArrowSchema, DataChunkToArrowArray, SchemaFromArrow, DataChunkFromArrow, DestroyArrowConvertedSchema)
func ArrowRowCount(arrow Arrow) IdxT {
	return C.duckdb_arrow_row_count(arrow.data())
}

// Deprecated: use new Arrow interface functions instead. (NewArrowSchema, DataChunkToArrowArray, SchemaFromArrow, DataChunkFromArrow, DestroyArrowConvertedSchema)
func QueryArrowError(arrow Arrow) string {
	err := C.duckdb_query_arrow_error(arrow.data())
	return C.GoString(err)
}

// Deprecated: use new Arrow interface functions instead. (NewArrowSchema, DataChunkToArrowArray, SchemaFromArrow, DataChunkFromArrow, DestroyArrowConvertedSchema)
// DestroyArrow wraps duckdb_destroy_arrow.
func DestroyArrow(arrow *Arrow) {
	if arrow.Ptr == nil {
		return
	}
	releaseAllocation(arrowAllocation, arrow.Ptr)
	data := arrow.data()
	C.duckdb_destroy_arrow(&data)
	arrow.Ptr = nil
}

// Deprecated: use new Arrow interface functions instead. (NewArrowSchema, DataChunkToArrowArray, SchemaFromArrow, DataChunkFromArrow, DestroyArrowConvertedSchema)
// ExecutePreparedArrow wraps duckdb_execute_prepared_arrow.
// outArrow must be destroyed with DestroyArrow.
func ExecutePreparedArrow(preparedStmt PreparedStatement, outArrow *Arrow) State {
	var arrow C.duckdb_arrow
	state := C.duckdb_execute_prepared_arrow(preparedStmt.data(), &arrow)
	*outArrow = trackedArrow(arrow)
	return state
}

func ArrowScan(conn Connection, table string, stream ArrowStream) State {
	cTable := C.CString(table)
	defer Free(unsafe.Pointer(cTable))
	return C.duckdb_arrow_scan(conn.data(), cTable, stream.data())
}
