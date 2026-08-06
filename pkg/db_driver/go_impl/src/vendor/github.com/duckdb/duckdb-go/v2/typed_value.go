package duckdb

import (
	"fmt"
	"math"
	"reflect"
)

// TypedValue wraps a Go value with an explicit DuckDB type for parameter
// binding. Use it when DuckDB cannot infer the parameter type from SQL alone,
// or when the default Go-type inference would choose a different DuckDB type.
//
// TypedValue is intentionally a narrow binding hint rather than a general
// conversion API. It selects the DuckDB parameter type while preserving the
// usual Go value semantics for that type. supportsTypedValue is the
// authoritative list of accepted target types; types that need extra logical
// type metadata (DECIMAL, ENUM, LIST, ARRAY, STRUCT, MAP, UNION) are rejected.
//
// If the type is TYPE_SQLNULL, the value is ignored without calling
// driver.Valuer and the parameter is bound as SQL NULL. A nil value, including
// a nil *TypedValue argument, also binds SQL NULL.
//
// Coercions are intentionally narrow: TYPE_BOOLEAN accepts only bool,
// TYPE_VARCHAR accepts only string. Integer types accept Go integer values in
// range. Floating-point types accept only Go float32 or float64 values.
// TYPE_FLOAT rejects finite float64 values that would overflow or underflow to
// zero as float32. NaN and infinities are preserved.
type TypedValue struct {
	value any
	typ   Type
}

// Typed returns a TypedValue for explicit DuckDB parameter binding.
// Validation is deferred until the value is bound.
func Typed(value any, typ Type) TypedValue {
	return TypedValue{
		value: value,
		typ:   typ,
	}
}

func coerceTypedValue(t Type, v any) (any, error) {
	if !supportsTypedValue(t) {
		return nil, unsupportedTypeError(typeName(t))
	}

	if t == TYPE_SQLNULL || isNil(v) {
		return nil, nil
	}

	switch t {
	case TYPE_BOOLEAN:
		if _, ok := v.(bool); ok {
			return v, nil
		}
		return nil, typedValueCastError(t, v)
	case TYPE_TINYINT:
		i, err := coerceTypedSignedInteger(t, v, math.MinInt8, math.MaxInt8)
		return typedCoercionResult(int8(i), err)
	case TYPE_SMALLINT:
		i, err := coerceTypedSignedInteger(t, v, math.MinInt16, math.MaxInt16)
		return typedCoercionResult(int16(i), err)
	case TYPE_INTEGER:
		i, err := coerceTypedSignedInteger(t, v, math.MinInt32, math.MaxInt32)
		return typedCoercionResult(int32(i), err)
	case TYPE_BIGINT:
		i, err := coerceTypedSignedInteger(t, v, math.MinInt64, math.MaxInt64)
		return typedCoercionResult(i, err)
	case TYPE_UTINYINT:
		i, err := coerceTypedUnsignedInteger(t, v, math.MaxUint8)
		return typedCoercionResult(uint8(i), err)
	case TYPE_USMALLINT:
		i, err := coerceTypedUnsignedInteger(t, v, math.MaxUint16)
		return typedCoercionResult(uint16(i), err)
	case TYPE_UINTEGER:
		i, err := coerceTypedUnsignedInteger(t, v, math.MaxUint32)
		return typedCoercionResult(uint32(i), err)
	case TYPE_UBIGINT:
		i, err := coerceTypedUnsignedInteger(t, v, math.MaxUint64)
		return typedCoercionResult(i, err)
	case TYPE_FLOAT:
		return coerceTypedFloat32(t, v)
	case TYPE_DOUBLE:
		return coerceTypedFloat64(t, v)
	case TYPE_VARCHAR:
		if _, ok := v.(string); ok {
			return v, nil
		}
		return nil, typedValueCastError(t, v)
	case TYPE_TIMESTAMP, TYPE_TIMESTAMP_TZ, TYPE_TIMESTAMP_S, TYPE_TIMESTAMP_MS, TYPE_TIMESTAMP_NS,
		TYPE_DATE, TYPE_TIME, TYPE_TIME_TZ, TYPE_INTERVAL:
		return v, nil
	}
	return nil, fmt.Errorf("duckdb: internal error: missing typed value coercion for %s", typeName(t))
}

func supportsTypedValue(t Type) bool {
	switch t {
	case TYPE_BOOLEAN, TYPE_TINYINT, TYPE_SMALLINT, TYPE_INTEGER, TYPE_BIGINT,
		TYPE_UTINYINT, TYPE_USMALLINT, TYPE_UINTEGER, TYPE_UBIGINT,
		TYPE_FLOAT, TYPE_DOUBLE, TYPE_VARCHAR,
		TYPE_TIMESTAMP, TYPE_TIMESTAMP_TZ, TYPE_TIMESTAMP_S, TYPE_TIMESTAMP_MS, TYPE_TIMESTAMP_NS,
		TYPE_DATE, TYPE_TIME, TYPE_TIME_TZ, TYPE_INTERVAL,
		TYPE_SQLNULL:
		return true
	default:
		return false
	}
}

func typedCoercionResult[T any](v T, err error) (any, error) {
	if err != nil {
		return nil, err
	}
	return v, nil
}

func coerceTypedSignedInteger(t Type, v any, min, max int64) (int64, error) {
	value := reflect.ValueOf(v)
	switch value.Kind() {
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		i := value.Int()
		if i < min || i > max {
			return 0, typedValueConversionError(t, i)
		}
		return i, nil
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		u := value.Uint()
		if u > uint64(max) {
			return 0, typedValueConversionError(t, u)
		}
		return int64(u), nil
	default:
		return 0, typedValueCastError(t, v)
	}
}

func coerceTypedUnsignedInteger(t Type, v any, max uint64) (uint64, error) {
	value := reflect.ValueOf(v)
	switch value.Kind() {
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		i := value.Int()
		if i < 0 || uint64(i) > max {
			return 0, typedValueConversionError(t, i)
		}
		return uint64(i), nil
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		u := value.Uint()
		if u > max {
			return 0, typedValueConversionError(t, u)
		}
		return u, nil
	default:
		return 0, typedValueCastError(t, v)
	}
}

func coerceTypedFloat32(t Type, v any) (any, error) {
	switch vv := v.(type) {
	case float32:
		return vv, nil
	case float64:
		// Avoid silently converting finite float64 values to float32 infinities or zero.
		if !math.IsInf(vv, 0) && math.Abs(vv) > math.MaxFloat32 {
			return nil, typedValueConversionError(t, vv)
		}
		if vv != 0 && float32(vv) == 0 {
			return nil, typedValueConversionError(t, vv)
		}
		return float32(vv), nil
	default:
		return nil, typedValueCastError(t, v)
	}
}

func coerceTypedFloat64(t Type, v any) (any, error) {
	switch vv := v.(type) {
	case float32:
		return float64(vv), nil
	case float64:
		return vv, nil
	default:
		return nil, typedValueCastError(t, v)
	}
}

func typedValueCastError(t Type, v any) error {
	return castErrorForValue(v, typeName(t))
}

func typedValueConversionError(t Type, v any) error {
	return fmt.Errorf("%s: cannot convert %v to %s", convertErrMsg, v, typeName(t))
}
