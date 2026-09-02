package converters

import (
	"fmt"
	"math/big"
	"strconv"
	"strings"
)

// dpdDecode decodes a 10-bit DPD (Densely Packed Decimal) group into 3 decimal digits.
func dpdDecode(dpd uint16) (int, int, int) {
	b9 := (dpd >> 9) & 1
	b8 := (dpd >> 8) & 1
	b7 := (dpd >> 7) & 1
	b6 := (dpd >> 6) & 1
	b5 := (dpd >> 5) & 1
	b4 := (dpd >> 4) & 1
	b3 := (dpd >> 3) & 1
	b2 := (dpd >> 2) & 1
	b1 := (dpd >> 1) & 1
	b0 := dpd & 1

	if b3 == 0 {
		return int(b9*4 + b8*2 + b7), int(b6*4 + b5*2 + b4), int(b2*4 + b1*2 + b0)
	}
	if b2 == 0 && b1 == 0 {
		return int(b9*4 + b8*2 + b7), int(b6*4 + b5*2 + b4), int(8 + b0)
	}
	if b2 == 0 && b1 == 1 {
		return int(b9*4 + b8*2 + b7), int(8 + b4), int(b6*4 + b5*2 + b0)
	}
	if b2 == 1 && b1 == 0 {
		return int(8 + b7), int(b6*4 + b5*2 + b4), int(b9*4 + b8*2 + b0)
	}
	// b3=b2=b1=1
	if b6 == 0 && b5 == 0 {
		return int(8 + b7), int(8 + b4), int(b9*4 + b8*2 + b0)
	}
	if b6 == 0 && b5 == 1 {
		return int(8 + b7), int(b9*4 + b8*2 + b4), int(8 + b0)
	}
	if b6 == 1 && b5 == 0 {
		return int(b9*4 + b8*2 + b7), int(8 + b4), int(8 + b0)
	}
	return int(8 + b7), int(8 + b4), int(8 + b0)
}

// dpdEncode encodes 3 decimal digits (0-9) into a 10-bit DPD value.
func dpdEncode(d2, d1, d0 int) uint16 {
	h2, h1, h0 := d2 >= 8, d1 >= 8, d0 >= 8
	v2, v1, v0 := d2&7, d1&7, d0&7

	if !h2 && !h1 && !h0 {
		return uint16((v2 << 7) | (v1 << 4) | v0)
	} else if !h2 && !h1 && h0 {
		return uint16((v2 << 7) | (v1 << 4) | 8 | (v0 & 1))
	} else if !h2 && h1 && !h0 {
		return uint16((v2 << 7) | (((v0 >> 2) & 1) << 6) | (((v0 >> 1) & 1) << 5) | ((v1 & 1) << 4) | (1 << 3) | (1 << 1) | (v0 & 1))
	} else if h2 && !h1 && !h0 {
		return uint16((((v0 >> 2) & 1) << 9) | (((v0 >> 1) & 1) << 8) | ((v2 & 1) << 7) | (v1 << 4) | (1 << 3) | (1 << 2) | (v0 & 1))
	} else if h2 && h1 && !h0 {
		return uint16((((v0 >> 2) & 1) << 9) | (((v0 >> 1) & 1) << 8) | ((v2 & 1) << 7) | ((v1 & 1) << 4) | (1 << 3) | (1 << 2) | (1 << 1) | (v0 & 1))
	} else if h2 && !h1 && h0 {
		return uint16((((v1 >> 2) & 1) << 9) | (((v1 >> 1) & 1) << 8) | ((v2 & 1) << 7) | (1 << 5) | ((v1 & 1) << 4) | (1 << 3) | (1 << 2) | (1 << 1) | (v0 & 1))
	} else if !h2 && h1 && h0 {
		return uint16((v2 << 7) | (1 << 6) | ((v1 & 1) << 4) | (1 << 3) | (1 << 2) | (1 << 1) | (v0 & 1))
	}
	return uint16(((v2 & 1) << 7) | (1 << 6) | (1 << 5) | ((v1 & 1) << 4) | (1 << 3) | (1 << 2) | (1 << 1) | (v0 & 1))
}

// DecodeDFP decodes IEEE 754-2008 DPD decimal floating-point bytes (8 or 16 bytes) into a string representation.
func DecodeDFP(data []byte) (string, error) {
	nBytes := len(data)
	if nBytes != 8 && nBytes != 16 {
		return "", fmt.Errorf("invalid DFP byte length: %d (must be 8 or 16)", nBytes)
	}

	var bias, nDpdGroups, expContBits int
	if nBytes == 8 {
		bias = 398
		nDpdGroups = 5
		expContBits = 8
	} else {
		bias = 6176
		nDpdGroups = 11
		expContBits = 12
	}

	coeffContBits := nDpdGroups * 10
	totalBits := nBytes * 8

	w := new(big.Int).SetBytes(data)

	// sign = (w >> (totalBits - 1)) & 1
	signBig := new(big.Int).Rsh(w, uint(totalBits-1))
	sign := signBig.Bit(0) == 1

	// G = (w >> (totalBits - 6)) & 0x1F
	gBig := new(big.Int).Rsh(w, uint(totalBits-6))
	g := int(gBig.Int64() & 0x1F)

	// E = (w >> coeffContBits) & ((1 << expContBits) - 1)
	eMask := (1 << expContBits) - 1
	eBig := new(big.Int).Rsh(w, uint(coeffContBits))
	e := int(eBig.Int64()) & eMask

	// T = w & ((1 << coeffContBits) - 1)
	tMask := new(big.Int).Sub(new(big.Int).Lsh(big.NewInt(1), uint(coeffContBits)), big.NewInt(1))
	t := new(big.Int).And(w, tMask)

	// Special values: Infinity and NaN
	if g >= 0x1E {
		if (g & 0x01) != 0 {
			return "NaN", nil
		}
		if sign {
			return "-Infinity", nil
		}
		return "Infinity", nil
	}

	var biasedExp, leadingDigit int
	if g >= 0x18 {
		biasedExp = (((g >> 1) & 0x03) << expContBits) | e
		leadingDigit = 8 + (g & 1)
	} else {
		biasedExp = ((g >> 3) << expContBits) | e
		leadingDigit = g & 0x07
	}

	digits := []int{leadingDigit}
	for i := nDpdGroups - 1; i >= 0; i-- {
		grpBig := new(big.Int).Rsh(t, uint(i*10))
		grp := uint16(grpBig.Int64() & 0x3FF)
		d2, d1, d0 := dpdDecode(grp)
		digits = append(digits, d2, d1, d0)
	}

	exp := biasedExp - bias
	return formatDFP(sign, digits, exp), nil
}

func formatDFP(sign bool, digits []int, exp int) string {
	// Strip leading zeros
	start := 0
	for start < len(digits)-1 && digits[start] == 0 {
		start++
	}
	significant := digits[start:]

	// Check all zeros
	if len(significant) == 1 && significant[0] == 0 {
		if sign {
			return "-0"
		}
		return "0"
	}

	var b strings.Builder
	if sign {
		b.WriteByte('-')
	}

	digitStr := make([]byte, len(significant))
	for i, d := range significant {
		digitStr[i] = '0' + byte(d)
	}
	sDigits := string(digitStr)

	numDigits := len(sDigits)
	dotPos := numDigits + exp

	if dotPos > 0 && dotPos <= numDigits {
		// e.g. 12345 with exp -2 -> dotPos 3 -> "123.45"
		if dotPos == numDigits {
			b.WriteString(sDigits)
		} else {
			b.WriteString(sDigits[:dotPos])
			b.WriteByte('.')
			b.WriteString(sDigits[dotPos:])
		}
	} else if dotPos > numDigits && dotPos <= numDigits+10 {
		// e.g. 12 with exp 2 -> "1200"
		b.WriteString(sDigits)
		b.WriteString(strings.Repeat("0", dotPos-numDigits))
	} else if dotPos <= 0 && dotPos >= -6 {
		// e.g. 12 with exp -3 -> "0.012"
		b.WriteString("0.")
		b.WriteString(strings.Repeat("0", -dotPos))
		b.WriteString(sDigits)
	} else {
		// Scientific notation
		if numDigits == 1 {
			b.WriteString(sDigits)
		} else {
			b.WriteByte(sDigits[0])
			b.WriteByte('.')
			b.WriteString(sDigits[1:])
		}
		sciExp := exp + numDigits - 1
		b.WriteByte('E')
		if sciExp >= 0 {
			b.WriteByte('+')
		}
		b.WriteString(strconv.Itoa(sciExp))
	}

	return b.String()
}

// EncodeDFP encodes a value into IEEE 754-2008 DPD decimal floating-point bytes (8 or 16 bytes).
func EncodeDFP(val any, nBytes int) ([]byte, error) {
	if nBytes != 8 && nBytes != 16 {
		nBytes = 8
	}

	var bias, nDpdGroups, expContBits, maxDigits int
	if nBytes == 8 {
		bias = 398
		nDpdGroups = 5
		expContBits = 8
		maxDigits = 16
	} else {
		bias = 6176
		nDpdGroups = 11
		expContBits = 12
		maxDigits = 34
	}

	coeffContBits := nDpdGroups * 10
	totalBits := nBytes * 8

	str := strings.TrimSpace(fmt.Sprint(val))
	if str == "" || str == "0" {
		biasedExp := bias
		g := (biasedExp >> expContBits) << 3
		e := biasedExp & ((1 << expContBits) - 1)
		w := new(big.Int).Or(
			new(big.Int).Lsh(big.NewInt(int64(g)), uint(totalBits-6)),
			new(big.Int).Lsh(big.NewInt(int64(e)), uint(coeffContBits)),
		)
		b := w.Bytes()
		if len(b) < nBytes {
			padded := make([]byte, nBytes)
			copy(padded[nBytes-len(b):], b)
			return padded, nil
		}
		return b, nil
	}

	sign := false
	if strings.HasPrefix(str, "-") {
		sign = true
		str = str[1:]
	} else if strings.HasPrefix(str, "+") {
		str = str[1:]
	}

	if strings.EqualFold(str, "infinity") || strings.EqualFold(str, "inf") {
		w := new(big.Int).Lsh(big.NewInt(0x1E), uint(totalBits-6))
		if sign {
			w.Or(w, new(big.Int).Lsh(big.NewInt(1), uint(totalBits-1)))
		}
		b := w.Bytes()
		padded := make([]byte, nBytes)
		copy(padded[nBytes-len(b):], b)
		return padded, nil
	}
	if strings.EqualFold(str, "nan") {
		w := new(big.Int).Lsh(big.NewInt(0x1F), uint(totalBits-6))
		b := w.Bytes()
		padded := make([]byte, nBytes)
		copy(padded[nBytes-len(b):], b)
		return padded, nil
	}

	// Parse mantissa and exponent from string
	var mantissaStr string
	exp := 0

	if idx := strings.IndexAny(str, "eE"); idx != -1 {
		eVal, _ := strconv.Atoi(str[idx+1:])
		exp += eVal
		str = str[:idx]
	}

	if dotIdx := strings.Index(str, "."); dotIdx != -1 {
		intPart := str[:dotIdx]
		fracPart := str[dotIdx+1:]
		exp -= len(fracPart)
		mantissaStr = intPart + fracPart
	} else {
		mantissaStr = str
	}

	mantissaStr = strings.TrimLeft(mantissaStr, "0")
	if mantissaStr == "" {
		mantissaStr = "0"
	}

	if len(mantissaStr) > maxDigits {
		mantissaStr = mantissaStr[:maxDigits]
	}

	// Pad with leading zeros to maxDigits
	digits := make([]int, maxDigits)
	padLen := maxDigits - len(mantissaStr)
	for i := 0; i < len(mantissaStr); i++ {
		digits[padLen+i] = int(mantissaStr[i] - '0')
	}

	leadingDigit := digits[0]
	contDigits := digits[1:]

	nContDigits := nDpdGroups * 3
	if len(contDigits) < nContDigits {
		extra := make([]int, nContDigits-len(contDigits))
		contDigits = append(extra, contDigits...)
	}

	biasedExp := exp + bias
	var g int
	if leadingDigit >= 8 {
		g = 0x18 | (((biasedExp >> expContBits) & 0x03) << 1) | (leadingDigit - 8)
	} else {
		g = ((biasedExp >> expContBits) << 3) | leadingDigit
	}
	e := biasedExp & ((1 << expContBits) - 1)

	var tBig = big.NewInt(0)
	for i := 0; i < nDpdGroups; i++ {
		dpdVal := dpdEncode(contDigits[i*3], contDigits[i*3+1], contDigits[i*3+2])
		tBig.Lsh(tBig, 10)
		tBig.Or(tBig, big.NewInt(int64(dpdVal)))
	}

	w := new(big.Int).Lsh(big.NewInt(int64(g)), uint(totalBits-6))
	w.Or(w, new(big.Int).Lsh(big.NewInt(int64(e)), uint(coeffContBits)))
	w.Or(w, tBig)

	if sign {
		w.Or(w, new(big.Int).Lsh(big.NewInt(1), uint(totalBits-1)))
	}

	b := w.Bytes()
	if len(b) < nBytes {
		padded := make([]byte, nBytes)
		copy(padded[nBytes-len(b):], b)
		return padded, nil
	} else if len(b) > nBytes {
		return b[len(b)-nBytes:], nil
	}
	return b, nil
}
