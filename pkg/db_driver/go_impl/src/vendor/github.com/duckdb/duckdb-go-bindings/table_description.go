package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// TableDescriptionCreate wraps duckdb_table_description_create.
// outDesc must be destroyed with TableDescriptionDestroy.
func TableDescriptionCreate(conn Connection, schema string, table string, outDesc *TableDescription) State {
	cSchema := C.CString(schema)
	defer Free(unsafe.Pointer(cSchema))
	cTable := C.CString(table)
	defer Free(unsafe.Pointer(cTable))

	var description C.duckdb_table_description
	state := C.duckdb_table_description_create(conn.data(), cSchema, cTable, &description)
	*outDesc = trackedTableDescription(description)
	return state
}

// TableDescriptionCreateExt wraps duckdb_table_description_create_ext.
// outDesc must be destroyed with TableDescriptionDestroy.
func TableDescriptionCreateExt(conn Connection, catalog string, schema string, table string, outDesc *TableDescription) State {
	cCatalog := C.CString(catalog)
	defer Free(unsafe.Pointer(cCatalog))
	cSchema := C.CString(schema)
	defer Free(unsafe.Pointer(cSchema))
	cTable := C.CString(table)
	defer Free(unsafe.Pointer(cTable))

	var description C.duckdb_table_description
	state := C.duckdb_table_description_create_ext(conn.data(), cCatalog, cSchema, cTable, &description)
	*outDesc = trackedTableDescription(description)
	return state
}

// TableDescriptionDestroy wraps duckdb_table_description_destroy.
func TableDescriptionDestroy(desc *TableDescription) {
	if desc.Ptr == nil {
		return
	}
	releaseAllocation(tableDescriptionAllocation, desc.Ptr)
	data := desc.data()
	C.duckdb_table_description_destroy(&data)
	desc.Ptr = nil
}

func TableDescriptionError(desc TableDescription) string {
	err := C.duckdb_table_description_error(desc.data())
	return C.GoString(err)
}

func ColumnHasDefault(desc TableDescription, index IdxT, outBool *bool) State {
	var b C.bool
	state := C.duckdb_column_has_default(desc.data(), index, &b)
	*outBool = bool(b)
	return state
}

func TableDescriptionGetColumnCount(desc TableDescription) IdxT {
	return C.duckdb_table_description_get_column_count(desc.data())
}

func TableDescriptionGetColumnName(desc TableDescription, index IdxT) string {
	cName := C.duckdb_table_description_get_column_name(desc.data(), index)
	defer Free(unsafe.Pointer(cName))
	return C.GoString(cName)
}

// TableDescriptionGetColumnType wraps duckdb_table_description_get_column_type.
// The return value must be destroyed with DestroyLogicalType.
func TableDescriptionGetColumnType(desc TableDescription, index IdxT) LogicalType {
	logicalType := C.duckdb_table_description_get_column_type(desc.data(), index)
	return trackedLogicalType(logicalType)
}
