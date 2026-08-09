package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

// DestroyValue wraps duckdb_destroy_value.
func DestroyValue(v *Value) {
	if v.Ptr == nil {
		return
	}
	releaseAllocation(valueAllocation, v.Ptr)
	data := v.data()
	C.duckdb_destroy_value(&data)
	v.Ptr = nil
}

// CreateVarchar wraps duckdb_create_varchar_length using the full string length.
// The return value must be destroyed with DestroyValue.
func CreateVarchar(str string) Value {
	return CreateVarcharLength(str, IdxT(len(str)))
}

// CreateVarcharLength wraps duckdb_create_varchar_length.
// The return value must be destroyed with DestroyValue.
func CreateVarcharLength(str string, length IdxT) Value {
	var cStr *C.char
	if length > 0 {
		cStr = (*C.char)(unsafe.Pointer(unsafe.StringData(str)))
	}
	v := C.duckdb_create_varchar_length(cStr, length)
	return trackedValue(v)
}

func ValidUtf8Check(blob []byte) ErrorData {
	var blobPtr *C.char
	if len(blob) > 0 {
		blobPtr = (*C.char)(unsafe.Pointer(&blob[0]))
	}
	errorData := C.duckdb_valid_utf8_check(blobPtr, IdxT(len(blob)))
	return trackedErrorData(errorData)
}

// CreateBool wraps duckdb_create_bool.
// The return value must be destroyed with DestroyValue.
func CreateBool(val bool) Value {
	v := C.duckdb_create_bool(C.bool(val))
	return trackedValue(v)
}

// CreateInt8 wraps duckdb_create_int8.
// The return value must be destroyed with DestroyValue.
func CreateInt8(val int8) Value {
	v := C.duckdb_create_int8(C.int8_t(val))
	return trackedValue(v)
}

// CreateUInt8 wraps duckdb_create_uint8.
// The return value must be destroyed with DestroyValue.
func CreateUInt8(val uint8) Value {
	v := C.duckdb_create_uint8(C.uint8_t(val))
	return trackedValue(v)
}

// CreateInt16 wraps duckdb_create_int16.
// The return value must be destroyed with DestroyValue.
func CreateInt16(val int16) Value {
	v := C.duckdb_create_int16(C.int16_t(val))
	return trackedValue(v)
}

// CreateUInt16 wraps duckdb_create_uint16.
// The return value must be destroyed with DestroyValue.
func CreateUInt16(val uint16) Value {
	v := C.duckdb_create_uint16(C.uint16_t(val))
	return trackedValue(v)
}

// CreateInt32 wraps duckdb_create_int32.
// The return value must be destroyed with DestroyValue.
func CreateInt32(val int32) Value {
	v := C.duckdb_create_int32(C.int32_t(val))
	return trackedValue(v)
}

// CreateUInt32 wraps duckdb_create_uint32.
// The return value must be destroyed with DestroyValue.
func CreateUInt32(val uint32) Value {
	v := C.duckdb_create_uint32(C.uint32_t(val))
	return trackedValue(v)
}

// CreateUInt64 wraps duckdb_create_uint64.
// The return value must be destroyed with DestroyValue.
func CreateUInt64(val uint64) Value {
	v := C.duckdb_create_uint64(C.uint64_t(val))
	return trackedValue(v)
}

// CreateInt64 wraps duckdb_create_int64.
// The return value must be destroyed with DestroyValue.
func CreateInt64(val int64) Value {
	v := C.duckdb_create_int64(C.int64_t(val))
	return trackedValue(v)
}

// CreateHugeInt wraps duckdb_create_hugeint.
// The return value must be destroyed with DestroyValue.
func CreateHugeInt(val HugeInt) Value {
	v := C.duckdb_create_hugeint(val)
	return trackedValue(v)
}

// CreateUHugeInt wraps duckdb_create_uhugeint.
// The return value must be destroyed with DestroyValue.
func CreateUHugeInt(val UHugeInt) Value {
	v := C.duckdb_create_uhugeint(val)
	return trackedValue(v)
}

// CreateBigNum wraps duckdb_create_bignum.
// The return value must be destroyed with DestroyValue.
func CreateBigNum(val BigNum) Value {
	v := C.duckdb_create_bignum(val)
	return trackedValue(v)
}

// CreateDecimal wraps duckdb_create_decimal.
// The return value must be destroyed with DestroyValue.
func CreateDecimal(val Decimal) Value {
	v := C.duckdb_create_decimal(val)
	return trackedValue(v)
}

// CreateFloat wraps duckdb_create_float.
// The return value must be destroyed with DestroyValue.
func CreateFloat(val float32) Value {
	v := C.duckdb_create_float(C.float(val))
	return trackedValue(v)
}

// CreateDouble wraps duckdb_create_double.
// The return value must be destroyed with DestroyValue.
func CreateDouble(val float64) Value {
	v := C.duckdb_create_double(C.double(val))
	return trackedValue(v)
}

// CreateDate wraps duckdb_create_date.
// The return value must be destroyed with DestroyValue.
func CreateDate(val Date) Value {
	v := C.duckdb_create_date(val)
	return trackedValue(v)
}

// CreateTime wraps duckdb_create_time.
// The return value must be destroyed with DestroyValue.
func CreateTime(val Time) Value {
	v := C.duckdb_create_time(val)
	return trackedValue(v)
}

// CreateTimeNS wraps duckdb_create_time_ns.
// The return value must be destroyed with DestroyValue.
func CreateTimeNS(val TimeNS) Value {
	v := C.duckdb_create_time_ns(val)
	return trackedValue(v)
}

// CreateTimeTZValue wraps duckdb_create_time_tz_value.
// The return value must be destroyed with DestroyValue.
func CreateTimeTZValue(timeTZ TimeTZ) Value {
	v := C.duckdb_create_time_tz_value(timeTZ)
	return trackedValue(v)
}

// CreateTimestamp wraps duckdb_create_timestamp.
// The return value must be destroyed with DestroyValue.
func CreateTimestamp(val Timestamp) Value {
	v := C.duckdb_create_timestamp(val)
	return trackedValue(v)
}

// CreateTimestampTZ wraps duckdb_create_timestamp_tz.
// The return value must be destroyed with DestroyValue.
func CreateTimestampTZ(val Timestamp) Value {
	v := C.duckdb_create_timestamp_tz(val)
	return trackedValue(v)
}

// CreateTimestampS wraps duckdb_create_timestamp_s.
// The return value must be destroyed with DestroyValue.
func CreateTimestampS(val TimestampS) Value {
	v := C.duckdb_create_timestamp_s(val)
	return trackedValue(v)
}

// CreateTimestampMS wraps duckdb_create_timestamp_ms.
// The return value must be destroyed with DestroyValue.
func CreateTimestampMS(val TimestampMS) Value {
	v := C.duckdb_create_timestamp_ms(val)
	return trackedValue(v)
}

// CreateTimestampNS wraps duckdb_create_timestamp_ns.
// The return value must be destroyed with DestroyValue.
func CreateTimestampNS(val TimestampNS) Value {
	v := C.duckdb_create_timestamp_ns(val)
	return trackedValue(v)
}

// CreateInterval wraps duckdb_create_interval.
// The return value must be destroyed with DestroyValue.
func CreateInterval(val Interval) Value {
	v := C.duckdb_create_interval(val)
	return trackedValue(v)
}

// CreateBlob wraps duckdb_create_blob.
// The return value must be destroyed with DestroyValue.
func CreateBlob(val []byte) Value {
	var data *C.uint8_t
	if len(val) > 0 {
		data = (*C.uint8_t)(unsafe.Pointer(&val[0]))
	}

	v := C.duckdb_create_blob(data, IdxT(len(val)))
	return trackedValue(v)
}

// CreateBit wraps duckdb_create_bit.
// The return value must be destroyed with DestroyValue.
func CreateBit(val Bit) Value {
	v := C.duckdb_create_bit(val)
	return trackedValue(v)
}

// CreateUUID wraps duckdb_create_uuid.
// The return value must be destroyed with DestroyValue.
func CreateUUID(val UHugeInt) Value {
	v := C.duckdb_create_uuid(val)
	return trackedValue(v)
}

func GetBool(v Value) bool {
	val := C.duckdb_get_bool(v.data())
	return bool(val)
}

func GetInt8(v Value) int8 {
	val := C.duckdb_get_int8(v.data())
	return int8(val)
}

func GetUInt8(v Value) uint8 {
	val := C.duckdb_get_uint8(v.data())
	return uint8(val)
}

func GetInt16(v Value) int16 {
	val := C.duckdb_get_int16(v.data())
	return int16(val)
}

func GetUInt16(v Value) uint16 {
	val := C.duckdb_get_uint16(v.data())
	return uint16(val)
}

func GetInt32(v Value) int32 {
	val := C.duckdb_get_int32(v.data())
	return int32(val)
}

func GetUInt32(v Value) uint32 {
	val := C.duckdb_get_uint32(v.data())
	return uint32(val)
}

func GetInt64(v Value) int64 {
	val := C.duckdb_get_int64(v.data())
	return int64(val)
}

func GetUInt64(v Value) uint64 {
	val := C.duckdb_get_uint64(v.data())
	return uint64(val)
}

func GetHugeInt(v Value) HugeInt {
	return C.duckdb_get_hugeint(v.data())
}

func GetUHugeInt(v Value) UHugeInt {
	return C.duckdb_get_uhugeint(v.data())
}

// GetBigNum wraps duckdb_get_bignum.
// The return value must be destroyed with DestroyBigNum.
func GetBigNum(v Value) BigNum {
	bigNum := C.duckdb_get_bignum(v.data())
	return trackedBigNum(bigNum)
}

func GetDecimal(v Value) Decimal {
	return C.duckdb_get_decimal(v.data())
}

func GetFloat(v Value) float32 {
	val := C.duckdb_get_float(v.data())
	return float32(val)
}

func GetDouble(v Value) float64 {
	val := C.duckdb_get_double(v.data())
	return float64(val)
}

func GetDate(v Value) Date {
	return C.duckdb_get_date(v.data())
}

func GetTime(v Value) Time {
	return C.duckdb_get_time(v.data())
}

func GetTimeNS(v Value) TimeNS {
	return C.duckdb_get_time_ns(v.data())
}

func GetTimeTZ(v Value) TimeTZ {
	return C.duckdb_get_time_tz(v.data())
}

func GetTimestamp(v Value) Timestamp {
	return C.duckdb_get_timestamp(v.data())
}

func GetTimestampTZ(v Value) Timestamp {
	return C.duckdb_get_timestamp_tz(v.data())
}

func GetTimestampS(v Value) TimestampS {
	return C.duckdb_get_timestamp_s(v.data())
}

func GetTimestampMS(v Value) TimestampMS {
	return C.duckdb_get_timestamp_ms(v.data())
}

func GetTimestampNS(v Value) TimestampNS {
	return C.duckdb_get_timestamp_ns(v.data())
}

func GetInterval(v Value) Interval {
	return C.duckdb_get_interval(v.data())
}

// GetValueType wraps duckdb_get_value_type.
// The return value must NOT be destroyed. It lives as long as Value (v) is alive.
func GetValueType(v Value) LogicalType {
	logicalType := C.duckdb_get_value_type(v.data())
	return LogicalType{
		Ptr: unsafe.Pointer(logicalType),
	}
}

// GetBlob wraps duckdb_get_blob.
// The return value must be destroyed with DestroyBlob.
func GetBlob(v Value) Blob {
	blob := C.duckdb_get_blob(v.data())
	return trackedBlob(blob)
}

// GetBit wraps duckdb_get_bit.
// The return value must be destroyed with DestroyBit.
func GetBit(v Value) Bit {
	bit := C.duckdb_get_bit(v.data())
	return trackedBit(bit)
}

func GetUUID(v Value) UHugeInt {
	return C.duckdb_get_uuid(v.data())
}

func GetVarchar(v Value) string {
	cStr := C.duckdb_get_varchar(v.data())
	defer Free(unsafe.Pointer(cStr))
	return C.GoString(cStr)
}

// CreateStructValue wraps duckdb_create_struct_value.
// The return value must be destroyed with DestroyValue.
func CreateStructValue(logicalType LogicalType, values []Value) Value {
	valuesPtr := allocValues(values)
	defer Free(unsafe.Pointer(valuesPtr))

	v := C.duckdb_create_struct_value(logicalType.data(), valuesPtr)
	return trackedValue(v)
}

// CreateListValue wraps duckdb_create_list_value.
// The return value must be destroyed with DestroyValue.
func CreateListValue(logicalType LogicalType, values []Value) Value {
	valuesPtr := allocValues(values)
	defer Free(unsafe.Pointer(valuesPtr))

	v := C.duckdb_create_list_value(logicalType.data(), valuesPtr, IdxT(len(values)))
	return trackedValue(v)
}

// CreateArrayValue wraps duckdb_create_array_value.
// The return value must be destroyed with DestroyValue.
func CreateArrayValue(logicalType LogicalType, values []Value) Value {
	valuesPtr := allocValues(values)
	defer Free(unsafe.Pointer(valuesPtr))

	v := C.duckdb_create_array_value(logicalType.data(), valuesPtr, IdxT(len(values)))
	return trackedValue(v)
}

// CreateMapValue wraps duckdb_create_map_value.
// The return value must be destroyed with DestroyValue.
func CreateMapValue(logicalType LogicalType, keys []Value, values []Value) Value {
	keyValuesPtr := allocValues(keys)
	defer Free(unsafe.Pointer(keyValuesPtr))

	valueValuesPtr := allocValues(values)
	defer Free(unsafe.Pointer(valueValuesPtr))

	m := C.duckdb_create_map_value(logicalType.data(), keyValuesPtr, valueValuesPtr, IdxT(len(keys)))
	return trackedValue(m)
}

// CreateUnionValue wraps duckdb_create_union_value.
// The return value must be destroyed with DestroyValue.
func CreateUnionValue(logicalType LogicalType, tag IdxT, value Value) Value {
	v := C.duckdb_create_union_value(logicalType.data(), tag, value.data())
	return trackedValue(v)
}

func GetMapSize(v Value) IdxT {
	return C.duckdb_get_map_size(v.data())
}

// GetMapKey wraps duckdb_get_map_key.
// The return value must be destroyed with DestroyValue.
func GetMapKey(v Value, index IdxT) Value {
	value := C.duckdb_get_map_key(v.data(), index)
	return trackedValue(value)
}

// GetMapValue wraps duckdb_get_map_value.
// The return value must be destroyed with DestroyValue.
func GetMapValue(v Value, index IdxT) Value {
	value := C.duckdb_get_map_value(v.data(), index)
	return trackedValue(value)
}

func IsNullValue(v Value) bool {
	return bool(C.duckdb_is_null_value(v.data()))
}

// CreateNullValue wraps duckdb_create_null_value.
// The return value must be destroyed with DestroyValue.
func CreateNullValue() Value {
	v := C.duckdb_create_null_value()
	return trackedValue(v)
}

func GetListSize(v Value) IdxT {
	return C.duckdb_get_list_size(v.data())
}

// GetListChild wraps duckdb_get_list_child.
// The return value must be destroyed with DestroyValue.
func GetListChild(val Value, index IdxT) Value {
	v := C.duckdb_get_list_child(val.data(), index)
	return trackedValue(v)
}

// CreateEnumValue wraps duckdb_create_enum_value.
// The return value must be destroyed with DestroyValue.
func CreateEnumValue(logicalType LogicalType, val uint64) Value {
	v := C.duckdb_create_enum_value(logicalType.data(), C.uint64_t(val))
	return trackedValue(v)
}

func GetEnumValue(v Value) uint64 {
	return uint64(C.duckdb_get_enum_value(v.data()))
}

// GetStructChild wraps duckdb_get_struct_child.
// The return value must be destroyed with DestroyValue.
func GetStructChild(val Value, index IdxT) Value {
	v := C.duckdb_get_struct_child(val.data(), index)
	return trackedValue(v)
}

func ValueToString(val Value) string {
	str := C.duckdb_value_to_string(val.data())
	defer Free(unsafe.Pointer(str))
	return C.GoString(str)
}
