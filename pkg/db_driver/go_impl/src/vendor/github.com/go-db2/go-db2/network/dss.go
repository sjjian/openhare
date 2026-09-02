package network

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"
)

// DSS Magic and Constants
const (
	DSSMagic byte = 0xD0 // DRDA Data Stream Structure Magic Identifier

	// DSS Types (low 4 bits of flag byte)
	DSSTypeRequest uint8 = 1 // Request DSS (RQSDSS)
	DSSTypeReply   uint8 = 2 // Reply DSS (RPYDSS)
	DSSTypeObject  uint8 = 3 // Object DSS (OBJDSS)
	DSSTypeComm    uint8 = 4 // Communications DSS

	// DSS Flag bitmasks
	DSSFlagChained uint8 = 0x40 // Bit 6: Chained to next DSS packet (0b01000000)
	DSSFlagError   uint8 = 0x20 // Bit 5: DSS Error (0b00100000)
	DSSFlagSameID  uint8 = 0x10 // Bit 4: Next DSS has same correlation ID (0b00010000)
)

var (
	// ErrInvalidDSSMagic is returned when the DSS header does not begin with 0xD0.
	ErrInvalidDSSMagic = errors.New("invalid DSS packet: missing 0xD0 magic identifier")
	// ErrTruncatedDSS is returned when fewer bytes than expected are read from the stream.
	ErrTruncatedDSS = errors.New("truncated DSS packet received")
)

// DSSHeader represents the 6-byte DRDA Data Stream Structure header.
type DSSHeader struct {
	Length        uint16 // Total DSS length including the 6-byte header
	Type          uint8  // DSS Type (1=Request, 2=Reply, 3=Object)
	Chained       bool   // True if chained to a subsequent DSS
	SameID        bool   // True if next DSS shares the same correlation ID
	HasError      bool   // True if error flag is set
	CorrelationID uint16 // Correlation identifier
}

// BuildDSSHeader constructs a 6-byte DSS header.
func BuildDSSHeader(payloadLen int, dssType uint8, chained, sameID, hasError bool, correlationID uint16) []byte {
	totalLen := uint16(payloadLen + 6)
	hdr := make([]byte, 6)
	binary.BigEndian.PutUint16(hdr[0:2], totalLen)
	hdr[2] = DSSMagic

	flags := dssType & 0x0F
	if chained {
		flags |= DSSFlagChained
	}
	if sameID {
		flags |= DSSFlagSameID
	}
	if hasError {
		flags |= DSSFlagError
	}
	hdr[3] = flags
	binary.BigEndian.PutUint16(hdr[4:6], correlationID)
	return hdr
}

// WriteRequestDSS writes a single request DSS packet containing a DDM payload to the writer.
// It automatically determines whether the payload should be tagged as Request DSS or Object DSS.
// Returns the next correlation ID to use.
func WriteRequestDSS(w io.Writer, payload []byte, curID uint16, nextHasSameID, lastPacket bool) (uint16, error) {
	if len(payload) < 4 {
		return curID, errors.New("payload too short for DDM object")
	}

	codePoint := CodePoint(binary.BigEndian.Uint16(payload[2:4]))
	dssType := DSSTypeRequest
	if codePoint == CodePointSQLSTT || codePoint == CodePointSQLATTR || codePoint == CodePointSQLDTA || codePoint == CodePointEXTDTA {
		dssType = DSSTypeObject
	}

	const maxChunkSize = 65529 // 65535 - 6 bytes header
	offset := 0
	totalLen := len(payload)

	for offset < totalLen {
		chunkEnd := offset + maxChunkSize
		isFinalChunk := false
		if chunkEnd >= totalLen {
			chunkEnd = totalLen
			isFinalChunk = true
		}

		chunk := payload[offset:chunkEnd]
		chained := !lastPacket || !isFinalChunk

		var hdr [6]byte
		binary.BigEndian.PutUint16(hdr[0:2], uint16(len(chunk)+6))
		hdr[2] = DSSMagic

		flags := dssType & 0x0F
		if chained {
			flags |= DSSFlagChained
		}
		if nextHasSameID || !isFinalChunk {
			flags |= DSSFlagSameID
		}
		hdr[3] = flags
		binary.BigEndian.PutUint16(hdr[4:6], curID)

		if _, err := w.Write(hdr[:]); err != nil {
			return curID, fmt.Errorf("failed to write DSS header: %w", err)
		}
		if _, err := w.Write(chunk); err != nil {
			return curID, fmt.Errorf("failed to write DSS payload: %w", err)
		}

		offset = chunkEnd
	}

	if !nextHasSameID {
		curID++
	}

	return curID, nil
}

// ReadDSS reads a complete DSS packet from the reader.
// Returns the DSS header, the outer DDM codepoint, the payload bytes, a boolean indicating if more query data pages follow, and an error.
func ReadDSS(r io.Reader) (*DSSHeader, CodePoint, []byte, bool, error) {
	var hdrBuf [6]byte
	if _, err := io.ReadFull(r, hdrBuf[:]); err != nil {
		return nil, 0, nil, false, err
	}

	if hdrBuf[2] != DSSMagic {
		return nil, 0, nil, false, fmt.Errorf("%w: got 0x%02X", ErrInvalidDSSMagic, hdrBuf[2])
	}

	dssLen := binary.BigEndian.Uint16(hdrBuf[0:2])
	flags := hdrBuf[3]
	dssType := flags & 0x0F
	chained := (flags & DSSFlagChained) != 0
	sameID := (flags & DSSFlagSameID) != 0
	hasError := (flags & DSSFlagError) != 0
	correlationID := binary.BigEndian.Uint16(hdrBuf[4:6])

	header := &DSSHeader{
		Length:        dssLen,
		Type:          dssType,
		Chained:       chained,
		SameID:        sameID,
		HasError:      hasError,
		CorrelationID: correlationID,
	}

	// Read DDM Object Header (2 bytes length + 2 bytes Codepoint)
	ddmHdr := make([]byte, 4)
	if _, err := io.ReadFull(r, ddmHdr); err != nil {
		return header, 0, nil, false, fmt.Errorf("failed to read DDM header: %w", err)
	}

	objLen := binary.BigEndian.Uint16(ddmHdr[0:2])
	codePoint := CodePoint(binary.BigEndian.Uint16(ddmHdr[2:4]))
	moreData := false

	// Handle standard or multi-page continuing query data (QRYDTA)
	if dssLen == 0xFFFF {
		// Large Query Data continuation block
		obj := make([]byte, 32757) // 0x7FFF - 6 (DSS) - 4 (DDM)
		if _, err := io.ReadFull(r, obj); err != nil {
			return header, codePoint, nil, false, err
		}

		nextLenBuf := make([]byte, 2)
		if _, err := io.ReadFull(r, nextLenBuf); err != nil {
			return header, codePoint, nil, false, err
		}
		nextLen := binary.BigEndian.Uint16(nextLenBuf)
		if nextLen > 2 {
			extra := make([]byte, nextLen-2)
			if _, err := io.ReadFull(r, extra); err != nil {
				return header, codePoint, nil, false, err
			}
			obj = append(obj, extra...)
		}
		if nextLen == 0x7FFE {
			moreData = true
		}
		return header, codePoint, obj, moreData, nil
	}

	if objLen < 4 {
		return header, codePoint, nil, false, fmt.Errorf("invalid DDM object length: %d", objLen)
	}

	if dssLen >= 6 && int(objLen) > int(dssLen)-6 {
		return header, codePoint, nil, false, fmt.Errorf("db2: DDM object length %d exceeds DSS frame payload capacity %d", objLen, dssLen-6)
	}

	payloadLen := int(objLen - 4)
	payload := make([]byte, payloadLen)
	if _, err := io.ReadFull(r, payload); err != nil {
		return header, codePoint, nil, false, fmt.Errorf("failed to read DDM payload: %w", err)
	}

	return header, codePoint, payload, moreData, nil
}
