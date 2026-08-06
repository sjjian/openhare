package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

func VectorSize() IdxT {
	return C.duckdb_vector_size()
}

// CreateVector wraps duckdb_create_vector.
// The return value must be destroyed with DestroyVector.
func CreateVector(logicalType LogicalType, capacity IdxT) Vector {
	vec := C.duckdb_create_vector(logicalType.data(), capacity)
	return trackedVector(vec)
}

// DestroyVector wraps duckdb_destroy_vector.
func DestroyVector(vec *Vector) {
	if vec.Ptr == nil {
		return
	}
	releaseAllocation(vectorAllocation, vec.Ptr)
	data := vec.data()
	C.duckdb_destroy_vector(&data)
	vec.Ptr = nil
}

// VectorGetColumnType wraps duckdb_vector_get_column_type.
// The return value must be destroyed with DestroyLogicalType.
func VectorGetColumnType(vec Vector) LogicalType {
	logicalType := C.duckdb_vector_get_column_type(vec.data())
	return trackedLogicalType(logicalType)
}

func VectorGetData(vec Vector) unsafe.Pointer {
	return C.duckdb_vector_get_data(vec.data())
}

func VectorGetValidity(vec Vector) unsafe.Pointer {
	mask := C.duckdb_vector_get_validity(vec.data())
	return unsafe.Pointer(mask)
}

func VectorEnsureValidityWritable(vec Vector) {
	C.duckdb_vector_ensure_validity_writable(vec.data())
}

func VectorAssignStringElement(vec Vector, index IdxT, str string) {
	var cStr *C.char
	n := IdxT(len(str))
	if n > 0 {
		cStr = (*C.char)(unsafe.Pointer(unsafe.StringData(str)))
	}
	C.duckdb_vector_assign_string_element_len(vec.data(), index, cStr, n)
}

func VectorAssignStringElementLen(vec Vector, index IdxT, blob []byte) {
	var blobPtr *C.char
	if len(blob) > 0 {
		blobPtr = (*C.char)(unsafe.Pointer(&blob[0]))
	}
	C.duckdb_vector_assign_string_element_len(vec.data(), index, blobPtr, IdxT(len(blob)))
}

func UnsafeVectorAssignStringElementLen(vec Vector, index IdxT, blob []byte) {
	var blobPtr *C.char
	if len(blob) > 0 {
		blobPtr = (*C.char)(unsafe.Pointer(&blob[0]))
	}
	C.duckdb_unsafe_vector_assign_string_element_len(vec.data(), index, blobPtr, IdxT(len(blob)))
}

func ListVectorGetChild(vec Vector) Vector {
	child := C.duckdb_list_vector_get_child(vec.data())
	return Vector{
		Ptr: unsafe.Pointer(child),
	}
}

func ListVectorGetSize(vec Vector) IdxT {
	return C.duckdb_list_vector_get_size(vec.data())
}

func ListVectorSetSize(vec Vector, size IdxT) State {
	return C.duckdb_list_vector_set_size(vec.data(), size)
}

func ListVectorReserve(vec Vector, capacity IdxT) State {
	return C.duckdb_list_vector_reserve(vec.data(), capacity)
}

func StructVectorGetChild(vec Vector, index IdxT) Vector {
	child := C.duckdb_struct_vector_get_child(vec.data(), index)
	return Vector{
		Ptr: unsafe.Pointer(child),
	}
}

func ArrayVectorGetChild(vec Vector) Vector {
	child := C.duckdb_array_vector_get_child(vec.data())
	return Vector{
		Ptr: unsafe.Pointer(child),
	}
}

func SliceVector(vec Vector, sel SelectionVector, len IdxT) {
	C.duckdb_slice_vector(vec.data(), sel.data(), len)
}

func VectorCopySel(src Vector, dst Vector, sel SelectionVector, count IdxT, srcOffset IdxT, dstOffset IdxT) {
	C.duckdb_vector_copy_sel(src.data(), dst.data(), sel.data(), count, srcOffset, dstOffset)
}

func VectorReferenceValue(vec Vector, v Value) {
	C.duckdb_vector_reference_value(vec.data(), v.data())
}

func VectorReferenceVector(toVec Vector, fromVec Vector) {
	C.duckdb_vector_reference_vector(toVec.data(), fromVec.data())
}

func ValidityRowIsValid(maskPtr unsafe.Pointer, row IdxT) bool {
	mask := (*C.uint64_t)(maskPtr)
	return bool(C.duckdb_validity_row_is_valid(mask, row))
}

func ValiditySetRowValidity(maskPtr unsafe.Pointer, row IdxT, valid bool) {
	mask := (*C.uint64_t)(maskPtr)
	C.duckdb_validity_set_row_validity(mask, row, C.bool(valid))
}

func ValiditySetRowInvalid(maskPtr unsafe.Pointer, row IdxT) {
	mask := (*C.uint64_t)(maskPtr)
	C.duckdb_validity_set_row_invalid(mask, row)
}

func ValiditySetRowValid(maskPtr unsafe.Pointer, row IdxT) {
	mask := (*C.uint64_t)(maskPtr)
	C.duckdb_validity_set_row_valid(mask, row)
}
