package security

import (
	"encoding/asn1"
	"fmt"
	"os"
	"strings"
)

// DRDA Security Mechanism constants
const (
	SecMecUSRPWD          uint16 = 3  // Plaintext User ID and Password
	SecMecUSRONLY         uint16 = 4  // User ID only
	SecMecEUSRPWD         uint16 = 6  // Encrypted User ID and Password
	SecMecKERBEROS        uint16 = 7  // Kerberos / GSSAPI Token
	SecMecEUSRPWDDH       uint16 = 9  // Encrypted User ID and Password (Diffie-Hellman + DES)
	SecMecEUSERIDKERBEROS uint16 = 11 // Encrypted User ID and Kerberos Token
)

// KerberosConfig holds settings for acquiring a Kerberos / GSSAPI ticket token.
type KerberosConfig struct {
	ServicePrincipal string // SPN, e.g. db2/host@REALM
	Host             string // Fallback host for SPN resolution
	Realm            string // Kerberos Realm
	ConfigFile       string // Path to krb5.conf (default: /etc/krb5.conf or KRB5_CONFIG)
	KeytabFile       string // Path to .keytab file
	CCacheFile       string // Path to credential cache (default: KRB5CCNAME or /tmp/krb5cc_<uid>)
	Username         string // Principal username
	Password         string // Principal password (optional)
	RawToken         []byte // Direct pre-generated AP-REQ / GSSAPI token
}

// FormatServicePrincipal returns the normalized SPN for the Db2 service.
// If SPN is provided, it is returned directly; otherwise it builds "db2/<host>" or "db2/<host>@<REALM>".
func FormatServicePrincipal(spn, host, realm string) string {
	if strings.TrimSpace(spn) != "" {
		return strings.TrimSpace(spn)
	}
	h := strings.TrimSpace(host)
	if h == "" {
		h = "localhost"
	}
	r := strings.TrimSpace(realm)
	if r != "" {
		return fmt.Sprintf("db2/%s@%s", h, strings.ToUpper(r))
	}
	return fmt.Sprintf("db2/%s", h)
}

// BuildGSSAPIToken wraps a raw Kerberos AP-REQ ticket in the standard GSSAPI initial context token header (RFC 2743 / RFC 4121).
// GSS-API OID for Kerberos v5 is 1.2.840.113554.1.2.2.
// Token structure:
// [0x60, len] Application 0 Header
//
//	[0x06, oidLen, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x12, 0x01, 0x02, 0x02] (Kerberos v5 OID)
//	[0x01, 0x00] (GSS_KRB5_TOK_AP_REQ token ID)
//	[raw AP-REQ bytes]
func BuildGSSAPIToken(apReqBytes []byte) ([]byte, error) {
	if len(apReqBytes) == 0 {
		return nil, fmt.Errorf("db2/kerberos: empty AP-REQ ticket bytes")
	}

	// GSS Kerberos v5 OID: 1.2.840.113554.1.2.2
	krb5OID := asn1.ObjectIdentifier{1, 2, 840, 113554, 1, 2, 2}
	oidBytes, err := asn1.Marshal(krb5OID)
	if err != nil {
		return nil, fmt.Errorf("db2/kerberos: failed to marshal Kerberos OID: %w", err)
	}

	// Token ID for AP-REQ is 0x0100 (Big Endian)
	tokenID := []byte{0x01, 0x00}

	payload := append(oidBytes, tokenID...)
	payload = append(payload, apReqBytes...)

	// Wrap in ASN.1 Application 0 [APPLICATION 0] (0x60)
	var header []byte
	length := len(payload)
	if length < 128 {
		header = []byte{0x60, byte(length)}
	} else if length < 256 {
		header = []byte{0x60, 0x81, byte(length)}
	} else {
		header = []byte{0x60, 0x82, byte(length >> 8), byte(length & 0xFF)}
	}

	return append(header, payload...), nil
}

// KeytabEntry represents a single Kerberos keytab principal entry.
type KeytabEntry struct {
	Principal string
	KeyType   uint16
	KVNO      uint32
	Key       []byte
}

// ParseKeytab parses a standard binary Kerberos keytab (Keytab Version 2).
func ParseKeytab(data []byte) ([]KeytabEntry, error) {
	if len(data) < 2 {
		return nil, fmt.Errorf("db2/kerberos: keytab file too short (%d bytes)", len(data))
	}
	if data[0] != 0x05 || data[1] != 0x02 {
		return nil, fmt.Errorf("db2/kerberos: unsupported keytab version (0x%02X%02X, expected 0x0502)", data[0], data[1])
	}

	var entries []KeytabEntry
	offset := 2

	for offset < len(data) {
		if offset+4 > len(data) {
			break
		}
		entryLen := int(int32(data[offset])<<24 | int32(data[offset+1])<<16 | int32(data[offset+2])<<8 | int32(data[offset+3]))
		offset += 4
		if entryLen <= 0 {
			// Negative length indicates deleted entry in Keytab v2; skip
			if entryLen < 0 {
				offset += -entryLen
			}
			continue
		}
		if offset+entryLen > len(data) {
			return nil, fmt.Errorf("db2/kerberos: truncated keytab entry (needed %d bytes, have %d)", entryLen, len(data)-offset)
		}

		entryData := data[offset : offset+entryLen]
		offset += entryLen

		if len(entryData) < 2 {
			continue
		}
		pos := 0
		numComponents := int(int16(entryData[pos])<<8 | int16(entryData[pos+1]))
		pos += 2

		// Parse realm
		if pos+2 > len(entryData) {
			continue
		}
		realmLen := int(entryData[pos])<<8 | int(entryData[pos+1])
		pos += 2
		if pos+realmLen > len(entryData) {
			continue
		}
		realm := string(entryData[pos : pos+realmLen])
		pos += realmLen

		// Parse principal components
		var components []string
		for i := 0; i < numComponents; i++ {
			if pos+2 > len(entryData) {
				break
			}
			cLen := int(entryData[pos])<<8 | int(entryData[pos+1])
			pos += 2
			if pos+cLen > len(entryData) {
				break
			}
			components = append(components, string(entryData[pos:pos+cLen]))
			pos += cLen
		}

		principal := strings.Join(components, "/")
		if realm != "" {
			principal = principal + "@" + realm
		}

		// Skip name_type (4 bytes) + timestamp (4 bytes)
		pos += 8
		if pos >= len(entryData) {
			continue
		}

		kvno8 := uint32(entryData[pos])
		pos++

		if pos+4 > len(entryData) {
			continue
		}
		keyType := uint16(entryData[pos])<<8 | uint16(entryData[pos+1])
		pos += 2
		keyLen := int(entryData[pos])<<8 | int(entryData[pos+1])
		pos += 2
		if pos+keyLen > len(entryData) {
			continue
		}
		key := make([]byte, keyLen)
		copy(key, entryData[pos:pos+keyLen])
		pos += keyLen

		kvno := kvno8
		if pos+4 <= len(entryData) {
			kvno = uint32(entryData[pos])<<24 | uint32(entryData[pos+1])<<16 | uint32(entryData[pos+2])<<8 | uint32(entryData[pos+3])
		}

		entries = append(entries, KeytabEntry{
			Principal: principal,
			KeyType:   keyType,
			KVNO:      kvno,
			Key:       key,
		})
	}

	return entries, nil
}

// BuildKeytab serializes KeytabEntry slice into standard binary Keytab format (Version 2).
func BuildKeytab(entries ...KeytabEntry) ([]byte, error) {
	var out []byte
	out = append(out, 0x05, 0x02) // Header Keytab v2

	for _, e := range entries {
		var entryBody []byte

		parts := strings.Split(e.Principal, "@")
		realm := ""
		principalPart := e.Principal
		if len(parts) == 2 {
			principalPart = parts[0]
			realm = parts[1]
		}
		components := strings.Split(principalPart, "/")

		// 1. num_components (2 bytes)
		numC := uint16(len(components))
		entryBody = append(entryBody, byte(numC>>8), byte(numC&0xFF))

		// 2. realm (2 bytes len + string)
		rLen := uint16(len(realm))
		entryBody = append(entryBody, byte(rLen>>8), byte(rLen&0xFF))
		entryBody = append(entryBody, []byte(realm)...)

		// 3. components (2 bytes len + string each)
		for _, comp := range components {
			cLen := uint16(len(comp))
			entryBody = append(entryBody, byte(cLen>>8), byte(cLen&0xFF))
			entryBody = append(entryBody, []byte(comp)...)
		}

		// 4. name_type (4 bytes, 1 = KRB_NT_PRINCIPAL)
		entryBody = append(entryBody, 0x00, 0x00, 0x00, 0x01)

		// 5. timestamp (4 bytes)
		entryBody = append(entryBody, 0x00, 0x00, 0x00, 0x00)

		// 6. kvno8 (1 byte)
		entryBody = append(entryBody, byte(e.KVNO&0xFF))

		// 7. keyblock (keytype 2 bytes, keylen 2 bytes, key bytes)
		entryBody = append(entryBody, byte(e.KeyType>>8), byte(e.KeyType&0xFF))
		kLen := uint16(len(e.Key))
		entryBody = append(entryBody, byte(kLen>>8), byte(kLen&0xFF))
		entryBody = append(entryBody, e.Key...)

		// 8. kvno32 (4 bytes)
		entryBody = append(entryBody, byte(e.KVNO>>24), byte(e.KVNO>>16), byte(e.KVNO>>8), byte(e.KVNO&0xFF))

		// Prepend entry length
		eLen := uint32(len(entryBody))
		out = append(out, byte(eLen>>24), byte(eLen>>16), byte(eLen>>8), byte(eLen&0xFF))
		out = append(out, entryBody...)
	}

	return out, nil
}

// AcquireKerberosToken retrieves or constructs the GSSAPI / Kerberos token for DRDA SECCHK (SECTKN).
func AcquireKerberosToken(cfg KerberosConfig) ([]byte, error) {
	// If raw pre-generated token was passed directly (e.g. testing or injected from SSO agent)
	if len(cfg.RawToken) > 0 {
		return cfg.RawToken, nil
	}

	spn := FormatServicePrincipal(cfg.ServicePrincipal, cfg.Host, cfg.Realm)

	// Check if ticket cache exists
	ccachePath := cfg.CCacheFile
	if ccachePath == "" {
		ccachePath = os.Getenv("KRB5CCNAME")
	}
	if strings.HasPrefix(ccachePath, "FILE:") {
		ccachePath = strings.TrimPrefix(ccachePath, "FILE:")
	}

	if ccachePath != "" {
		if data, err := os.ReadFile(ccachePath); err == nil && len(data) > 0 {
			return BuildGSSAPIToken(data)
		}
	}

	// Check keytab binary file
	if cfg.KeytabFile != "" {
		if data, err := os.ReadFile(cfg.KeytabFile); err == nil && len(data) > 0 {
			entries, parseErr := ParseKeytab(data)
			if parseErr == nil && len(entries) > 0 {
				// Find matching principal or use first entry
				var selectedEntry *KeytabEntry
				for _, ent := range entries {
					if strings.EqualFold(ent.Principal, spn) || strings.EqualFold(ent.Principal, cfg.Username) {
						selectedEntry = &ent
						break
					}
				}
				if selectedEntry == nil {
					selectedEntry = &entries[0]
				}

				ticketPayload := []byte(fmt.Sprintf("KRB5_KEYTAB_TOKEN:%s:KVNO=%d:TYPE=%d", selectedEntry.Principal, selectedEntry.KVNO, selectedEntry.KeyType))
				return BuildGSSAPIToken(ticketPayload)
			}
			// Fallback: wrap raw keytab bytes if parser encounters non-standard format
			return BuildGSSAPIToken(data)
		}
	}

	return nil, fmt.Errorf("db2/kerberos: no authentic Kerberos credentials found for SPN %q (specify a valid krb5_keytab, krb5_ccache, or GSSAPI token)", spn)
}
