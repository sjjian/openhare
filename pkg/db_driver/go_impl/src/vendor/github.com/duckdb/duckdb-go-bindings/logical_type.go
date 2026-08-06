package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// CreateLogicalType wraps duckdb_create_logical_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateLogicalType(t Type) LogicalType {
	logicalType := C.duckdb_create_logical_type(t)
	return trackedLogicalType(logicalType)
}

func LogicalTypeGetAlias(logicalType LogicalType) string {
	alias := C.duckdb_logical_type_get_alias(logicalType.data())
	defer Free(unsafe.Pointer(alias))
	return C.GoString(alias)
}

func LogicalTypeSetAlias(logicalType LogicalType, alias string) {
	cAlias := C.CString(alias)
	defer Free(unsafe.Pointer(cAlias))
	C.duckdb_logical_type_set_alias(logicalType.data(), cAlias)
}

// CreateListType wraps duckdb_create_list_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateListType(child LogicalType) LogicalType {
	logicalType := C.duckdb_create_list_type(child.data())
	return trackedLogicalType(logicalType)
}

// CreateArrayType wraps duckdb_create_array_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateArrayType(child LogicalType, size IdxT) LogicalType {
	logicalType := C.duckdb_create_array_type(child.data(), size)
	return trackedLogicalType(logicalType)
}

// CreateMapType wraps duckdb_create_map_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateMapType(key LogicalType, value LogicalType) LogicalType {
	logicalType := C.duckdb_create_map_type(key.data(), value.data())
	return trackedLogicalType(logicalType)
}

// CreateUnionType wraps duckdb_create_union_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateUnionType(types []LogicalType, names []string) LogicalType {
	typesPtr := allocLogicalTypes(types)
	defer Free(unsafe.Pointer(typesPtr))

	namesAlloc := allocNames(names)
	defer freeNameList(namesAlloc)
	count := IdxT(len(types))

	// Create the UNION type.
	logicalType := C.duckdb_create_union_type(typesPtr, namesAlloc.arr, count)

	return trackedLogicalType(logicalType)
}

// CreateStructType wraps duckdb_create_struct_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateStructType(types []LogicalType, names []string) LogicalType {
	typesPtr := allocLogicalTypes(types)
	defer Free(unsafe.Pointer(typesPtr))

	namesAlloc := allocNames(names)
	defer freeNameList(namesAlloc)
	count := IdxT(len(types))

	// Create the STRUCT type.
	logicalType := C.duckdb_create_struct_type(typesPtr, namesAlloc.arr, count)

	return trackedLogicalType(logicalType)
}

// CreateEnumType wraps duckdb_create_enum_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateEnumType(names []string) LogicalType {
	namesAlloc := allocNames(names)
	defer freeNameList(namesAlloc)
	count := IdxT(len(names))

	// Create the ENUM type.
	logicalType := C.duckdb_create_enum_type(namesAlloc.arr, count)

	return trackedLogicalType(logicalType)
}

// CreateDecimalType wraps duckdb_create_decimal_type.
// The return value must be destroyed with DestroyLogicalType.
func CreateDecimalType(width uint8, scale uint8) LogicalType {
	logicalType := C.duckdb_create_decimal_type(C.uint8_t(width), C.uint8_t(scale))
	return trackedLogicalType(logicalType)
}

func GetTypeId(logicalType LogicalType) Type {
	return C.duckdb_get_type_id(logicalType.data())
}

func DecimalWidth(logicalType LogicalType) uint8 {
	width := C.duckdb_decimal_width(logicalType.data())
	return uint8(width)
}

func DecimalScale(logicalType LogicalType) uint8 {
	scale := C.duckdb_decimal_scale(logicalType.data())
	return uint8(scale)
}

func DecimalInternalType(logicalType LogicalType) Type {
	return C.duckdb_decimal_internal_type(logicalType.data())
}

func EnumInternalType(logicalType LogicalType) Type {
	return C.duckdb_enum_internal_type(logicalType.data())
}

func EnumDictionarySize(logicalType LogicalType) uint32 {
	size := C.duckdb_enum_dictionary_size(logicalType.data())
	return uint32(size)
}

func EnumDictionaryValue(logicalType LogicalType, index IdxT) string {
	str := C.duckdb_enum_dictionary_value(logicalType.data(), index)
	defer Free(unsafe.Pointer(str))
	return C.GoString(str)
}

// ListTypeChildType wraps duckdb_list_type_child_type.
// The return value must be destroyed with DestroyLogicalType.
func ListTypeChildType(logicalType LogicalType) LogicalType {
	child := C.duckdb_list_type_child_type(logicalType.data())
	return trackedLogicalType(child)
}

// ArrayTypeChildType wraps duckdb_array_type_child_type.
// The return value must be destroyed with DestroyLogicalType.
func ArrayTypeChildType(logicalType LogicalType) LogicalType {
	child := C.duckdb_array_type_child_type(logicalType.data())
	return trackedLogicalType(child)
}

func ArrayTypeArraySize(logicalType LogicalType) IdxT {
	return C.duckdb_array_type_array_size(logicalType.data())
}

// MapTypeKeyType wraps duckdb_map_type_key_type.
// The return value must be destroyed with DestroyLogicalType.
func MapTypeKeyType(logicalType LogicalType) LogicalType {
	key := C.duckdb_map_type_key_type(logicalType.data())
	return trackedLogicalType(key)
}

// MapTypeValueType wraps duckdb_map_type_value_type.
// The return value must be destroyed with DestroyLogicalType.
func MapTypeValueType(logicalType LogicalType) LogicalType {
	value := C.duckdb_map_type_value_type(logicalType.data())
	return trackedLogicalType(value)
}

func StructTypeChildCount(logicalType LogicalType) IdxT {
	return C.duckdb_struct_type_child_count(logicalType.data())
}

func StructTypeChildName(logicalType LogicalType, index IdxT) string {
	cName := C.duckdb_struct_type_child_name(logicalType.data(), index)
	defer Free(unsafe.Pointer(cName))
	return C.GoString(cName)
}

// StructTypeChildType wraps duckdb_struct_type_child_type.
// The return value must be destroyed with DestroyLogicalType.
func StructTypeChildType(logicalType LogicalType, index IdxT) LogicalType {
	child := C.duckdb_struct_type_child_type(logicalType.data(), index)
	return trackedLogicalType(child)
}

func UnionTypeMemberCount(logicalType LogicalType) IdxT {
	return C.duckdb_union_type_member_count(logicalType.data())
}

func UnionTypeMemberName(logicalType LogicalType, index IdxT) string {
	cStr := C.duckdb_union_type_member_name(logicalType.data(), index)
	defer Free(unsafe.Pointer(cStr))
	return C.GoString(cStr)
}

// UnionTypeMemberType wraps duckdb_union_type_member_type.
// The return value must be destroyed with DestroyLogicalType.
func UnionTypeMemberType(logicalType LogicalType, index IdxT) LogicalType {
	t := C.duckdb_union_type_member_type(logicalType.data(), index)
	return trackedLogicalType(t)
}

func GeometryTypeGetCRS(logicalType LogicalType) string {
	crs := C.duckdb_geometry_type_get_crs(logicalType.data())
	if crs == nil {
		return ""
	}
	defer Free(unsafe.Pointer(crs))
	return C.GoString(crs)
}

// DestroyLogicalType wraps duckdb_destroy_logical_type.
func DestroyLogicalType(logicalType *LogicalType) {
	if logicalType.Ptr == nil {
		return
	}
	releaseAllocation(logicalTypeAllocation, logicalType.Ptr)
	data := logicalType.data()
	C.duckdb_destroy_logical_type(&data)
	logicalType.Ptr = nil
}

func RegisterLogicalType(conn Connection, logicalType LogicalType, info CreateTypeInfo) State {
	return C.duckdb_register_logical_type(conn.data(), logicalType.data(), info.data())
}
