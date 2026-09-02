package network

import (
	"bytes"
	"encoding/binary"
	"errors"
	"fmt"
	"strings"

	"github.com/go-db2/go-db2/converters"
)

// StringEncoding defines the character encoding used for packing DDM strings.
type StringEncoding string

const (
	EncodingCP500 StringEncoding = "cp500" // IBM EBCDIC 500
	EncodingUTF8  StringEncoding = "utf-8" // UTF-8
)

// ManagerLevel represents a DRDA Manager and its negotiated support level.
type ManagerLevel struct {
	Manager CodePoint // Manager Codepoint (e.g., AGENT, SQLAM, CMNTCPIP, etc.)
	Level   uint16    // Manager Version/Level
}

// PackDDMObject wraps raw body bytes into a DDM object header (2 bytes length + 2 bytes codepoint + body).
func PackDDMObject(cp CodePoint, body []byte) []byte {
	totalLen := len(body) + 4
	if totalLen > 65535 {
		totalLen = 65535
	}
	buf := make([]byte, totalLen)
	binary.BigEndian.PutUint16(buf[0:2], uint16(totalLen))
	binary.BigEndian.PutUint16(buf[2:4], uint16(cp))
	copy(buf[4:], body[:totalLen-4])
	return buf
}

// PackBytes wraps a binary slice into a DDM parameter object.
func PackBytes(cp CodePoint, val []byte) []byte {
	return PackDDMObject(cp, val)
}

// PackUint16 encodes a 16-bit integer into a DDM parameter object.
func PackUint16(cp CodePoint, val uint16) []byte {
	buf := make([]byte, 2)
	binary.BigEndian.PutUint16(buf, val)
	return PackDDMObject(cp, buf)
}

// PackUint32 encodes a 32-bit integer into a DDM parameter object.
func PackUint32(cp CodePoint, val uint32) []byte {
	buf := make([]byte, 4)
	binary.BigEndian.PutUint32(buf, val)
	return PackDDMObject(cp, buf)
}

// PackString encodes a string into a DDM parameter object using the specified encoding.
func PackString(cp CodePoint, val string, enc StringEncoding) ([]byte, error) {
	var encoded []byte
	var err error

	switch enc {
	case EncodingCP500:
		encoded, err = converters.EncodeCP500(val)
		if err != nil {
			return nil, fmt.Errorf("failed to encode string to CP500: %w", err)
		}
	default:
		encoded = []byte(val)
	}

	return PackDDMObject(cp, encoded), nil
}

// PackNullString encodes a nullable string for SQL statements / parameters.
func PackNullString(val *string, enc StringEncoding) []byte {
	if val == nil {
		return []byte{0xFF}
	}
	var b []byte
	switch enc {
	case EncodingCP500:
		var err error
		b, err = converters.EncodeCP500(*val)
		if err != nil {
			b = []byte(*val)
		}
	default:
		b = []byte(*val)
	}

	buf := make([]byte, 1+4+len(b))
	buf[0] = 0x00
	binary.BigEndian.PutUint32(buf[1:5], uint32(len(b)))
	copy(buf[5:], b)
	return buf
}

// DefaultManagerLevels returns standard client manager levels for Db2 DRDA negotiation.
func DefaultManagerLevels() []ManagerLevel {
	return []ManagerLevel{
		{Manager: CodePointAGENT, Level: 10},
		{Manager: CodePointSQLAM, Level: 11},
		{Manager: CodePointCMNTCPIP, Level: 5},
		{Manager: CodePointRDB, Level: 12},
		{Manager: CodePointSECMGR, Level: 9},
		{Manager: CodePointUNICODEMGR, Level: 1208},
	}
}

// PackEXCSAT builds the EXCSAT (Exchange Server Attributes) DDM command.
func PackEXCSAT(extName, srvName, srvRlsLv, srvClsNm string, mgrLevels []ManagerLevel) ([]byte, error) {
	var body []byte

	// 1. External Name (EXTNAM)
	extNameObj, err := PackString(CodePointEXTNAM, extName, EncodingCP500)
	if err != nil {
		return nil, err
	}
	body = append(body, extNameObj...)

	// 2. Server Name (SRVNAM)
	srvNameObj, err := PackString(CodePointSRVNAM, srvName, EncodingCP500)
	if err != nil {
		return nil, err
	}
	body = append(body, srvNameObj...)

	// 3. Server Release Level (SRVRLSLV)
	srvRlsLvObj, err := PackString(CodePointSRVRLSLV, srvRlsLv, EncodingCP500)
	if err != nil {
		return nil, err
	}
	body = append(body, srvRlsLvObj...)

	// 4. Manager-Level List (MGRLVLLS)
	mgrListBytes := make([]byte, len(mgrLevels)*4)
	for i, ml := range mgrLevels {
		binary.BigEndian.PutUint16(mgrListBytes[i*4:i*4+2], uint16(ml.Manager))
		binary.BigEndian.PutUint16(mgrListBytes[i*4+2:i*4+4], ml.Level)
	}
	body = append(body, PackBytes(CodePointMGRLVLLS, mgrListBytes)...)

	// 5. Server Class Name (SRVCLSNM)
	srvClsNmObj, err := PackString(CodePointSRVCLSNM, srvClsNm, EncodingCP500)
	if err != nil {
		return nil, err
	}
	body = append(body, srvClsNmObj...)

	return PackDDMObject(CodePointEXCSAT, body), nil
}

// PackEXCSAT_MGRLVLLS builds an EXCSAT packet containing only MGRLVLLS (e.g. for setting CCSIDMGR).
func PackEXCSAT_MGRLVLLS(mgrLevels []ManagerLevel) []byte {
	mgrListBytes := make([]byte, len(mgrLevels)*4)
	for i, ml := range mgrLevels {
		binary.BigEndian.PutUint16(mgrListBytes[i*4:i*4+2], uint16(ml.Manager))
		binary.BigEndian.PutUint16(mgrListBytes[i*4+2:i*4+4], ml.Level)
	}
	body := PackBytes(CodePointMGRLVLLS, mgrListBytes)
	return PackDDMObject(CodePointEXCSAT, body)
}

// PackACCSEC builds the ACCSEC (Access Security) DDM command.
func PackACCSEC(database string, secmec uint16, sectkn []byte) ([]byte, error) {
	var body []byte

	// 1. Security Mechanism (SECMEC)
	body = append(body, PackUint16(CodePointSECMEC, secmec)...)

	// 2. Database Name (RDBNAM) in CP500
	rdbNamObj, err := PackString(CodePointRDBNAM, database, EncodingCP500)
	if err != nil {
		return nil, err
	}
	body = append(body, rdbNamObj...)

	// 3. Optional Security Token (SECTKN)
	if len(sectkn) > 0 {
		body = append(body, PackBytes(CodePointSECTKN, sectkn)...)
	}

	return PackDDMObject(CodePointACCSEC, body), nil
}

// PackSECCHK builds the SECCHK (Security Check) DDM command for user authentication.
func PackSECCHK(secmec uint16, sectkn []byte, database, user, password string, enc StringEncoding) ([]byte, error) {
	return PackSECCHKWithBytes(secmec, sectkn, database, user, []byte(password), false, enc)
}

// PackSECCHKWithBytes builds the SECCHK DDM command supporting raw encrypted password bytes and security tokens.
func PackSECCHKWithBytes(secmec uint16, sectkn []byte, database, user string, passwordBytes []byte, isEncrypted bool, enc StringEncoding) ([]byte, error) {
	var body []byte

	// 1. Security Mechanism (SECMEC)
	body = append(body, PackUint16(CodePointSECMEC, secmec)...)

	// 2. Security Token (SECTKN) if provided (for SECMEC 9)
	if len(sectkn) > 0 {
		body = append(body, PackBytes(CodePointSECTKN, sectkn)...)
	}

	// 3. Database Name (RDBNAM)
	rdbNamObj, err := PackString(CodePointRDBNAM, database, enc)
	if err != nil {
		return nil, err
	}
	body = append(body, rdbNamObj...)

	// 4. User ID (USRID)
	usrIdObj, err := PackString(CodePointUSRID, user, enc)
	if err != nil {
		return nil, err
	}
	body = append(body, usrIdObj...)

	// 5. Password (PASSWORD) - only append if provided (omitted in Kerberos/token auth)
	if len(passwordBytes) > 0 {
		if isEncrypted {
			body = append(body, PackBytes(CodePointPASSWORD, passwordBytes)...)
		} else {
			pwdObj, err := PackString(CodePointPASSWORD, string(passwordBytes), enc)
			if err != nil {
				return nil, err
			}
			body = append(body, pwdObj...)
		}
	}

	return PackDDMObject(CodePointSECCHK, body), nil
}

// Default constants for ACCRDB
var (
	defaultCRRTKN = []byte{
		0xD5, 0xC6, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF1,
		0x2E, 0xC3, 0xF0, 0xC1, 0xF5, 0x01, 0x55, 0x63,
		0x0D, 0x5A, 0x11,
	}
	defaultTYPDEFOVR = []byte{
		0x00, 0x06, 0x11, 0x9C, 0x04, 0xB8,
		0x00, 0x06, 0x11, 0x9D, 0x04, 0xB0,
		0x00, 0x06, 0x11, 0x9E, 0x04, 0xB8,
	}
)

// PackACCRDB builds the ACCRDB (Access Relational Database) DDM command.
func PackACCRDB(prdid, rdbnam string, enc StringEncoding) ([]byte, error) {
	var body []byte

	// 1. RDBNAM
	rdbNamObj, err := PackString(CodePointRDBNAM, rdbnam, enc)
	if err != nil {
		return nil, err
	}
	body = append(body, rdbNamObj...)

	// 2. RDBACCCL (SQLAM = 0x2407)
	body = append(body, PackUint16(CodePointRDBACCCL, uint16(CodePointSQLAM))...)

	// 3. PRDID
	prdidObj, err := PackString(CodePointPRDID, prdid, enc)
	if err != nil {
		return nil, err
	}
	body = append(body, prdidObj...)

	// 4. TYPDEFNAM ("QTDSQLX86")
	typDefNamObj, err := PackString(CodePointTYPDEFNAM, "QTDSQLX86", enc)
	if err != nil {
		return nil, err
	}
	body = append(body, typDefNamObj...)

	// 5. CRRTKN
	body = append(body, PackBytes(CodePointCRRTKN, defaultCRRTKN)...)

	// 6. TYPDEFOVR
	body = append(body, PackBytes(CodePointTYPDEFOVR, defaultTYPDEFOVR)...)

	return PackDDMObject(CodePointACCRDB, body), nil
}

// PackRDBCMM builds the RDBCMM (Relational Database Commit) DDM command.
func PackRDBCMM() []byte {
	return PackDDMObject(CodePointRDBCMM, nil)
}

// PackRDBRLLBCK builds the RDBRLLBCK (Relational Database Rollback) DDM command.
func PackRDBRLLBCK() []byte {
	return PackDDMObject(CodePointRDBRLLBCK, nil)
}

// PackPKGNAMCSN formats the package name, consistency token, and section number.
func PackPKGNAMCSN(database, pkgid, pkgcnstkn string, pkgsn uint16) []byte {
	dbPadded := fmt.Sprintf("%-18s", database)
	nullidPadded := fmt.Sprintf("%-18s", "NULLID")
	pkgidPadded := fmt.Sprintf("%-18s", pkgid)

	var payload []byte
	payload = append(payload, []byte(dbPadded)...)
	payload = append(payload, []byte(nullidPadded)...)
	payload = append(payload, []byte(pkgidPadded)...)

	if pkgcnstkn == "" {
		payload = append(payload, []byte{0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01}...)
	} else {
		tokenPadded := fmt.Sprintf("%8s", pkgcnstkn)
		payload = append(payload, []byte(tokenPadded)...)
	}

	snBytes := make([]byte, 2)
	binary.BigEndian.PutUint16(snBytes, pkgsn)
	payload = append(payload, snBytes...)

	return PackBytes(CodePointPKGNAMCSN, payload)
}

// PackEXCSQLSET builds an EXCSQLSET command (e.g. for setting client workstation name).
func PackEXCSQLSET(pkgid, pkgcnstkn string, pkgsn uint16, database string) []byte {
	body := PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn)
	return PackDDMObject(CodePointEXCSQLSET, body)
}

// PackSQLSTT builds an SQLSTT object containing a raw SQL query.
func PackSQLSTT(sql string) []byte {
	body := append(PackNullString(&sql, EncodingUTF8), PackNullString(nil, EncodingUTF8)...)
	return PackDDMObject(CodePointSQLSTT, body)
}

// ParseDDMReply parses a response buffer into a map of CodePoint to parameter data bytes.
func ParseDDMReply(data []byte) (map[CodePoint][]byte, error) {
	results := make(map[CodePoint][]byte)
	offset := 0

	for offset < len(data) {
		if offset+4 > len(data) {
			return nil, errors.New("incomplete DDM parameter header in reply")
		}

		paramLen := int(binary.BigEndian.Uint16(data[offset : offset+2]))
		codePoint := CodePoint(binary.BigEndian.Uint16(data[offset+2 : offset+4]))

		if paramLen < 4 || offset+paramLen > len(data) {
			return nil, fmt.Errorf("invalid DDM parameter length %d at offset %d", paramLen, offset)
		}

		paramData := data[offset+4 : offset+paramLen]
		results[codePoint] = paramData
		offset += paramLen
	}

	return results, nil
}

// PackEXCSQLIMM builds an EXCSQLIMM (Execute Immediate SQL) DDM command.
func PackEXCSQLIMM(pkgid, pkgcnstkn string, pkgsn uint16, database string) []byte {
	body := append(
		PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn),
		PackBytes(CodePointRDBCMTOK, []byte{241})...,
	)
	return PackDDMObject(CodePointEXCSQLIMM, body)
}

// PackPRPSQLSTT builds a PRPSQLSTT (Prepare SQL Statement) DDM command.
func PackPRPSQLSTT(pkgid, pkgcnstkn string, pkgsn uint16, database string) []byte {
	body := append(
		PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn),
		PackBytes(CodePointRTNSQLDA, []byte{241})...,
	)
	return PackDDMObject(CodePointPRPSQLSTT, body)
}

// PackDSCSQLSTT builds a DSCSQLSTT (Describe SQL Statement) DDM command.
func PackDSCSQLSTT(pkgid, pkgcnstkn string, pkgsn uint16, database string) []byte {
	body := append(
		PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn),
		PackBytes(CodePointTYPSQLDA, []byte{1})...,
	)
	return PackDDMObject(CodePointDSCSQLSTT, body)
}

// PackEXCSQLSTT builds an EXCSQLSTT (Execute SQL Statement) DDM command with parameters.
func PackEXCSQLSTT(pkgid, pkgcnstkn string, pkgsn uint16, database string) []byte {
	body := append(
		PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn),
		PackBytes(CodePointRDBCMTOK, []byte{241})...,
	)
	return PackDDMObject(CodePointEXCSQLSTT, body)
}

// PackOPNQRYWithParams builds an OPNQRY command with parameter dynamic format enabled.
func PackOPNQRYWithParams(pkgid, pkgcnstkn string, pkgsn uint16, database string, qryblksz uint32) []byte {
	var body []byte
	body = append(body, PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn)...)
	body = append(body, PackUint32(CodePointQRYBLKSZ, qryblksz)...)
	body = append(body, PackUint16(CodePointMAXBLKEXT, uint16(qryblksz))...)
	body = append(body, PackBytes(CodePointQRYCLSIMP, []byte{0x01})...)
	body = append(body, PackBytes(CodePointDYNDTAFMT, []byte{0xF1})...)
	return PackDDMObject(CodePointOPNQRY, body)
}

// PackCNTQRY builds a CNTQRY (Continue Query) DDM command to stream row data from open query.
func PackCNTQRY(pkgid, pkgcnstkn string, pkgsn uint16, database string, qryblksz uint32, qryinsid uint64) []byte {
	var body []byte
	body = append(body, PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn)...)
	body = append(body, PackUint32(CodePointQRYBLKSZ, qryblksz)...)
	insidBytes := make([]byte, 8)
	binary.BigEndian.PutUint64(insidBytes, qryinsid)
	body = append(body, PackBytes(CodePointQRYINSID, insidBytes)...)
	body = append(body, PackBytes(CodePointRTNEXTDTA, []byte{0x02})...)
	return PackDDMObject(CodePointCNTQRY, body)
}

// PackOPNQRY builds an OPNQRY (Open Query) DDM command.
func PackOPNQRY(pkgid, pkgcnstkn string, pkgsn uint16, database string, qryblksz uint32) []byte {
	var body []byte
	body = append(body, PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn)...)
	body = append(body, PackUint32(CodePointQRYBLKSZ, qryblksz)...)
	body = append(body, PackUint16(CodePointMAXBLKEXT, uint16(qryblksz))...)
	body = append(body, PackBytes(CodePointQRYCLSIMP, []byte{0x01})...)
	return PackDDMObject(CodePointOPNQRY, body)
}

// PackSQLINTR builds an SQLINTR (SQL Interrupt Request) DDM command to cancel active query.
func PackSQLINTR(pkgid, pkgcnstkn string, pkgsn uint16, database string) []byte {
	body := PackPKGNAMCSN(database, pkgid, pkgcnstkn, pkgsn)
	return PackDDMObject(CodePointSQLINTR, body)
}

// ColumnDescription holds column metadata decoded from SQLDARD.
type ColumnDescription struct {
	Name      string
	SQLType   uint16
	Length    int64
	Precision int
	Scale     int
	Nullable  bool
}

// FieldDescriptor represents a single column descriptor from QRYDSC.
type FieldDescriptor struct {
	Type uint8
	PS   []byte
}

func parseString(b []byte) (string, []byte) {
	if len(b) < 2 {
		return "", nil
	}
	ln := int(binary.BigEndian.Uint16(b[:2]))
	if ln == 0 || len(b) < 2+ln {
		return "", b[2:]
	}
	data := b[2 : 2+ln]
	return string(data), b[2+ln:]
}

func parseName(b []byte) (string, []byte) {
	s1, rest1 := parseString(b)
	s2, rest2 := parseString(rest1)
	if s1 != "" {
		return s1, rest2
	}
	return s2, rest2
}

// ParseSQLDARD decodes column metadata from an SQLDARD reply packet.
func ParseSQLDARD(obj []byte, endian binary.ByteOrder) ([]ColumnDescription, error) {
	if len(obj) == 0 {
		return nil, nil
	}

	hasName := (obj[0] == 0x00)

	var rest []byte
	if obj[0] == 0xFF {
		rest = obj[1:]
	} else {
		// Parse leading SQLCARD
		sqlcode, sqlstate, msg, _, err := ParseSQLCARD(obj, endian)
		if err != nil {
			return nil, err
		}
		if sqlcode < 0 {
			return nil, fmt.Errorf("db2: SQLCODE=%d SQLSTATE=%s: %s", sqlcode, sqlstate, msg)
		}

		if len(obj) > 54 {
			rest = obj[54:]
			for i := 0; i < 3 && len(rest) >= 2; i++ {
				ln := int(binary.BigEndian.Uint16(rest[:2]))
				if len(rest) >= 2+ln {
					rest = rest[2+ln:]
				}
			}
			if len(rest) > 0 && rest[0] == 0xFF {
				rest = rest[1:]
			}
		} else {
			rest = obj
		}
	}

	if len(rest) < 2 {
		return nil, nil
	}

	if rest[0] == 0x00 {
		if len(rest) > 13 {
			rest = rest[13:]
			_, rest = parseString(rest)
			_, rest = parseName(rest)
		}
	} else {
		rest = rest[1:]
	}

	if len(rest) < 2 {
		return nil, nil
	}

	numCols := int(endian.Uint16(rest[:2]))
	rest = rest[2:]

	var cols []ColumnDescription
	for i := 0; i < numCols && len(rest) >= 16; i++ {
		prec := int(endian.Uint16(rest[0:2]))
		scale := int(endian.Uint16(rest[2:4]))
		sqllen := int64(endian.Uint64(rest[4:12]))
		sqltype := endian.Uint16(rest[12:14])
		rest = rest[16:]

		var colName string
		// Check for ffffff delimiter (used in SP descriptors)
		delimPos := bytes.Index(rest, []byte{0xFF, 0xFF, 0xFF})
		if delimPos != -1 {
			nameChunk := rest[:delimPos]
			rest = rest[delimPos+3:]
			// Extract ASCII name from chunk
			for k := 0; k < len(nameChunk)-1; k++ {
				nlen := int(nameChunk[k])
				if nlen > 0 && k+1+nlen <= len(nameChunk) {
					cand := nameChunk[k+1 : k+1+nlen]
					isASCII := true
					for _, c := range cand {
						if c < 32 || c > 126 {
							isASCII = false
							break
						}
					}
					if isASCII {
						colName = string(cand)
						break
					}
				}
			}
		} else {
			if hasName {
				if len(rest) >= 9 {
					rest = rest[9:]
					var name string
					name, rest = parseName(rest)
					label, r2 := parseName(rest)
					rest = r2
					_, r3 := parseName(rest)
					rest = r3
					if len(rest) >= 7 {
						rest = rest[7:]
					}
					if label != "" {
						colName = label
					} else {
						colName = name
					}
				}
			} else {
				if len(rest) >= 29 {
					rest = rest[29:]
				}
			}
		}

		if colName == "" {
			colName = fmt.Sprintf("PARAM%d", i+1)
		}

		cols = append(cols, ColumnDescription{
			Name:      colName,
			SQLType:   sqltype,
			Length:    sqllen,
			Precision: prec,
			Scale:     scale,
			Nullable:  (sqltype % 2) != 0,
		})
	}

	return cols, nil
}

// ParseQRYDSC decodes the QRYDSC (Query Descriptor) into a slice of field descriptors.
func ParseQRYDSC(obj []byte) ([]FieldDescriptor, error) {
	if len(obj) < 3 {
		return nil, errors.New("QRYDSC payload too short")
	}

	ln := int(obj[0])
	if ln == 0 || len(obj) < ln {
		ln = len(obj)
	}

	data := obj[1:ln]
	if len(data) >= 2 && data[0] == 0x76 && data[1] == 0xD0 {
		data = data[2:]
	}

	var fields []FieldDescriptor
	for i := 0; i+3 <= len(data); i += 3 {
		fType := data[i]
		ps := data[i+1 : i+3]
		fields = append(fields, FieldDescriptor{
			Type: fType,
			PS:   ps,
		})
	}

	return fields, nil
}

// ParseSQLCARD parses the SQL Communications Area (SQLCARD) structure into SQLCODE, SQLSTATE, Message, and RowsAffected.
func ParseSQLCARD(obj []byte, endian binary.ByteOrder) (int32, string, string, int64, error) {
	if len(obj) == 0 {
		return 0, "", "", 0, errors.New("empty SQLCARD payload")
	}
	if obj[0] == 0xFF {
		return 0, "", "", 0, nil // Valid empty / no error
	}
	if len(obj) < 18 {
		return 0, "", "", 0, fmt.Errorf("SQLCARD payload too short: %d bytes", len(obj))
	}

	sqlcode := int32(endian.Uint32(obj[1:5]))
	sqlstate := string(obj[5:10])

	var rowsAffected int64
	if len(obj) >= 26 {
		rowsAffected = int64(int32(endian.Uint32(obj[22:26])))
	}
	if rowsAffected == 0 && sqlcode == 0 {
		rowsAffected = 1
	}

	// Try extracting human-readable message if present
	var message string
	if len(obj) > 36+18 {
		rest := obj[36+18:]
		// Extract RDB name
		if len(rest) >= 2 {
			rdbLen := int(binary.BigEndian.Uint16(rest[:2]))
			if len(rest) >= 2+rdbLen {
				rest = rest[2+rdbLen:]
			}
		}
		// Extract error message
		if len(rest) >= 2 {
			msgLen := int(binary.BigEndian.Uint16(rest[:2]))
			if len(rest) >= 2+msgLen {
				rawMsg := rest[2 : 2+msgLen]
				message = string(rawMsg)
				message = strings.ReplaceAll(message, "\xff", ", ")
			}
		}
	}

	return sqlcode, sqlstate, message, rowsAffected, nil
}
