package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

// DestroyExpression wraps duckdb_destroy_expression.
func DestroyExpression(expr *Expression) {
	if expr.Ptr == nil {
		return
	}
	releaseAllocation(expressionAllocation, expr.Ptr)
	data := expr.data()
	C.duckdb_destroy_expression(&data)
	expr.Ptr = nil
}

// ExpressionReturnType wraps duckdb_expression_return_type.
// The return value must be destroyed with DestroyLogicalType.
func ExpressionReturnType(expr Expression) LogicalType {
	logicalType := C.duckdb_expression_return_type(expr.data())
	return trackedLogicalType(logicalType)
}

func ExpressionIsFoldable(expr Expression) bool {
	return bool(C.duckdb_expression_is_foldable(expr.data()))
}

// ExpressionFold wraps duckdb_expression_fold.
// outValue must be destroyed with DestroyValue.
// The return value must be destroyed with DestroyErrorData.
func ExpressionFold(ctx ClientContext, expr Expression, outValue *Value) ErrorData {
	var value C.duckdb_value
	errorData := C.duckdb_expression_fold(ctx.data(), expr.data(), &value)
	*outValue = trackedValue(value)
	return trackedErrorData(errorData)
}
