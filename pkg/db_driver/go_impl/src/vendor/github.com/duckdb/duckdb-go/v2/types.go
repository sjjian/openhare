package duckdb

import (
	"bytes"
	"database/sql/driver"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"reflect"
	"strings"
	"time"

	"github.com/go-viper/mapstructure/v2"
	"github.com/google/uuid"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// duckdb-go exports the following type wrappers:
// UUID, Bit, Map, Interval, Decimal, Union, Composite (optional, used to scan LIST and STRUCT).

// Pre-computed reflect type values to avoid repeated allocations.
var (
	reflectTypeBool      = reflect.TypeFor[bool]()
	reflectTypeInt8      = reflect.TypeFor[int8]()
	reflectTypeInt16     = reflect.TypeFor[int16]()
	reflectTypeInt32     = reflect.TypeFor[int32]()
	reflectTypeInt64     = reflect.TypeFor[int64]()
	reflectTypeUint8     = reflect.TypeFor[uint8]()
	reflectTypeUint16    = reflect.TypeFor[uint16]()
	reflectTypeUint32    = reflect.TypeFor[uint32]()
	reflectTypeUint64    = reflect.TypeFor[uint64]()
	reflectTypeFloat32   = reflect.TypeFor[float32]()
	reflectTypeFloat64   = reflect.TypeFor[float64]()
	reflectTypeTime      = reflect.TypeFor[time.Time]()
	reflectTypeInterval  = reflect.TypeFor[Interval]()
	reflectTypeBigInt    = reflect.TypeFor[*big.Int]()
	reflectTypeString    = reflect.TypeFor[string]()
	reflectTypeBytes     = reflect.TypeFor[[]byte]()
	reflectTypeDecimal   = reflect.TypeFor[Decimal]()
	reflectTypeSliceAny  = reflect.TypeFor[[]any]()
	reflectTypeMapString = reflect.TypeFor[map[string]any]()
	reflectTypeMap       = reflect.TypeFor[OrderedMap]()
	reflectTypeUnion     = reflect.TypeFor[Union]()
	reflectTypeAny       = reflect.TypeFor[any]()
	reflectTypeUUID      = reflect.TypeFor[UUID]()
	reflectTypeBit       = reflect.TypeFor[Bit]()
)

type numericType interface {
	int | int8 | int16 | int32 | int64 | uint | uint8 | uint16 | uint32 | uint64 | float32 | float64
}

const uuidLength = 16

type UUID [uuidLength]byte

// Scan implements the sql.Scanner interface.
func (u *UUID) Scan(v any) error {
	switch val := v.(type) {
	case []byte:
		if len(val) != uuidLength {
			return u.Scan(string(val))
		}
		copy(u[:], val)
	case string:
		id, err := uuid.Parse(val)
		if err != nil {
			return err
		}
		copy(u[:], id[:])
	default:
		return fmt.Errorf("invalid UUID value type: %T", val)
	}
	return nil
}

// String implements the fmt.Stringer interface.
func (u *UUID) String() string {
	buf := make([]byte, 36)

	hex.Encode(buf, u[:4])
	buf[8] = '-'
	hex.Encode(buf[9:13], u[4:6])
	buf[13] = '-'
	hex.Encode(buf[14:18], u[6:8])
	buf[18] = '-'
	hex.Encode(buf[19:23], u[8:10])
	buf[23] = '-'
	hex.Encode(buf[24:], u[10:])

	return string(buf)
}

// Value implements the driver.Valuer interface.
func (u *UUID) Value() (driver.Value, error) {
	return u.String(), nil
}

func inferUUID(val any) (mapping.HugeInt, error) {
	var id UUID
	switch v := val.(type) {
	case UUID:
		id = v
	case *UUID:
		id = *v
	case []uint8:
		if len(v) != uuidLength {
			return mapping.HugeInt{}, castError(reflect.TypeOf(val).String(), reflectTypeUUID.String())
		}
		for i := range uuidLength {
			id[i] = v[i]
		}
	default:
		return mapping.HugeInt{}, castError(reflect.TypeOf(val).String(), reflectTypeUUID.String())
	}
	hi := uuidToHugeInt(id)
	return hi, nil
}

// duckdb_hugeint is composed of (lower, upper) components.
// The value is computed as: upper * 2^64 + lower

func hugeIntToUUID(hugeInt *mapping.HugeInt) []byte {
	// Flip the sign bit of the signed hugeint to transform it to UUID bytes.
	var val [uuidLength]byte
	lower, upper := mapping.HugeIntMembers(hugeInt)
	binary.BigEndian.PutUint64(val[:8], uint64(upper)^1<<63)
	binary.BigEndian.PutUint64(val[8:], lower)
	return val[:]
}

func uuidToHugeInt(uuid UUID) mapping.HugeInt {
	// Flip the sign bit.
	lower := binary.BigEndian.Uint64(uuid[8:])
	upper := binary.BigEndian.Uint64(uuid[:8])
	return mapping.NewHugeInt(lower, int64(upper^(1<<63)))
}

// Bit represents a DuckDB BIT value as a sequence of bits.
// Data stores DuckDB's internal format: a padding-count prefix byte followed by
// the bit bytes (right-aligned with 1-padded MSB bits).
// For example, "10101" (5 bits) is stored as [3, 11110101] where 3 is the padding count.
//
//nolint:recvcheck // Scan must use a pointer receiver for sql.Scanner. Helpers stay on value receivers so Bit values implement fmt.Stringer.
type Bit struct {
	Data []byte
}

// Scan implements the sql.Scanner interface.
func (b *Bit) Scan(v any) error {
	if b == nil {
		return fmt.Errorf("invalid Bit destination")
	}

	switch val := v.(type) {
	case nil:
		b.Data = nil
		return nil
	case Bit:
		if err := val.Validate(); err != nil {
			return err
		}
		b.Data = append([]byte(nil), val.Data...)
		return nil
	case *Bit:
		if val == nil {
			b.Data = nil
			return nil
		}
		return b.Scan(*val)
	case string:
		bit, err := NewBitFromString(val)
		if err != nil {
			return err
		}
		*b = bit
		return nil
	case []byte:
		return b.Scan(string(val))
	default:
		return fmt.Errorf("invalid Bit value type: %T", v)
	}
}

// NewBitFromString creates a Bit from a string of '0' and '1' characters.
func NewBitFromString(s string) (Bit, error) {
	if len(s) == 0 {
		return Bit{}, fmt.Errorf("empty bit string")
	}

	numBytes := (len(s) + 7) / 8
	padding := (8 - (len(s) % 8)) % 8
	data := make([]byte, numBytes+1)
	data[0] = byte(padding)

	// Set padding bits to 1
	if padding > 0 {
		data[1] = byte(0xFF) << (8 - padding)
	}

	for i, c := range s {
		switch c {
		case '1':
			bitPos := padding + i
			byteIdx := bitPos/8 + 1
			bitIdx := 7 - (bitPos % 8)
			data[byteIdx] |= 1 << bitIdx
		case '0':
		default:
			return Bit{}, fmt.Errorf("invalid character in bit string: %c", c)
		}
	}

	return Bit{Data: data}, nil
}

// Validate checks that Data is a valid DuckDB bit encoding: the padding count
// (first byte) must be 0-7, and the padding bits in the first data byte must
// all be set to 1.
func (b Bit) Validate() error {
	if len(b.Data) <= 1 {
		return fmt.Errorf("empty bit string")
	}
	padding := int(b.Data[0])
	if padding > 7 {
		return fmt.Errorf("invalid padding count %d, must be 0-7", padding)
	}
	if padding > 0 {
		expectedMask := byte(0xFF) << (8 - padding)
		if (b.Data[1] & expectedMask) != expectedMask {
			return fmt.Errorf("padding bits must be 1s, expected high %d bits of first byte to be set", padding)
		}
	}
	return nil
}

// Len returns the number of bits.
func (b Bit) Len() int {
	if len(b.Data) <= 1 {
		return 0
	}
	length := (len(b.Data)-1)*8 - int(b.Data[0])
	if length < 0 {
		return 0
	}
	return length
}

// String returns the bit string representation (e.g., "10101").
func (b Bit) String() string {
	length := b.Len()
	if length <= 0 {
		return ""
	}
	var sb strings.Builder
	sb.Grow(length)
	padding := int(b.Data[0])
	bitData := b.Data[1:]
	for i := range length {
		bitPos := padding + i
		byteIdx := bitPos / 8
		bitIdx := 7 - (bitPos % 8)
		if (bitData[byteIdx] & (1 << bitIdx)) != 0 {
			sb.WriteByte('1')
		} else {
			sb.WriteByte('0')
		}
	}
	return sb.String()
}

func hugeIntToNative(hugeInt *mapping.HugeInt) *big.Int {
	lower, upper := mapping.HugeIntMembers(hugeInt)
	i := big.NewInt(upper)
	i.Lsh(i, 64)
	i.Add(i, new(big.Int).SetUint64(lower))
	return i
}

func numToBigInt(val any) (*big.Int, error) {
	switch v := val.(type) {
	case uint8:
		return big.NewInt(int64(v)), nil
	case int8:
		return big.NewInt(int64(v)), nil
	case uint16:
		return big.NewInt(int64(v)), nil
	case int16:
		return big.NewInt(int64(v)), nil
	case uint32:
		return big.NewInt(int64(v)), nil
	case int32:
		return big.NewInt(int64(v)), nil
	case uint64:
		return new(big.Int).SetUint64(v), nil
	case int64:
		return big.NewInt(v), nil
	case uint:
		return new(big.Int).SetUint64(uint64(v)), nil
	case int:
		return big.NewInt(int64(v)), nil
	case float32:
		bigFloat := new(big.Float).SetFloat64(float64(v))
		bigInt, _ := bigFloat.Int(nil)
		return bigInt, nil
	case float64:
		bigFloat := new(big.Float).SetFloat64(v)
		bigInt, _ := bigFloat.Int(nil)
		return bigInt, nil
	case *big.Int:
		if v == nil {
			return nil, castError("nil *big.Int", "*big.Int")
		}
		return v, nil
	case Decimal:
		if v.Value == nil {
			return nil, castError("nil Decimal.Value", "*big.Int")
		}
		return v.Value, nil
	default:
		return nil, castError(reflect.TypeOf(val).String(), "*big.Int")
	}
}

func hugeIntFromNative(i *big.Int) (mapping.HugeInt, error) {
	d := big.NewInt(1)
	d.Lsh(d, 64)

	q := new(big.Int)
	r := new(big.Int)
	q.DivMod(i, d, r)

	if !q.IsInt64() {
		return mapping.HugeInt{}, fmt.Errorf("big.Int(%s) is too big for HUGEINT", i.String())
	}

	return mapping.NewHugeInt(r.Uint64(), q.Int64()), nil
}

func inferHugeInt(val any) (mapping.HugeInt, error) {
	var err error
	var hi mapping.HugeInt
	switch v := val.(type) {
	case uint8:
		hi = mapping.NewHugeInt(uint64(v), 0)
	case int8:
		hi = mapping.NewHugeInt(uint64(v), int64(v)>>63)
	case uint16:
		hi = mapping.NewHugeInt(uint64(v), 0)
	case int16:
		hi = mapping.NewHugeInt(uint64(v), int64(v)>>63)
	case uint32:
		hi = mapping.NewHugeInt(uint64(v), 0)
	case int32:
		hi = mapping.NewHugeInt(uint64(v), int64(v)>>63)
	case uint64:
		hi = mapping.NewHugeInt(v, 0)
	case int64:
		hi = mapping.NewHugeInt(uint64(v), v>>63)
	case uint:
		hi = mapping.NewHugeInt(uint64(v), 0)
	case int:
		hi = mapping.NewHugeInt(uint64(v), int64(v)>>63)
	default:
		var i *big.Int
		if i, err = numToBigInt(val); err != nil {
			return mapping.HugeInt{}, err
		}
		hi, err = hugeIntFromNative(i)
	}
	return hi, err
}

func uhugeIntToNative(uhi *mapping.UHugeInt) *big.Int {
	lower, upper := mapping.UHugeIntMembers(uhi)
	i := new(big.Int).SetUint64(upper)
	i.Lsh(i, 64)
	i.Add(i, new(big.Int).SetUint64(lower))
	return i
}

func uhugeIntFromNative(i *big.Int) (mapping.UHugeInt, error) {
	if i.Sign() < 0 {
		return mapping.UHugeInt{}, fmt.Errorf("big.Int(%s) is negative, cannot convert to UHUGEINT", i.String())
	}

	d := big.NewInt(1)
	d.Lsh(d, 64)

	q := new(big.Int)
	r := new(big.Int)
	q.DivMod(i, d, r)

	if !q.IsUint64() {
		return mapping.UHugeInt{}, fmt.Errorf("big.Int(%s) is too big for UHUGEINT", i.String())
	}

	return mapping.NewUHugeInt(r.Uint64(), q.Uint64()), nil
}

func bigNumToNative(bn *mapping.BigNum) *big.Int {
	data, isNegative := mapping.BigNumMembers(bn)

	// Data is in big-endian format, which is what big.Int.SetBytes expects.
	i := new(big.Int).SetBytes(data)
	if isNegative {
		i.Neg(i)
	}
	return i
}

func bigNumFromNative(i *big.Int) mapping.BigNum {
	isNegative := i.Sign() < 0

	// Get absolute value bytes in big-endian format (which is what NewBigNum expects).
	absVal := new(big.Int).Abs(i)
	bigEndian := absVal.Bytes()

	// Handle zero case - ensure at least one byte
	if len(bigEndian) == 0 {
		bigEndian = []byte{0}
	}

	return mapping.NewBigNum(bigEndian, isNegative)
}

func inferBigNum(val any) (mapping.BigNum, error) {
	i, err := numToBigInt(val)
	if err != nil {
		return mapping.BigNum{}, err
	}
	return bigNumFromNative(i), nil
}

func inferUHugeInt(val any) (mapping.UHugeInt, error) {
	var err error
	var uhi mapping.UHugeInt
	switch v := val.(type) {
	case uint8:
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case int8:
		if v < 0 {
			return mapping.UHugeInt{}, fmt.Errorf("negative value %d cannot be converted to UHUGEINT", v)
		}
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case uint16:
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case int16:
		if v < 0 {
			return mapping.UHugeInt{}, fmt.Errorf("negative value %d cannot be converted to UHUGEINT", v)
		}
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case uint32:
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case int32:
		if v < 0 {
			return mapping.UHugeInt{}, fmt.Errorf("negative value %d cannot be converted to UHUGEINT", v)
		}
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case uint64:
		uhi = mapping.NewUHugeInt(v, 0)
	case int64:
		if v < 0 {
			return mapping.UHugeInt{}, fmt.Errorf("negative value %d cannot be converted to UHUGEINT", v)
		}
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case uint:
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	case int:
		if v < 0 {
			return mapping.UHugeInt{}, fmt.Errorf("negative value %d cannot be converted to UHUGEINT", v)
		}
		uhi = mapping.NewUHugeInt(uint64(v), 0)
	default:
		var i *big.Int
		if i, err = numToBigInt(val); err != nil {
			return mapping.UHugeInt{}, err
		}
		uhi, err = uhugeIntFromNative(i)
	}
	return uhi, err
}

// Map is used to represent DuckDB maps as Go maps.
// Note that Go maps do not preserve key order, so direct comparison operations
// on DuckDB maps may not behave as expected when using this type. Use OrderedMap as an alternative.
// Deprecated: Use OrderedMap instead to preserve key order.
type Map map[any]any

func (m *Map) Scan(v any) error {
	data, ok := v.(OrderedMap)
	if !ok {
		return fmt.Errorf("invalid type `%T` for scanning `Map`, expected `OrderedMap`", v)
	}

	nm := make(map[any]any, data.Len())
	keys := data.Keys()
	vals := data.Values()
	for i, key := range keys {
		nm[key] = vals[i]
	}

	*m = nm
	return nil
}

// OrderedMap is used to represent DuckDB maps while preserving key order.
// Key order is significant in DuckDB maps for direct comparison operations.
//
// NOTE: only supports keys of comparable types (no slices, maps, or functions).
// NOTE: Set and Get use linear search, so performance may degrade with large maps.
//
// Value receivers on MarshalJSON/String let plain OrderedMap values satisfy
// json.Marshaler/fmt.Stringer; Set/Delete/Scan/UnmarshalJSON need pointer receivers.
//
//nolint:recvcheck // value + pointer receivers are intentional (see above)
type OrderedMap struct {
	keys   []any
	values []any
}

func (om *OrderedMap) Keys() []any {
	return append([]any(nil), om.keys...)
}

func (om *OrderedMap) Values() []any {
	return append([]any(nil), om.values...)
}

func (om *OrderedMap) Len() int {
	return len(om.keys)
}

// String implements the fmt.Stringer interface for debugging purposes.
func (om OrderedMap) String() string {
	var sb strings.Builder
	sb.WriteString("OrderedMap{")
	for i, key := range om.keys {
		if i > 0 {
			sb.WriteString(", ")
		}
		fmt.Fprintf(&sb, "%v: %v", key, om.values[i])
	}
	sb.WriteString("}")
	return sb.String()
}

// Set adds or updates a key-value pair, always inserting the key to the end of the map.
// Previous entries with the same key will be removed to ensure only the last value is retained.
func (om *OrderedMap) Set(k, v any) {
	om.Delete(k)

	om.keys = append(om.keys, k)
	om.values = append(om.values, v)
}

func (om *OrderedMap) Get(k any) (any, bool) {
	for i, key := range om.keys {
		if key == k {
			return om.values[i], true
		}
	}
	return nil, false
}

func (om *OrderedMap) Delete(k any) {
	for i, key := range om.keys {
		if key == k {
			om.keys = append(om.keys[:i], om.keys[i+1:]...)
			om.values = append(om.values[:i], om.values[i+1:]...)
			return
		}
	}
}

func (om *OrderedMap) Scan(v any) error {
	data, ok := v.(OrderedMap)
	if !ok {
		return fmt.Errorf("invalid type `%T` for scanning `OrderedMap`, expected `OrderedMap`", v)
	}

	om.keys = data.Keys()
	om.values = data.Values()

	return nil
}

// MarshalJSON encodes the map as a JSON object preserving insertion order.
// Non-string keys are stringified via fmt.Sprintf; they are not recoverable on unmarshal
// (UnmarshalJSON always produces string keys). Nested OrderedMap values are also not
// preserved: they re-encode correctly but decode back as map[string]any.
func (om OrderedMap) MarshalJSON() ([]byte, error) {
	var buf bytes.Buffer
	buf.WriteByte('{')
	for i, key := range om.keys {
		if i > 0 {
			buf.WriteByte(',')
		}
		keyBytes, err := json.Marshal(key)
		if err != nil {
			return nil, err
		}
		// JSON object keys must be strings; wrap non-string keys.
		if len(keyBytes) == 0 || keyBytes[0] != '"' {
			keyBytes, err = json.Marshal(fmt.Sprintf("%v", key))
			if err != nil {
				return nil, err
			}
		}
		buf.Write(keyBytes)
		buf.WriteByte(':')
		valBytes, err := json.Marshal(om.values[i])
		if err != nil {
			return nil, err
		}
		buf.Write(valBytes)
	}
	buf.WriteByte('}')
	return buf.Bytes(), nil
}

// UnmarshalJSON decodes a JSON object into the map, preserving the key order from the
// JSON stream. All keys are decoded as strings; numeric/other key types are not restored.
// JSON null resets the map to empty.
func (om *OrderedMap) UnmarshalJSON(data []byte) error {
	if string(data) == "null" {
		om.keys = nil
		om.values = nil
		return nil
	}
	dec := json.NewDecoder(bytes.NewReader(data))
	t, err := dec.Token()
	if err != nil {
		return err
	}
	if delim, ok := t.(json.Delim); !ok || delim != '{' {
		return fmt.Errorf("expected JSON object, got %v", t)
	}
	om.keys = nil
	om.values = nil
	for dec.More() {
		t, err = dec.Token()
		if err != nil {
			return err
		}
		key, ok := t.(string)
		if !ok {
			return fmt.Errorf("expected string key, got %T", t)
		}
		var val any
		if err = dec.Decode(&val); err != nil {
			return err
		}
		om.keys = append(om.keys, key)
		om.values = append(om.values, val)
	}
	_, err = dec.Token() // closing '}'
	return err
}

func mapKeysField() string {
	return "key"
}

func mapValuesField() string {
	return "value"
}

type Interval struct {
	Days   int32 `json:"days"`
	Months int32 `json:"months"`
	Micros int64 `json:"micros"`
}

func inferInterval(val any) (mapping.Interval, error) {
	var i Interval
	switch v := val.(type) {
	case Interval:
		i = v
	default:
		return mapping.Interval{}, castError(reflect.TypeOf(val).String(), reflectTypeInterval.String())
	}
	return mapping.NewInterval(i.Months, i.Days, i.Micros), nil
}

// Composite can be used as the `Scanner` type for any composite types (maps, lists, structs).
type Composite[T any] struct {
	t T
}

func (s Composite[T]) Get() T {
	return s.t
}

func (s *Composite[T]) Scan(v any) error {
	return mapstructure.Decode(v, &s.t)
}

const max_decimal_width = 38

type Decimal struct {
	Width uint8
	Scale uint8
	Value *big.Int
}

func (d Decimal) Float64() float64 {
	scale := big.NewInt(int64(d.Scale))
	factor := new(big.Float).SetInt(new(big.Int).Exp(big.NewInt(10), scale, nil))
	value := new(big.Float).SetInt(d.Value)
	value.Quo(value, factor)
	f, _ := value.Float64()
	return f
}

func (d Decimal) String() string {
	// Get the sign, and return early, if zero.
	if d.Value.Sign() == 0 {
		return "0"
	}

	// Remove the sign from the string integer value
	var signStr string
	scaleless := d.Value.String()
	if d.Value.Sign() < 0 {
		signStr = "-"
		scaleless = scaleless[1:]
	}

	// Remove all zeros from the right side
	zeroTrimmed := strings.TrimRightFunc(scaleless, func(r rune) bool { return r == '0' })
	scale := int(d.Scale) - (len(scaleless) - len(zeroTrimmed))

	// If the string is still bigger than the scale factor, output it without a decimal point
	if scale <= 0 {
		return signStr + zeroTrimmed + strings.Repeat("0", -1*scale)
	}

	// Pad a number with 0.0's if needed
	if len(zeroTrimmed) <= scale {
		return fmt.Sprintf("%s0.%s%s", signStr, strings.Repeat("0", scale-len(zeroTrimmed)), zeroTrimmed)
	}
	return signStr + zeroTrimmed[:len(zeroTrimmed)-scale] + "." + zeroTrimmed[len(zeroTrimmed)-scale:]
}

type Union struct {
	Value driver.Value `json:"value"`
	Tag   string       `json:"tag"`
}

func castToTime(val any) (time.Time, error) {
	var ti time.Time
	switch v := val.(type) {
	case time.Time:
		ti = v
	default:
		return ti, castError(reflect.TypeOf(val).String(), reflectTypeTime.String())
	}
	return ti, nil
}

func getTSTicks(t Type, val any) (int64, error) {
	ti, err := castToTime(val)
	if err != nil {
		return 0, err
	}

	if t == TYPE_TIMESTAMP_S {
		return ti.Unix(), nil
	}
	if t == TYPE_TIMESTAMP_MS {
		return ti.UnixMilli(), nil
	}

	year := ti.Year()
	if t == TYPE_TIMESTAMP || t == TYPE_TIMESTAMP_TZ {
		if year < -290307 || year > 294246 {
			return 0, conversionError(year, -290307, 294246)
		}
		return ti.UnixMicro(), nil
	}

	// TYPE_TIMESTAMP_NS:
	if year < 1678 || year > 2262 {
		return 0, conversionError(year, -290307, 294246)
	}
	return ti.UnixNano(), nil
}

func inferTimestamp(t Type, val any) (mapping.Timestamp, error) {
	ticks, err := getTSTicks(t, val)
	return mapping.NewTimestamp(ticks), err
}

func inferTimestampS(val any) (mapping.TimestampS, error) {
	ticks, err := getTSTicks(TYPE_TIMESTAMP_S, val)
	return mapping.NewTimestampS(ticks), err
}

func inferTimestampMS(val any) (mapping.TimestampMS, error) {
	ticks, err := getTSTicks(TYPE_TIMESTAMP_MS, val)
	return mapping.NewTimestampMS(ticks), err
}

func inferTimestampNS(val any) (mapping.TimestampNS, error) {
	ticks, err := getTSTicks(TYPE_TIMESTAMP_NS, val)
	return mapping.NewTimestampNS(ticks), err
}

func inferDate[T any](val T) (mapping.Date, error) {
	ti, err := castToTime(val)
	if err != nil {
		return mapping.Date{}, err
	}

	date := mapping.NewDate(int32(ti.Unix() / secondsPerDay))
	return date, err
}

func inferTime(val any) (mapping.Time, error) {
	ticks, err := getTimeTicks(val)
	if err != nil {
		return mapping.Time{}, err
	}
	return mapping.NewTime(ticks), nil
}

func inferTimeTZ(val any) (mapping.TimeTZ, error) {
	ti, err := castToTime(val)
	if err != nil {
		return mapping.TimeTZ{}, err
	}

	// DuckDB stores time as microseconds since 00:00:00.
	base := time.Date(1970, time.January, 1, ti.Hour(), ti.Minute(), ti.Second(), ti.Nanosecond(), time.UTC)
	ticks := base.UnixMicro()

	// Preserve the UTC offset from the input time.
	_, offset := ti.Zone()
	return mapping.CreateTimeTZ(ticks, int32(offset)), nil
}

func getTimeTicks[T any](val T) (int64, error) {
	ti, err := castToTime(val)
	if err != nil {
		return 0, err
	}

	// DuckDB stores time as microseconds since 00:00:00.
	base := time.Date(1970, time.January, 1, ti.Hour(), ti.Minute(), ti.Second(), ti.Nanosecond(), time.UTC)
	return base.UnixMicro(), err
}
