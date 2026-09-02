package converters

import (
	"bytes"
	"database/sql/driver"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"math"
	"strings"
	"time"
	"unicode/utf16"

	"github.com/go-db2/go-db2/types"
)

// FDODSC generates the FDODSC descriptor bytes for a column parameter.
func FDODSC(sqlType types.SQLType, sqllen int64, prec, scale int) []byte {
	switch sqlType {
	case types.SQLTypeVarChar, types.SQLTypeNVarChar, types.SQLTypeChar, types.SQLTypeNChar:
		return []byte{0x39, 0x3F, 0xFF}
	case types.SQLTypeSmall, types.SQLTypeNSmall:
		return []byte{0x05, 0x00, 0x02}
	case types.SQLTypeInteger, types.SQLTypeNInteger:
		return []byte{0x03, 0x00, 0x04}
	case types.SQLTypeBigInt, types.SQLTypeNBigInt:
		return []byte{0x17, 0x00, 0x08}
	case types.SQLTypeFloat, types.SQLTypeNFloat:
		if sqllen == 4 {
			return []byte{0x0D, 0x00, 0x04}
		}
		return []byte{0x0B, 0x00, 0x08}
	case types.SQLTypeDate, types.SQLTypeNDate:
		return []byte{0x21, 0x00, 0x0A}
	case types.SQLTypeTime, types.SQLTypeNTime:
		return []byte{0x23, 0x00, 0x08}
	case types.SQLTypeTimestamp, types.SQLTypeNTimestamp:
		return []byte{0x25, 0x00, 0x20}
	case types.SQLTypeBoolean, types.SQLTypeNBoolean:
		if sqllen == 2 {
			return []byte{0x05, 0x00, 0x02}
		}
		return []byte{0xBF, 0x00, 0x01}
	case types.SQLTypeBlob, types.SQLTypeNBlob:
		return []byte{0xC9, 0x80, 0x02}
	case types.SQLTypeClob, types.SQLTypeNClob, types.SQLTypeDbClob, types.SQLTypeNDbClob,
		types.SQLTypeClobLocator, types.SQLTypeNClobLocator, types.SQLTypeDbClobLocator, types.SQLTypeNDbClobLocator:
		return []byte{0x39, 0x3F, 0xFF}
	case types.SQLTypeGraphic, types.SQLTypeNGraphic:
		return []byte{0x37, byte(sqllen >> 8), byte(sqllen & 0xFF)}
	case types.SQLTypeVarGraph, types.SQLTypeNVarGraph,
		types.SQLTypeLonGraph, types.SQLTypeNLonGraph:
		return []byte{0x39, 0x3F, 0xFF}
	case types.SQLTypeBinary, types.SQLTypeNBinary:
		return []byte{0x27, byte(sqllen >> 8), byte(sqllen & 0xFF)}
	case types.SQLTypeDecimal, types.SQLTypeNDecimal:
		return []byte{0x0F, byte(prec), byte(scale)}
	case types.SQLTypeDecFloat, types.SQLTypeNDecFloat:
		if sqllen == 16 {
			return []byte{0xBB, 0x00, 0x10}
		}
		return []byte{0xBB, 0x00, 0x08}
	case types.SQLTypeXML, types.SQLTypeNXML:
		return []byte{0x39, 0x3F, 0xFF}
	default:
		return []byte{0x39, 0x3F, 0xFF}
	}
}

// FDODTA encodes a Go value into the DRDA wire format for a given column type.
func FDODTA(sqlType types.SQLType, sqllen int64, prec, scale int, val any, endian binary.ByteOrder) ([]byte, error) {
	// Handle driver.Valuer
	if valuer, ok := val.(driver.Valuer); ok {
		var err error
		val, err = valuer.Value()
		if err != nil {
			return nil, err
		}
	}

	if val == nil {
		return []byte{0xFF}, nil // Null indicator
	}

	switch sqlType {
	case types.SQLTypeVarChar, types.SQLTypeNVarChar, types.SQLTypeChar, types.SQLTypeNChar,
		types.SQLTypeClob, types.SQLTypeNClob, types.SQLTypeDbClob, types.SQLTypeNDbClob,
		types.SQLTypeClobLocator, types.SQLTypeNClobLocator, types.SQLTypeDbClobLocator, types.SQLTypeNDbClobLocator,
		types.SQLTypeVarGraph, types.SQLTypeNVarGraph, types.SQLTypeLonGraph, types.SQLTypeNLonGraph:
		switch v := val.(type) {
		case []byte:
			b := make([]byte, 3+len(v))
			b[0] = 0x00 // Not null
			binary.BigEndian.PutUint16(b[1:3], uint16(len(v)))
			copy(b[3:], v)
			return b, nil
		default:
			str := fmt.Sprint(v)
			utf16Runes := utf16.Encode([]rune(str))
			utf16Bytes := make([]byte, len(utf16Runes)*2)
			for i, r := range utf16Runes {
				binary.BigEndian.PutUint16(utf16Bytes[i*2:i*2+2], r)
			}
			b := make([]byte, 3+len(utf16Bytes))
			b[0] = 0x00
			binary.BigEndian.PutUint16(b[1:3], uint16(len(utf16Runes)))
			copy(b[3:], utf16Bytes)
			return b, nil
		}

	case types.SQLTypeGraphic, types.SQLTypeNGraphic:
		str := fmt.Sprint(val)
		utf16Bytes := EncodeUTF16BE(str)
		targetChars := int(sqllen)
		if targetChars <= 0 {
			targetChars = len(utf16Bytes) / 2
		}
		padded := PadGraphicUTF16BE(utf16Bytes, targetChars)
		b := make([]byte, 1+len(padded))
		b[0] = 0x00
		copy(b[1:], padded)
		return b, nil

	case types.SQLTypeSmall, types.SQLTypeNSmall:
		n := toInt64(val)
		var buf [3]byte
		buf[0] = 0x00
		endian.PutUint16(buf[1:3], uint16(int16(n)))
		return buf[:], nil

	case types.SQLTypeInteger, types.SQLTypeNInteger:
		n := toInt64(val)
		var buf [5]byte
		buf[0] = 0x00
		endian.PutUint32(buf[1:5], uint32(int32(n)))
		return buf[:], nil

	case types.SQLTypeBigInt, types.SQLTypeNBigInt:
		n := toInt64(val)
		var buf [9]byte
		buf[0] = 0x00
		endian.PutUint64(buf[1:9], uint64(n))
		return buf[:], nil

	case types.SQLTypeFloat, types.SQLTypeNFloat:
		f := toFloat64(val)
		if sqllen == 4 {
			var buf [5]byte
			buf[0] = 0x00
			endian.PutUint32(buf[1:5], math.Float32bits(float32(f)))
			return buf[:], nil
		}
		var buf [9]byte
		buf[0] = 0x00
		endian.PutUint64(buf[1:9], math.Float64bits(f))
		return buf[:], nil

	case types.SQLTypeBoolean, types.SQLTypeNBoolean:
		bVal := toBool(val)
		if sqllen == 2 {
			var buf [3]byte
			buf[0] = 0x00
			if bVal {
				endian.PutUint16(buf[1:3], 1)
			}
			return buf[:], nil
		}
		byteVal := byte(0)
		if bVal {
			byteVal = 1
		}
		return []byte{0x00, byteVal}, nil

	case types.SQLTypeDate, types.SQLTypeNDate:
		t, err := toTime(val)
		if err != nil {
			return nil, err
		}
		dateStr := t.Format("2006-01-02")
		return append([]byte{0x00}, []byte(dateStr)...), nil

	case types.SQLTypeTime, types.SQLTypeNTime:
		t, err := toTime(val)
		if err != nil {
			return nil, err
		}
		timeStr := t.Format("15:04:05")
		return append([]byte{0x00}, []byte(timeStr)...), nil

	case types.SQLTypeTimestamp, types.SQLTypeNTimestamp:
		t, err := toTime(val)
		if err != nil {
			return nil, err
		}
		tsStr := t.Format("2006-01-02-15.04.05.000000      ")
		return append([]byte{0x00}, []byte(tsStr)...), nil

	case types.SQLTypeBinary, types.SQLTypeNBinary:
		b := toBytes(val)
		padded := make([]byte, sqllen)
		copy(padded, b)
		return append([]byte{0x00}, padded...), nil

	case types.SQLTypeVarBinary, types.SQLTypeNVarBinary, types.SQLTypeBlob, types.SQLTypeNBlob:
		b := toBytes(val)
		res := make([]byte, 3+len(b))
		res[0] = 0x00
		binary.BigEndian.PutUint16(res[1:3], uint16(len(b)))
		copy(res[3:], b)
		return res, nil

	case types.SQLTypeDecimal, types.SQLTypeNDecimal:
		return encodePackedDecimalParam(val, prec, scale)

	case types.SQLTypeDecFloat, types.SQLTypeNDecFloat:
		nBytes := 8
		if sqllen == 16 {
			nBytes = 16
		}
		dfpBytes, err := EncodeDFP(val, nBytes)
		if err != nil {
			return nil, err
		}
		return append([]byte{0x00}, dfpBytes...), nil

	case types.SQLTypeXML, types.SQLTypeNXML:
		str := fmt.Sprint(val)
		utf16Runes := utf16.Encode([]rune(str))
		utf16Bytes := make([]byte, len(utf16Runes)*2)
		for i, r := range utf16Runes {
			binary.BigEndian.PutUint16(utf16Bytes[i*2:i*2+2], r)
		}
		b := make([]byte, 3+len(utf16Bytes))
		b[0] = 0x00
		binary.BigEndian.PutUint16(b[1:3], uint16(len(utf16Bytes)))
		copy(b[3:], utf16Bytes)
		return b, nil

	default:
		// Fallback as UTF-16 string
		str := fmt.Sprint(val)
		utf16Runes := utf16.Encode([]rune(str))
		utf16Bytes := make([]byte, len(utf16Runes)*2)
		for i, r := range utf16Runes {
			binary.BigEndian.PutUint16(utf16Bytes[i*2:i*2+2], r)
		}
		b := make([]byte, 3+len(utf16Bytes))
		b[0] = 0x00
		binary.BigEndian.PutUint16(b[1:3], uint16(len(utf16Bytes)))
		copy(b[3:], utf16Bytes)
		return b, nil
	}
}

func encodePackedDecimalParam(val any, prec, scale int) ([]byte, error) {
	str := fmt.Sprint(val)
	// Normalize decimal string
	negative := strings.HasPrefix(str, "-")
	if negative {
		str = str[1:]
	}
	parts := strings.Split(str, ".")
	intPart := parts[0]
	fracPart := ""
	if len(parts) > 1 {
		fracPart = parts[1]
	}
	if len(fracPart) < scale {
		fracPart += strings.Repeat("0", scale-len(fracPart))
	} else if len(fracPart) > scale {
		fracPart = fracPart[:scale]
	}
	digits := intPart + fracPart
	if len(digits) < prec {
		digits = strings.Repeat("0", prec-len(digits)) + digits
	} else if len(digits) > prec {
		digits = digits[len(digits)-prec:]
	}
	signChar := "c"
	if negative {
		signChar = "d"
	}
	hexStr := digits + signChar
	if len(hexStr)%2 != 0 {
		hexStr = "0" + hexStr
	}
	decoded, err := hex.DecodeString(hexStr)
	if err != nil {
		return nil, err
	}
	return append([]byte{0x00}, decoded...), nil
}

func toInt64(val any) int64 {
	switch v := val.(type) {
	case int:
		return int64(v)
	case int8:
		return int64(v)
	case int16:
		return int64(v)
	case int32:
		return int64(v)
	case int64:
		return v
	case uint:
		return int64(v)
	case uint8:
		return int64(v)
	case uint16:
		return int64(v)
	case uint32:
		return int64(v)
	case uint64:
		return int64(v)
	case float32:
		return int64(v)
	case float64:
		return int64(v)
	default:
		return 0
	}
}

func toFloat64(val any) float64 {
	switch v := val.(type) {
	case float64:
		return v
	case float32:
		return float64(v)
	case int:
		return float64(v)
	case int64:
		return float64(v)
	default:
		return 0
	}
}

func toBool(val any) bool {
	switch v := val.(type) {
	case bool:
		return v
	case int, int64:
		return toInt64(val) != 0
	case string:
		return strings.EqualFold(v, "true") || v == "1"
	default:
		return false
	}
}

func toTime(val any) (time.Time, error) {
	switch v := val.(type) {
	case time.Time:
		return v, nil
	case string:
		v = strings.TrimSpace(v)
		layouts := []string{
			"2006-01-02 15:04:05.999999999",
			"2006-01-02 15:04:05",
			"2006-01-02T15:04:05.999999999",
			"2006-01-02T15:04:05",
			"2006-01-02-15.04.05.000000",
			"2006-01-02",
			"15:04:05",
			time.RFC3339Nano,
			time.RFC3339,
		}
		for _, l := range layouts {
			if t, err := time.Parse(l, v); err == nil {
				return t, nil
			}
		}
		return time.Time{}, fmt.Errorf("db2: cannot parse %q as valid date/time format", v)
	default:
		return time.Time{}, fmt.Errorf("db2: cannot convert %T to time.Time", val)
	}
}

func toBytes(val any) []byte {
	switch v := val.(type) {
	case []byte:
		return v
	case string:
		return []byte(v)
	default:
		return []byte(fmt.Sprint(v))
	}
}

// BuildSQLDTA constructs the complete SQLDTA object containing FDODSC and FDODTA blocks for the parameters.
// It supports more than 84 parameters by structuring descriptors into groups to avoid integer overflow.
func BuildSQLDTA(colTypes []types.SQLType, colLens []int64, precs, scales []int, args []any, endian binary.ByteOrder) ([]byte, error) {
	numParams := len(args)
	if len(colTypes) != numParams || len(colLens) != numParams || len(precs) != numParams || len(scales) != numParams {
		return nil, fmt.Errorf("db2: mismatched parameter column metadata lengths (expected %d, got %d colTypes)", numParams, len(colTypes))
	}

	var fdodsc []byte
	var fdodta bytes.Buffer
	fdodta.Grow(numParams * 32)

	// In DRDA, FDODSC groups parameters in triplets (LL, 0x76, 0xD0).
	// A single triplet group can describe up to 84 parameters ((255 - 3) / 3 = 84).
	// For numParams > 84, we divide into multiple groups of up to 84 parameters each to avoid uint8 overflow.
	for i := 0; i < numParams; {
		chunkSize := numParams - i
		if chunkSize > 84 {
			chunkSize = 84
		}

		groupHeader := []byte{
			byte((1 + chunkSize) * 3),
			0x76,
			0xD0,
		}
		fdodsc = append(fdodsc, groupHeader...)

		for j := 0; j < chunkSize; j++ {
			idx := i + j
			st := colTypes[idx]
			sl := colLens[idx]
			p := precs[idx]
			s := scales[idx]

			dscBytes := FDODSC(st, sl, p, s)
			fdodsc = append(fdodsc, dscBytes...)

			dtaBytes, err := FDODTA(st, sl, p, s, args[idx], endian)
			if err != nil {
				return nil, fmt.Errorf("failed to encode parameter %d: %w", idx+1, err)
			}
			fdodta.Write(dtaBytes)
		}

		i += chunkSize
	}

	dtaBytes := fdodta.Bytes()
	if (len(fdodsc)+len(dtaBytes))%2 != 0 {
		dtaBytes = append([]byte{0x00}, dtaBytes...)
	}

	fdodsc = append(fdodsc, 0x06, 0x71, 0xE4, 0xD0, 0x00, 0x01)

	// Wrap FDODSC and FDODTA
	bodyLen := 4 + (4 + len(fdodsc)) + (4 + len(dtaBytes))
	if bodyLen > 65529 {
		return nil, fmt.Errorf("db2: parameter payload length %d exceeds maximum DRDA DSS limit of 65529 bytes", bodyLen)
	}

	sqldta := make([]byte, bodyLen)

	// SQLDTA object header
	binary.BigEndian.PutUint16(sqldta[0:2], uint16(bodyLen))
	binary.BigEndian.PutUint16(sqldta[2:4], 0x2412) // SQLDTA

	// FDODSC object header
	binary.BigEndian.PutUint16(sqldta[4:6], uint16(4+len(fdodsc)))
	binary.BigEndian.PutUint16(sqldta[6:8], 0x0010) // FDODSC
	copy(sqldta[8:8+len(fdodsc)], fdodsc)

	// FDODTA object header
	offset := 8 + len(fdodsc)
	binary.BigEndian.PutUint16(sqldta[offset:offset+2], uint16(4+len(dtaBytes)))
	binary.BigEndian.PutUint16(sqldta[offset+2:offset+4], 0x147A) // FDODTA
	copy(sqldta[offset+4:], dtaBytes)

	return sqldta, nil
}
