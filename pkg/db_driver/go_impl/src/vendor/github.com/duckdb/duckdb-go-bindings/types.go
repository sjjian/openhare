package duckdb_go_bindings

/*
#include <duckdb.h>
#include <stdlib.h>
#include <string.h>
#include <duckdb_go_bindings.h>
*/
import "C"

import "unsafe"

type IdxT = C.idx_t

type SelT = C.sel_t

// Types without internal pointers:

type (
	Date              = C.duckdb_date
	DateStruct        = C.duckdb_date_struct
	Time              = C.duckdb_time
	TimeStruct        = C.duckdb_time_struct
	TimeNS            = C.duckdb_time_ns
	TimeTZ            = C.duckdb_time_tz
	TimeTZStruct      = C.duckdb_time_tz_struct
	Timestamp         = C.duckdb_timestamp
	TimestampS        = C.duckdb_timestamp_s
	TimestampMS       = C.duckdb_timestamp_ms
	TimestampNS       = C.duckdb_timestamp_ns
	TimestampStruct   = C.duckdb_timestamp_struct
	Interval          = C.duckdb_interval
	HugeInt           = C.duckdb_hugeint
	UHugeInt          = C.duckdb_uhugeint
	Decimal           = C.duckdb_decimal
	QueryProgressType = C.duckdb_query_progress_type
	// StringT does not export New and Members.
	// Use the respective StringT functions to access / write to this type.
	StringT   = C.duckdb_string_t
	ListEntry = C.duckdb_list_entry
	// Blob does not export New and Members.
	// Use the respective Blob functions to access / write to this type.
	// This type must be destroyed with DestroyBlob.
	Blob = C.duckdb_blob
	// Bit stores a bit string.
	// Use NewBit/BitMembers to access this type.
	// This type must be destroyed with DestroyBit.
	Bit = C.duckdb_bit
	// BigNum stores arbitrary precision integers.
	// Use NewBigNum/BigNumMembers to access/write to this type.
	// This type must be destroyed with DestroyBigNum.
	BigNum = C.duckdb_bignum
)

// TODO:
// duckdb_string
// duckdb_extension_access

func StringIsInlined(strT StringT) bool {
	isInlined := C.duckdb_string_is_inlined(strT)
	return bool(isInlined)
}

func StringTLength(strT StringT) uint32 {
	length := C.duckdb_string_t_length(strT)
	return uint32(length)
}

func StringTData(strT *StringT) string {
	length := C.int(StringTLength(*strT))
	ptr := unsafe.Pointer(C.duckdb_string_t_data(strT))
	return string(C.GoBytes(ptr, length))
}

// Helper functions for types without internal pointers:

// NewDate sets the members of a duckdb_date.
func NewDate(days int32) Date {
	return Date{days: C.int32_t(days)}
}

// DateMembers returns the days of a duckdb_date.
func DateMembers(date *Date) int32 {
	return int32(date.days)
}

// NewDateStruct sets the members of a duckdb_date_struct.
func NewDateStruct(year int32, month int8, day int8) DateStruct {
	return DateStruct{
		year:  C.int32_t(year),
		month: C.int8_t(month),
		day:   C.int8_t(day),
	}
}

// DateStructMembers returns the year, month, and day of a duckdb_date.
func DateStructMembers(date *DateStruct) (int32, int8, int8) {
	return int32(date.year), int8(date.month), int8(date.day)
}

// NewTime sets the members of a duckdb_time.
func NewTime(micros int64) Time {
	return Time{micros: C.int64_t(micros)}
}

// TimeMembers returns the micros of a duckdb_time.
func TimeMembers(ti *Time) int64 {
	return int64(ti.micros)
}

// NewTimeStruct sets the members of a duckdb_time_struct.
func NewTimeStruct(hour int8, min int8, sec int8, micros int32) TimeStruct {
	return TimeStruct{
		hour:   C.int8_t(hour),
		min:    C.int8_t(min),
		sec:    C.int8_t(sec),
		micros: C.int32_t(micros),
	}
}

// TimeStructMembers returns the hour, min, sec, and micros of a duckdb_time_struct.
func TimeStructMembers(ti *TimeStruct) (int8, int8, int8, int32) {
	return int8(ti.hour), int8(ti.min), int8(ti.sec), int32(ti.micros)
}

// NewTimeNS sets the members of a duckdb_time_ns.
func NewTimeNS(nanos int64) TimeNS {
	return TimeNS{nanos: C.int64_t(nanos)}
}

// TimeNSMembers returns the nanos of a duckdb_time_ns.
func TimeNSMembers(ti *TimeNS) int64 {
	return int64(ti.nanos)
}

// NewTimeTZ sets the members of a duckdb_time_tz.
func NewTimeTZ(bits uint64) TimeTZ {
	return TimeTZ{bits: C.uint64_t(bits)}
}

// TimeTZMembers returns the bits of a duckdb_time_tz.
func TimeTZMembers(ti *TimeTZ) uint64 {
	return uint64(ti.bits)
}

// NewTimeTZStruct sets the members of a duckdb_time_tz_struct.
func NewTimeTZStruct(ti TimeStruct, offset int32) TimeTZStruct {
	return TimeTZStruct{
		time:   ti,
		offset: C.int32_t(offset),
	}
}

// TimeTZStructMembers returns the time and offset of a duckdb_time_tz_struct.
func TimeTZStructMembers(ti *TimeTZStruct) (TimeStruct, int32) {
	return ti.time, int32(ti.offset)
}

// NewTimestamp sets the members of a duckdb_timestamp.
func NewTimestamp(micros int64) Timestamp {
	return Timestamp{micros: C.int64_t(micros)}
}

// TimestampMembers returns the micros of a duckdb_timestamp.
func TimestampMembers(ts *Timestamp) int64 {
	return int64(ts.micros)
}

// NewTimestampS sets the members of a duckdb_timestamp_s.
func NewTimestampS(seconds int64) TimestampS {
	return TimestampS{seconds: C.int64_t(seconds)}
}

// TimestampSMembers returns the seconds of a duckdb_timestamp_s.
func TimestampSMembers(ts *TimestampS) int64 {
	return int64(ts.seconds)
}

// NewTimestampMS sets the members of a duckdb_timestamp_ms.
func NewTimestampMS(millis int64) TimestampMS {
	return TimestampMS{millis: C.int64_t(millis)}
}

// TimestampMSMembers returns the millis of a duckdb_timestamp_ms.
func TimestampMSMembers(ts *TimestampMS) int64 {
	return int64(ts.millis)
}

// NewTimestampNS sets the members of a duckdb_timestamp_ns.
func NewTimestampNS(nanos int64) TimestampNS {
	return TimestampNS{nanos: C.int64_t(nanos)}
}

// TimestampNSMembers returns the nanos of a duckdb_timestamp_ns.
func TimestampNSMembers(ts *TimestampNS) int64 {
	return int64(ts.nanos)
}

// NewTimestampStruct sets the members of a duckdb_timestamp_struct.
func NewTimestampStruct(date DateStruct, ti TimeStruct) TimestampStruct {
	return TimestampStruct{
		date: date,
		time: ti,
	}
}

// TimestampStructMembers returns the date and time of a duckdb_timestamp_struct.
func TimestampStructMembers(ts *TimestampStruct) (DateStruct, TimeStruct) {
	return ts.date, ts.time
}

// NewInterval sets the members of a duckdb_interval.
func NewInterval(months int32, days int32, micros int64) Interval {
	return Interval{
		months: C.int32_t(months),
		days:   C.int32_t(days),
		micros: C.int64_t(micros),
	}
}

// IntervalMembers returns the months, days, and micros of a duckdb_interval.
func IntervalMembers(i *Interval) (int32, int32, int64) {
	return int32(i.months), int32(i.days), int64(i.micros)
}

// NewHugeInt sets the members of a duckdb_hugeint.
func NewHugeInt(lower uint64, upper int64) HugeInt {
	return HugeInt{
		lower: C.uint64_t(lower),
		upper: C.int64_t(upper),
	}
}

// HugeIntMembers returns the lower and upper of a duckdb_hugeint.
func HugeIntMembers(hi *HugeInt) (uint64, int64) {
	return uint64(hi.lower), int64(hi.upper)
}

// NewUHugeInt sets the members of a duckdb_uhugeint.
func NewUHugeInt(lower uint64, upper uint64) UHugeInt {
	return UHugeInt{
		lower: C.uint64_t(lower),
		upper: C.uint64_t(upper),
	}
}

// UHugeIntMembers returns the lower and upper of a duckdb_uhugeint.
func UHugeIntMembers(hi *UHugeInt) (uint64, uint64) {
	return uint64(hi.lower), uint64(hi.upper)
}

// NewDecimal sets the members of a duckdb_decimal.
func NewDecimal(width uint8, scale uint8, hi HugeInt) Decimal {
	return Decimal{
		width: C.uint8_t(width),
		scale: C.uint8_t(scale),
		value: hi,
	}
}

// DecimalMembers returns the width, scale, and value of a duckdb_decimal.
func DecimalMembers(d *Decimal) (uint8, uint8, HugeInt) {
	return uint8(d.width), uint8(d.scale), d.value
}

// NewQueryProgressType sets the members of a duckdb_query_progress_type.
func NewQueryProgressType(percentage float64, rowsProcessed uint64, totalRowsToProcess uint64) QueryProgressType {
	return QueryProgressType{
		percentage:            C.double(percentage),
		rows_processed:        C.uint64_t(rowsProcessed),
		total_rows_to_process: C.uint64_t(totalRowsToProcess),
	}
}

// QueryProgressTypeMembers returns the percentage, rows_processed, and total_rows_to_process of a duckdb_query_progress_type.
func QueryProgressTypeMembers(q *QueryProgressType) (float64, uint64, uint64) {
	return float64(q.percentage), uint64(q.rows_processed), uint64(q.total_rows_to_process)
}

// NewListEntry sets the members of a duckdb_list_entry.
func NewListEntry(offset uint64, length uint64) ListEntry {
	return ListEntry{
		offset: C.uint64_t(offset),
		length: C.uint64_t(length),
	}
}

// ListEntryMembers returns the offset and length of a duckdb_list_entry.
func ListEntryMembers(entry *ListEntry) (uint64, uint64) {
	return uint64(entry.offset), uint64(entry.length)
}

// NewBigNum creates a BigNum from a byte slice and sign.
// The data is stored in little endian format (absolute value).
// The returned BigNum must be destroyed with DestroyBigNum.
func NewBigNum(data []byte, isNegative bool) BigNum {
	cData := (*C.uint8_t)(C.CBytes(data))
	return trackedBigNum(BigNum{
		data:        cData,
		size:        C.idx_t(len(data)),
		is_negative: C.bool(isNegative),
	})
}

// BigNumMembers returns the data bytes and sign of a BigNum.
// The data is in little endian format (absolute value).
func BigNumMembers(bn *BigNum) ([]byte, bool) {
	size := int(bn.size)
	data := C.GoBytes(unsafe.Pointer(bn.data), C.int(size))
	return data, bool(bn.is_negative)
}

// NewBit creates a Bit from the given data bytes.
// BIT byte data has 0 to 7 bits of padding.
// The first byte contains the number of padding bits.
// The padding bits of the second byte are set to 1, starting from the MSB.
func NewBit(data []byte) Bit {
	cData := (*C.uint8_t)(C.CBytes(data))
	return trackedBit(Bit{
		data: cData,
		size: C.idx_t(len(data)),
	})
}

// BitMembers returns the data bytes of a Bit.
// The first byte contains the padding (number of unused bits in the last byte).
// Remaining bytes contain the actual bit data.
func BitMembers(b *Bit) []byte {
	size := int(b.size)
	return C.GoBytes(unsafe.Pointer(b.data), C.int(size))
}

// Helper functions for types with internal fields that need freeing:

// DestroyBlob destroys the data field of duckdb_blob.
func DestroyBlob(b *Blob) {
	if b == nil || b.data == nil {
		return
	}
	releaseAllocation(blobAllocation, b.data)
	Free(b.data)
	b.data = nil
}

// DestroyBit destroys the data field of duckdb_bit.
func DestroyBit(b *Bit) {
	if b == nil || b.data == nil {
		return
	}
	releaseAllocation(bitAllocation, unsafe.Pointer(b.data))
	Free(unsafe.Pointer(b.data))
	b.data = nil
}

// DestroyBigNum destroys the data field of duckdb_bignum.
func DestroyBigNum(i *BigNum) {
	if i == nil || i.data == nil {
		return
	}
	releaseAllocation(bigNumAllocation, unsafe.Pointer(i.data))
	Free(unsafe.Pointer(i.data))
	i.data = nil
}

func FromDate(date Date) DateStruct {
	return C.duckdb_from_date(date)
}

func ToDate(date DateStruct) Date {
	return C.duckdb_to_date(date)
}

func IsFiniteDate(date Date) bool {
	return bool(C.duckdb_is_finite_date(date))
}

func FromTime(ti Time) TimeStruct {
	return C.duckdb_from_time(ti)
}

func CreateTimeTZ(micros int64, offset int32) TimeTZ {
	return C.duckdb_create_time_tz(C.int64_t(micros), C.int32_t(offset))
}

func FromTimeTZ(ti TimeTZ) TimeTZStruct {
	return C.duckdb_from_time_tz(ti)
}

func ToTime(ti TimeStruct) Time {
	return C.duckdb_to_time(ti)
}

func FromTimestamp(ts Timestamp) TimestampStruct {
	return C.duckdb_from_timestamp(ts)
}

func ToTimestamp(ts TimestampStruct) Timestamp {
	return C.duckdb_to_timestamp(ts)
}

func IsFiniteTimestamp(ts Timestamp) bool {
	return bool(C.duckdb_is_finite_timestamp(ts))
}

func IsFiniteTimestampS(ts TimestampS) bool {
	return bool(C.duckdb_is_finite_timestamp_s(ts))
}

func IsFiniteTimestampMS(ts TimestampMS) bool {
	return bool(C.duckdb_is_finite_timestamp_ms(ts))
}

func IsFiniteTimestampNS(ts TimestampNS) bool {
	return bool(C.duckdb_is_finite_timestamp_ns(ts))
}

func HugeIntToDouble(hi HugeInt) float64 {
	return float64(C.duckdb_hugeint_to_double(hi))
}

func DoubleToHugeInt(d float64) HugeInt {
	return C.duckdb_double_to_hugeint(C.double(d))
}

func UHugeIntToDouble(hi UHugeInt) float64 {
	return float64(C.duckdb_uhugeint_to_double(hi))
}

func DoubleToUHugeInt(d float64) UHugeInt {
	return C.duckdb_double_to_uhugeint(C.double(d))
}

func DoubleToDecimal(d float64, width uint8, scale uint8) Decimal {
	return C.duckdb_double_to_decimal(C.double(d), C.uint8_t(width), C.uint8_t(scale))
}

func DecimalToDouble(d Decimal) float64 {
	return float64(C.duckdb_decimal_to_double(d))
}

// Types with internal pointers:

// Column wraps duckdb_column.
// NOTE: Same limitations as Result.
// Deprecated: See C API documentation.
type Column struct {
	data C.duckdb_column
}

// Result wraps duckdb_result.
// NOTE: Using 'type Result = C.duckdb_result' causes a somewhat mysterious
// 'runtime error: cgo argument has Go pointer to unpinned Go pointer'.
// See https://github.com/golang/go/issues/28606#issuecomment-2184269962.
// When using a type alias, duckdb_result itself contains a Go unsafe.Pointer for its 'void *internal_data' field.
type Result struct {
	data C.duckdb_result
}
