//go:build duckdb_arrow

package arrowmapping

import (
	bindings "github.com/duckdb/duckdb-go-bindings"
)

// Pointers.

type (
	Arrow                = bindings.Arrow
	ArrowStream          = bindings.ArrowStream
	ArrowSchema          = bindings.ArrowSchema
	ArrowConvertedSchema = bindings.ArrowConvertedSchema
	ArrowArray           = bindings.ArrowArray
	ArrowOptions         = bindings.ArrowOptions
)

// Functions.

var (
	ConnectionGetArrowOptions   = bindings.ConnectionGetArrowOptions
	DestroyArrowOptions         = bindings.DestroyArrowOptions
	ResultGetArrowOptions       = bindings.ResultGetArrowOptions
	DestroyArrowConvertedSchema = bindings.DestroyArrowConvertedSchema
	QueryArrowSchema            = bindings.QueryArrowSchema
	QueryArrowArray             = bindings.QueryArrowArray
	ArrowRowCount               = bindings.ArrowRowCount
	QueryArrowError             = bindings.QueryArrowError
	DestroyArrow                = bindings.DestroyArrow
	ExecutePreparedArrow        = bindings.ExecutePreparedArrow
	ArrowScan                   = bindings.ArrowScan

	// new arrow C API functions
	NewArrowSchema        = bindings.NewArrowSchema
	DataChunkToArrowArray = bindings.DataChunkToArrowArray
	SchemaFromArrow       = bindings.SchemaFromArrow
	DataChunkFromArrow    = bindings.DataChunkFromArrow
)
