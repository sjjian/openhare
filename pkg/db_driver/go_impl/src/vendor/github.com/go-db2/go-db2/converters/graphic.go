package converters

import (
	"encoding/binary"
	"strings"
	"unicode/utf16"
)

// DecodeUTF16BE decodes a sequence of Big-Endian UTF-16 bytes into a UTF-8 Go string.
func DecodeUTF16BE(b []byte) string {
	if len(b) < 2 {
		return ""
	}
	u16 := make([]uint16, len(b)/2)
	for i := 0; i < len(u16); i++ {
		u16[i] = binary.BigEndian.Uint16(b[i*2 : i*2+2])
	}
	return string(utf16.Decode(u16))
}

// EncodeUTF16BE encodes a UTF-8 Go string into a sequence of Big-Endian UTF-16 bytes.
func EncodeUTF16BE(s string) []byte {
	u16 := utf16.Encode([]rune(s))
	buf := make([]byte, len(u16)*2)
	for i, v := range u16 {
		binary.BigEndian.PutUint16(buf[i*2:i*2+2], v)
	}
	return buf
}

// PadGraphicUTF16BE pads a UTF-16 BE byte slice with DBCS spaces (0x0020) up to targetCharLen characters.
func PadGraphicUTF16BE(b []byte, targetCharLen int) []byte {
	currentChars := len(b) / 2
	if currentChars >= targetCharLen {
		return b[:targetCharLen*2]
	}
	res := make([]byte, targetCharLen*2)
	copy(res, b)
	for i := currentChars; i < targetCharLen; i++ {
		binary.BigEndian.PutUint16(res[i*2:i*2+2], 0x0020)
	}
	return res
}

// TrimRightGraphicSpaces trims trailing spaces (including DBCS / Ideographic space U+3000 and nulls) from a graphic string.
func TrimRightGraphicSpaces(s string) string {
	return strings.TrimRight(s, " \t\r\n\u0020\u3000\u0000")
}
