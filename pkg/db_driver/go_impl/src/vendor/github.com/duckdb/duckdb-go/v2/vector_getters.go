package duckdb

import (
	"encoding/json"
	"maps"
	"math/big"
	"strings"
	"time"
	"unsafe"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// fnGetVectorValue is the getter callback function for any (nested) vector.
type fnGetVectorValue func(vec *vector, rowIdx mapping.IdxT) (any, error)

// getNull checks DuckDB's validity bitfield: one bit per row packed into uint64 entries.
// Bit = 1 means valid (not null), bit = 0 means null.
func (vec *vector) getNull(rowIdx mapping.IdxT) bool {
	if vec.maskPtr == nil {
		return false
	}
	entryIdx := uint64(rowIdx) / 64                         // which uint64 entry holds this row's bit
	idxInEntry := uint64(rowIdx) % 64                       // which bit position within that entry (0-63)
	mask := *(*uint64)(unsafe.Add(vec.maskPtr, entryIdx*8)) // read the entry at byte offset entryIdx*8
	return mask&(1<<idxInEntry) == 0                        // 0 = null, 1 = valid
}

func getPrimitive[T any](vec *vector, rowIdx mapping.IdxT) T {
	var zero T
	elementSize := unsafe.Sizeof(zero)
	offset := uintptr(rowIdx) * elementSize
	ptr := unsafe.Add(vec.dataPtr, offset)
	return *(*T)(ptr)
}

func (vec *vector) getTS(t Type, rowIdx mapping.IdxT) time.Time {
	switch t {
	case TYPE_TIMESTAMP, TYPE_TIMESTAMP_TZ:
		val := getPrimitive[mapping.Timestamp](vec, rowIdx)
		return getTS(t, &val)
	case TYPE_TIMESTAMP_S:
		val := getPrimitive[mapping.TimestampS](vec, rowIdx)
		return getTSS(&val)
	case TYPE_TIMESTAMP_MS:
		val := getPrimitive[mapping.TimestampMS](vec, rowIdx)
		return getTSMS(&val)
	case TYPE_TIMESTAMP_NS:
		val := getPrimitive[mapping.TimestampNS](vec, rowIdx)
		return getTSNS(&val)
	default:
		return time.Time{}
	}
}

func getTS(t Type, ts *mapping.Timestamp) time.Time {
	switch t {
	case TYPE_TIMESTAMP, TYPE_TIMESTAMP_TZ:
		return time.UnixMicro(mapping.TimestampMembers(ts)).UTC()
	}
	return time.Time{}
}

func getTSS(ts *mapping.TimestampS) time.Time {
	return time.Unix(mapping.TimestampSMembers(ts), 0).UTC()
}

func getTSMS(ts *mapping.TimestampMS) time.Time {
	return time.UnixMilli(mapping.TimestampMSMembers(ts)).UTC()
}

func getTSNS(ts *mapping.TimestampNS) time.Time {
	return time.Unix(0, mapping.TimestampNSMembers(ts)).UTC()
}

func (vec *vector) getDate(rowIdx mapping.IdxT) time.Time {
	date := getPrimitive[mapping.Date](vec, rowIdx)
	return getDate(&date)
}

func getDate(date *mapping.Date) time.Time {
	d := mapping.FromDate(*date)
	year, month, day := mapping.DateStructMembers(&d)
	return time.Date(int(year), time.Month(month), int(day), 0, 0, 0, 0, time.UTC)
}

func (vec *vector) getTime(rowIdx mapping.IdxT) time.Time {
	switch vec.Type {
	case TYPE_TIME:
		val := getPrimitive[mapping.Time](vec, rowIdx)
		return getTime(&val)
	case TYPE_TIME_TZ:
		ti := getPrimitive[mapping.TimeTZ](vec, rowIdx)
		return getTimeTZ(&ti)
	}
	return time.Time{}
}

func getTime(ti *mapping.Time) time.Time {
	micros := mapping.TimeMembers(ti)
	unix := time.UnixMicro(micros).UTC()
	return time.Date(1, time.January, 1, unix.Hour(), unix.Minute(), unix.Second(), unix.Nanosecond(), time.UTC)
}

func getTimeTZ(ti *mapping.TimeTZ) time.Time {
	timeTZStruct := mapping.FromTimeTZ(*ti)
	timeStruct, offset := mapping.TimeTZStructMembers(&timeTZStruct)

	// TIMETZ has microsecond precision.
	hour, minute, sec, micro := mapping.TimeStructMembers(&timeStruct)
	nanos := int(micro) * 1000
	loc := time.UTC
	if offset != 0 {
		loc = time.FixedZone("", int(offset))
	}
	return time.Date(1, time.January, 1, int(hour), int(minute), int(sec), nanos, loc)
}

func (vec *vector) getInterval(rowIdx mapping.IdxT) Interval {
	interval := getPrimitive[mapping.Interval](vec, rowIdx)
	return getInterval(&interval)
}

func getInterval(interval *mapping.Interval) Interval {
	months, days, micros := mapping.IntervalMembers(interval)
	return Interval{
		Days:   days,
		Months: months,
		Micros: micros,
	}
}

func (vec *vector) getHugeint(rowIdx mapping.IdxT) *big.Int {
	hugeInt := getPrimitive[mapping.HugeInt](vec, rowIdx)
	return hugeIntToNative(&hugeInt)
}

func (vec *vector) getUhugeint(rowIdx mapping.IdxT) *big.Int {
	uhugeInt := getPrimitive[mapping.UHugeInt](vec, rowIdx)
	return uhugeIntToNative(&uhugeInt)
}

func (vec *vector) getBigNum(rowIdx mapping.IdxT) *big.Int {
	// BIGNUM is stored as StringT containing DuckDB's encoding:
	// - Bytes 0-2: 3-byte header (length | 0x800000 for positive, complemented for negative)
	// - Bytes 3+: Big-endian magnitude (complemented for negative)
	// Sign is determined by whether MSB of byte 0 is set (0x80)
	strT := getPrimitive[mapping.StringT](vec, rowIdx)
	data := []byte(mapping.StringTData(&strT))

	if len(data) < 4 {
		return big.NewInt(0)
	}

	// Check sign: MSB set means positive
	isPositive := (data[0] & 0x80) != 0

	// Data starts at byte 3, magnitude is already big-endian
	magnitude := data[3:]

	if isPositive {
		return new(big.Int).SetBytes(magnitude)
	}

	// Negative: complement all magnitude bytes
	complemented := make([]byte, len(magnitude))
	for i := range magnitude {
		complemented[i] = ^magnitude[i]
	}

	result := new(big.Int).SetBytes(complemented)
	result.Neg(result)
	return result
}

func (vec *vector) getBytes(rowIdx mapping.IdxT) any {
	// Use a pointer directly into C-allocated vector memory rather than a stack copy.
	// cgo declares duckdb_string_t with alignment 1, so a stack copy (via getPrimitive)
	// may land at an odd address. Reading the out-of-line pointer field at offset 8
	// then requires 8-byte alignment, which trips checkptr under -race.
	// C's allocator guarantees vec.dataPtr is ≥8-byte aligned, and each
	// duckdb_string_t is 16 bytes, so offset 8 within any element is always 8-byte aligned.
	strTPtr := (*mapping.StringT)(unsafe.Add(vec.dataPtr, uintptr(rowIdx)*unsafe.Sizeof(mapping.StringT{})))
	length := *(*uint32)(unsafe.Pointer(strTPtr))
	// duckdb_string_t layout: uint32 length at offset 0; if length <= 12 data is inlined
	// at offset 4, otherwise a pointer at offset 8 (see duckdb.h string_t::INLINE_LENGTH).
	// NOTE: INLINE_LENGTH (12) is not exposed via the C API and could change in a future
	// DuckDB version. If string tests start failing after a DuckDB upgrade, check here first.
	var data string
	if length <= 12 {
		ptr := unsafe.Add(unsafe.Pointer(strTPtr), 4)
		data = unsafe.String((*byte)(ptr), int(length))
	} else {
		dataPtr := *(*unsafe.Pointer)(unsafe.Add(unsafe.Pointer(strTPtr), 8))
		data = unsafe.String((*byte)(dataPtr), int(length))
	}
	if vec.Type == TYPE_VARCHAR {
		return strings.Clone(data)
	}
	return []byte(data)
}

func (vec *vector) getBit(rowIdx mapping.IdxT) Bit {
	strT := getPrimitive[mapping.StringT](vec, rowIdx)
	str := mapping.StringTData(&strT)
	return Bit{Data: []byte(str)}
}

func (vec *vector) getJSON(rowIdx mapping.IdxT) any {
	bytes := vec.getBytes(rowIdx).(string)
	var value any
	_ = json.Unmarshal([]byte(bytes), &value)
	return value
}

func (vec *vector) getDecimal(rowIdx mapping.IdxT) (Decimal, error) {
	var val *big.Int
	switch vec.internalType {
	case TYPE_SMALLINT:
		v := getPrimitive[int16](vec, rowIdx)
		val = big.NewInt(int64(v))
	case TYPE_INTEGER:
		v := getPrimitive[int32](vec, rowIdx)
		val = big.NewInt(int64(v))
	case TYPE_BIGINT:
		v := getPrimitive[int64](vec, rowIdx)
		val = big.NewInt(v)
	case TYPE_HUGEINT:
		v := getPrimitive[mapping.HugeInt](vec, rowIdx)
		val = hugeIntToNative(&v)
	default:
		return Decimal{}, unsupportedTypeError(typeName(vec.internalType))
	}
	return Decimal{Width: vec.decimalWidth, Scale: vec.decimalScale, Value: val}, nil
}

func (vec *vector) getEnum(rowIdx mapping.IdxT) (string, error) {
	var idx mapping.IdxT
	switch vec.internalType {
	case TYPE_UTINYINT:
		idx = mapping.IdxT(getPrimitive[uint8](vec, rowIdx))
	case TYPE_USMALLINT:
		idx = mapping.IdxT(getPrimitive[uint16](vec, rowIdx))
	case TYPE_UINTEGER:
		idx = mapping.IdxT(getPrimitive[uint32](vec, rowIdx))
	case TYPE_UBIGINT:
		idx = mapping.IdxT(getPrimitive[uint64](vec, rowIdx))
	default:
		return "", unsupportedTypeError(typeName(vec.internalType))
	}

	// Use the pre-built slice instead of CGO round-trips.
	// Before: VectorGetColumnType + EnumDictionaryValue + DestroyLogicalType per cell.
	// After:  single slice index — no CGO, no hashing, no heap allocation.
	return vec.enumDict[idx], nil
}

func (vec *vector) getList(rowIdx mapping.IdxT) ([]any, error) {
	entry := getPrimitive[mapping.ListEntry](vec, rowIdx)
	offset, length := mapping.ListEntryMembers(&entry)
	return vec.getSliceChild(offset, length)
}

func (vec *vector) getStruct(rowIdx mapping.IdxT) (map[string]any, error) {
	m := maps.Clone(vec.structTemplate)
	for i := range vec.childVectors {
		child := &vec.childVectors[i]
		val, err := child.getFn(child, rowIdx)
		if err != nil {
			return nil, err
		}
		m[vec.structEntries[i].Name()] = val
	}
	return m, nil
}

func (vec *vector) getMap(rowIdx mapping.IdxT) (OrderedMap, error) {
	list, err := vec.getList(rowIdx)
	if err != nil {
		return OrderedMap{}, err
	}

	m := OrderedMap{}
	for i := range list {
		mapItem := list[i].(map[string]any)
		key := mapItem[mapKeysField()]
		val := mapItem[mapValuesField()]
		m.Set(key, val)
	}
	return m, nil
}

func (vec *vector) getArray(rowIdx mapping.IdxT) ([]any, error) {
	length := uint64(vec.arrayLength)
	return vec.getSliceChild(uint64(rowIdx)*length, length)
}

func (vec *vector) getSliceChild(offset, length uint64) ([]any, error) {
	slice := make([]any, 0, length)
	child := &vec.childVectors[0]

	// Fill the slice with all child values.
	for i := range length {
		val, err := child.getFn(child, mapping.IdxT(i+offset))
		if err != nil {
			return nil, err
		}
		slice = append(slice, val)
	}
	return slice, nil
}

func (vec *vector) getUnion(rowIdx mapping.IdxT) (any, error) {
	tag := getPrimitive[uint8](&vec.childVectors[0], rowIdx)
	child := &vec.childVectors[tag+1]
	value, err := child.getFn(child, rowIdx)
	if err != nil {
		return nil, err
	}

	return Union{
		Tag:   vec.tagDict[uint32(tag)],
		Value: value,
	}, nil
}
