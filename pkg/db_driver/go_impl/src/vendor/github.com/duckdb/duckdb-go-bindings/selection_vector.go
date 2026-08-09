package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

// CreateSelectionVector wraps duckdb_create_selection_vector.
// The return value must be destroyed with DestroySelectionVector.
func CreateSelectionVector(size IdxT) SelectionVector {
	sel := C.duckdb_create_selection_vector(size)
	return trackedSelectionVector(sel)
}

// DestroySelectionVector wraps duckdb_destroy_selection_vector.
func DestroySelectionVector(sel *SelectionVector) {
	if sel.Ptr == nil {
		return
	}
	releaseAllocation(selectionVectorAllocation, sel.Ptr)
	C.duckdb_destroy_selection_vector(sel.data())
	sel.Ptr = nil
}

func SelectionVectorGetDataPtr(sel SelectionVector) *SelT {
	return C.duckdb_selection_vector_get_data_ptr(sel.data())
}
