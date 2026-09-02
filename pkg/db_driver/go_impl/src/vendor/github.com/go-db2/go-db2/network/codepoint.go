package network

import "fmt"

// CodePoint represents a 16-bit DRDA/DDM protocol identifier.
type CodePoint uint16

// DRDA / DDM Protocol Codepoints
const (
	// Connection & Session Handshake
	CodePointEXCSAT      CodePoint = 0x1041 // Exchange Server Attributes
	CodePointEXCSATRD    CodePoint = 0x1443 // Exchange Server Attributes Reply Data
	CodePointACCSEC      CodePoint = 0x106D // Access Security
	CodePointACCSECRD    CodePoint = 0x14AC // Access Security Reply Data
	CodePointSECCHK      CodePoint = 0x106E // Security Check
	CodePointSECCHKCD    CodePoint = 0x11A4 // Security Check Code
	CodePointSECMEC      CodePoint = 0x11A2 // Security Mechanism
	CodePointSECMGR      CodePoint = 0x1440 // Security Manager
	CodePointSECMGRNM    CodePoint = 0x1196 // Security Manager Name
	CodePointSECTKN      CodePoint = 0x11DC // Security Token
	CodePointUSRID       CodePoint = 0x11A0 // User ID
	CodePointPASSWORD    CodePoint = 0x11A1 // Password
	CodePointNEWPASSWORD CodePoint = 0x11DE // New Password
	CodePointACCRDB      CodePoint = 0x2001 // Access Relational Database
	CodePointSQLINTR     CodePoint = 0x2007 // SQL Interrupt Request
	CodePointRDBNAM      CodePoint = 0x2110 // Relational Database Name
	CodePointRDBINTTKN   CodePoint = 0x2103 // RDB Interrupt Token
	CodePointRDBALWUPD   CodePoint = 0x211A // RDB Allow Update
	CodePointRDBACCCL    CodePoint = 0x210F // RDB Access Class
	CodePointCRRTKN      CodePoint = 0x2135 // Correlation Token
	CodePointPRDID       CodePoint = 0x112E // Product Specific Identifier
	CodePointPRDDTA      CodePoint = 0x2104 // Product Specific Data
	CodePointSRVNAM      CodePoint = 0x116D // Server Name
	CodePointSRVCLSNM    CodePoint = 0x1147 // Server Class Name
	CodePointSRVRLSLV    CodePoint = 0x115A // Server Release Level
	CodePointEXTNAM      CodePoint = 0x115E // External Name
	CodePointSPVNAM      CodePoint = 0x115D // Supervisor Name
	CodePointVRSNAM      CodePoint = 0x1144 // Version Name
	CodePointSRVDGN      CodePoint = 0x1153 // Server Diagnostic Information

	// Managers & CCSIDs
	CodePointAGENT      CodePoint = 0x1403 // Agent Manager
	CodePointMGRLVLLS   CodePoint = 0x1404 // Manager-Level List
	CodePointMGRLVLN    CodePoint = 0x1473 // Manager-Level Number
	CodePointSQLAM      CodePoint = 0x2407 // SQL Application Manager
	CodePointCMNTCPIP   CodePoint = 0x1474 // TCP/IP Communication Manager
	CodePointCMNAPPC    CodePoint = 0x1444 // APPC Communication Manager
	CodePointCMNSYNCPT  CodePoint = 0x147C // Sync Point Communication Manager
	CodePointUNICODEMGR CodePoint = 0x1C08 // Unicode Manager
	CodePointCCSIDMGR   CodePoint = 0x14CC // CCSID Manager
	CodePointCCSIDSBC   CodePoint = 0x119C // Single-Byte CCSID
	CodePointCCSIDDBC   CodePoint = 0x119D // Double-Byte CCSID
	CodePointCCSIDMBC   CodePoint = 0x119E // Mixed-Byte CCSID
	CodePointCSTMBCS    CodePoint = 0x2435 // Client/Server Mixed-Byte Character Set
	CodePointSUPERVISOR CodePoint = 0x143C // Supervisor Manager
	CodePointRSYNCMGR   CodePoint = 0x14C1 // Resync Manager
	CodePointSYNCPTMGR  CodePoint = 0x14C0 // Sync Point Manager
	CodePointXAMGR      CodePoint = 0x1C01 // XA Manager
	CodePointDICTIONARY CodePoint = 0x1458 // Data Dictionary Manager
	CodePointRDB        CodePoint = 0x240F // Relational Database Application Manager

	// SQL Statements & Execution
	CodePointPRPSQLSTT CodePoint = 0x200D // Prepare SQL Statement
	CodePointEXCSQLSTT CodePoint = 0x200B // Execute SQL Statement
	CodePointEXCSQLIMM CodePoint = 0x200A // Execute Immediate SQL Statement
	CodePointEXCSQLSET CodePoint = 0x2014 // Execute SQL Set Statement
	CodePointDSCSQLSTT CodePoint = 0x2008 // Describe SQL Statement
	CodePointDSCRDBTBL CodePoint = 0x2012 // Describe RDB Table
	CodePointSQLSTT    CodePoint = 0x2414 // SQL Statement String
	CodePointSQLATTR   CodePoint = 0x2450 // SQL Attributes
	CodePointSQLSTTVRB CodePoint = 0x2419 // SQL Statement Verb
	CodePointPKGNAMCT  CodePoint = 0x2112 // Package Name and Consistency Token
	CodePointPKGNAMCSN CodePoint = 0x2113 // Package Name, Consistency Token, and Section Number
	CodePointPKGCNSTKN CodePoint = 0x210D // Package Consistency Token
	CodePointPKGID     CodePoint = 0x2109 // Package Identifier
	CodePointPKGSNLST  CodePoint = 0x2139 // Package Section List
	CodePointPKGDFTCST CodePoint = 0x2125 // Package Default Character Set
	CodePointRDBCOLID  CodePoint = 0x2108 // RDB Collection Identifier
	CodePointRTNSQLDA  CodePoint = 0x2116 // Return SQL Descriptor Area
	CodePointTYPSQLDA  CodePoint = 0x2146 // Type of SQL Descriptor Area
	CodePointTYPDEFNAM CodePoint = 0x002F // Data Type Definition Name
	CodePointTYPDEFOVR CodePoint = 0x0035 // Data Type Definition Override

	// Queries & Result Sets
	CodePointOPNQRY    CodePoint = 0x200C // Open Query
	CodePointCNTQRY    CodePoint = 0x2006 // Continue Query
	CodePointCLSQRY    CodePoint = 0x2005 // Close Query
	CodePointQRYDSC    CodePoint = 0x241A // Query Descriptor
	CodePointQRYDTA    CodePoint = 0x241B // Query Data
	CodePointQRYBLKCTL CodePoint = 0x2132 // Query Block Protocol Control
	CodePointQRYBLKSZ  CodePoint = 0x2114 // Query Block Size
	CodePointQRYBLKRST CodePoint = 0x2154 // Query Block Reset
	CodePointQRYPRCTYP CodePoint = 0x2102 // Query Protocol Type
	CodePointQRYCLSIMP CodePoint = 0x215D // Query Close Implicit
	CodePointQRYCLSRLS CodePoint = 0x215E // Query Close Release
	CodePointQRYOPTVAL CodePoint = 0x215F // Query Option Value
	CodePointOUTOVRPRI CodePoint = 0x2123 // Output Override Priority
	CodePointQRYINSID  CodePoint = 0x215B // Query Instance Identifier
	CodePointQRYATTUPD CodePoint = 0x2150 // Query Attribute Update
	CodePointQRYRELSCR CodePoint = 0x213C // Query Relative Scroll
	CodePointQRYSCRORN CodePoint = 0x2152 // Query Scroll Orientation
	CodePointQRYROWNBR CodePoint = 0x213D // Query Row Number
	CodePointQRYROWSNS CodePoint = 0x2153 // Query Row Sensitivity
	CodePointQRYRFRTBL CodePoint = 0x213E // Query Refresh Table
	CodePointQRYATTSCR CodePoint = 0x2149 // Query Attribute Scrollable
	CodePointQRYATTSNS CodePoint = 0x2157 // Query Attribute Sensitive
	CodePointQRYROWSET CodePoint = 0x2156 // Query Row Set
	CodePointQRYRTNDTA CodePoint = 0x2155 // Query Return Data
	CodePointMAXBLKEXT CodePoint = 0x2141 // Maximum Number of Extra Blocks
	CodePointMAXRSLCNT CodePoint = 0x2140 // Maximum Result Set Count
	CodePointRSLSETFLG CodePoint = 0x2142 // Result Set Flags
	CodePointNBRROW    CodePoint = 0x213A // Number of Rows
	CodePointOUTEXP    CodePoint = 0x2111 // Output Expected
	CodePointOUTOVR    CodePoint = 0x2415 // Output Override
	CodePointOUTOVROPT CodePoint = 0x2147 // Output Override Option
	CodePointPRCNAM    CodePoint = 0x2138 // Procedure Name
	CodePointFIXROWPRC CodePoint = 0x2418 // Fixed Row Processing
	CodePointFRCFIXROW CodePoint = 0x2410 // Force Fixed Row
	CodePointLMTBLKPRC CodePoint = 0x2417 // Limited Block Processing

	// SQL Data & Formatted Data Objects (FDO)
	CodePointSQLDTA    CodePoint = 0x2412 // SQL Data
	CodePointSQLDTARD  CodePoint = 0x2413 // SQL Data Reply Data
	CodePointSQLCARD   CodePoint = 0x2408 // SQL Communications Area Reply Data
	CodePointSQLDARD   CodePoint = 0x2411 // SQL Descriptor Area Reply Data
	CodePointSQLRSLRD  CodePoint = 0x240E // SQL Result Set Reply Data
	CodePointSQLCINRD  CodePoint = 0x240B // SQL Cursor Initialization Reply Data
	CodePointSQLCSRHLD CodePoint = 0x211F // SQL Cursor Hold
	CodePointEXTDTA    CodePoint = 0x146C // Externalized Data
	CodePointFDODSC    CodePoint = 0x0010 // Formatted Data Object Descriptor
	CodePointFDODTA    CodePoint = 0x147A // Formatted Data Object Data
	CodePointFDODSCOFF CodePoint = 0x2118 // Formatted Data Object Descriptor Offset
	CodePointFDOPRMOFF CodePoint = 0x212B // Formatted Data Object Parameter Offset
	CodePointFDOTRPOFF CodePoint = 0x212A // Formatted Data Object Triplet Offset
	CodePointRTNEXTDTA CodePoint = 0x2148 // Return External Data
	CodePointDYNDTAFMT CodePoint = 0x214B // Dynamic Data Format

	// Transaction & Unit of Work (UOW)
	CodePointRDBCMM     CodePoint = 0x200E // RDB Commit
	CodePointRDBRLLBCK  CodePoint = 0x200F // RDB Rollback
	CodePointRDBRLLBCK2 CodePoint = 0xC004 // RDB Rollback 2
	CodePointRDBCMTOK   CodePoint = 0x2105 // RDB Commit OK
	CodePointUOWDSP     CodePoint = 0x2115 // Unit of Work Disposition
	CodePointSYNCCTL    CodePoint = 0x1055 // Sync Control
	CodePointSYNCRSY    CodePoint = 0x1069 // Sync Resync
	CodePointSYNCLOG    CodePoint = 0x106F // Sync Log
	CodePointSYNCCRD    CodePoint = 0x1248 // Sync Coordination Reply Data
	CodePointSYNCRRD    CodePoint = 0x126D // Sync Resync Reply Data
	CodePointSYNCTYPE   CodePoint = 0x1187 // Sync Type
	CodePointRSYNCTYP   CodePoint = 0x11EA // Resync Type
	CodePointFORGET     CodePoint = 0x1186 // Forget
	CodePointXID        CodePoint = 0x1801 // Transaction Identifier
	CodePointXAFLAGS    CodePoint = 0x1903 // XA Flags
	CodePointXARETVAL   CodePoint = 0x1904 // XA Return Value
	CodePointPRPHRCLST  CodePoint = 0x1905 // Prepare Heuristic List
	CodePointXIDCNT     CodePoint = 0x1906 // Transaction ID Count

	// Package Binding & Rebinding
	CodePointBGNBND    CodePoint = 0x2002 // Begin Bind
	CodePointBNDSQLSTT CodePoint = 0x2004 // Bind SQL Statement
	CodePointENDBND    CodePoint = 0x2009 // End Bind
	CodePointDRPPKG    CodePoint = 0x2007 // Drop Package
	CodePointREBIND    CodePoint = 0x2010 // Rebind Package

	// PureQuery & Piggybacked Session Data (PBSD)
	CodePointPBSD        CodePoint = 0xC000 // Piggybacked Session Data
	CodePointPBSD_ISO    CodePoint = 0xC001 // PBSD Isolation Level
	CodePointPBSD_SCHEMA CodePoint = 0xC002 // PBSD Current Schema

	// Reply Messages & Error Reply Messages (*RM)
	CodePointEXCSATRM CodePoint = 0x1443 // Exchange Server Attributes Reply Message
	CodePointACCSECRM CodePoint = 0x14AC // Access Security Reply Message
	CodePointSECCHKRM CodePoint = 0x1219 // Security Check Reply Message
	CodePointACCRDBRM CodePoint = 0x2201 // Access RDB Reply Message
	CodePointRDBACCRM CodePoint = 0x2207 // RDB Access Reply Message
	CodePointRDBAFLRM CodePoint = 0x221A // RDB Access Failed Reply Message
	CodePointRDBATHRM CodePoint = 0x22CB // RDB Authorization Reply Message
	CodePointRDBNACRM CodePoint = 0x2204 // RDB Not Accessed Reply Message
	CodePointRDBNFNRM CodePoint = 0x2211 // RDB Not Found Reply Message
	CodePointRDBUPDRM CodePoint = 0x2218 // RDB Update Reply Message
	CodePointSQLERRRM CodePoint = 0x2213 // SQL Error Reply Message
	CodePointOPNQRYRM CodePoint = 0x2205 // Open Query Reply Message
	CodePointOPNQFLRM CodePoint = 0x2212 // Open Query Failed Reply Message
	CodePointENDQRYRM CodePoint = 0x220B // End Query Reply Message
	CodePointQRYNOPRM CodePoint = 0x2202 // Query Not Open Reply Message
	CodePointQRYPOPRM CodePoint = 0x220F // Query Previously Opened Reply Message
	CodePointDTAMCHRM CodePoint = 0x220E // Data Mismatch Reply Message
	CodePointRSLSETRM CodePoint = 0x2219 // Result Set Reply Message
	CodePointCMDATHRM CodePoint = 0x121C // Command Not Authorized Reply Message
	CodePointCMDCHKRM CodePoint = 0x1254 // Command Check Reply Message
	CodePointCMDNSPRM CodePoint = 0x1250 // Command Not Supported Reply Message
	CodePointCMDCMPRM CodePoint = 0x124B // Command Complete Reply Message
	CodePointCMDVLTRM CodePoint = 0x221D // Command Violation Reply Message
	CodePointCMMRQSRM CodePoint = 0x2225 // Commit Required Reply Message
	CodePointAGNPRMRM CodePoint = 0x1232 // Agent Parameter Reply Message
	CodePointBGNBNDRM CodePoint = 0x2208 // Begin Bind Reply Message
	CodePointABNUOWRM CodePoint = 0x220D // Abnormal Unit of Work Reply Message
	CodePointENDUOWRM CodePoint = 0x220C // End Unit of Work Reply Message
	CodePointMGRLVLRM CodePoint = 0x1210 // Manager Level Reply Message
	CodePointMGRDEPRM CodePoint = 0x1218 // Manager Dependency Reply Message
	CodePointOBJNSPRM CodePoint = 0x1253 // Object Not Supported Reply Message
	CodePointPRCCNVRM CodePoint = 0x1245 // Product Conversion Reply Message
	CodePointPRMNSPRM CodePoint = 0x1251 // Parameter Not Supported Reply Message
	CodePointPKGBNARM CodePoint = 0x2206 // Package Not Bound Reply Message
	CodePointPKGBPARM CodePoint = 0x2209 // Package Bound with Parameters Reply Message
	CodePointRSCLMTRM CodePoint = 0x1233 // Resource Limit Reply Message
	CodePointSYNTAXRM CodePoint = 0x124C // Syntax Error Reply Message
	CodePointTRGNSPRM CodePoint = 0x125F // Target Not Supported Reply Message
	CodePointVALNSPRM CodePoint = 0x1252 // Value Not Supported Reply Message
	CodePointDSCINVRM CodePoint = 0x220A // Descriptor Invalid Reply Message

	// Miscellaneous & Diagnostics
	CodePointCODPNT    CodePoint = 0x000C // Codepoint Identifier
	CodePointCODPNTDR  CodePoint = 0x0064 // Codepoint Data Representation
	CodePointDEPERRCD  CodePoint = 0x119B // Dependency Error Code
	CodePointDSCERRCD  CodePoint = 0x2101 // Descriptor Error Code
	CodePointDIAGLVL   CodePoint = 0x2160 // Diagnostic Level
	CodePointPRCCNVCD  CodePoint = 0x113F // Product Conversion Code
	CodePointRLSCONV   CodePoint = 0x119F // Release Conversion
	CodePointRSCNAM    CodePoint = 0x112D // Resource Name
	CodePointRSCTYP    CodePoint = 0x111F // Resource Type
	CodePointRSNCOD    CodePoint = 0x1127 // Reason Code
	CodePointSTTDECDEL CodePoint = 0x2121 // Statement Decimal Delimiter
	CodePointSTTSTRDEL CodePoint = 0x2120 // Statement String Delimiter
	CodePointSVCERRNO  CodePoint = 0x11B4 // Service Error Number
	CodePointSVRCOD    CodePoint = 0x1149 // Severity Code
	CodePointSYNERRCD  CodePoint = 0x114A // Syntax Error Code
	CodePointTIMEOUT   CodePoint = 0x1907 // Timeout
	CodePointTRGDFTRT  CodePoint = 0x213B // Target Default Return
	CodePointFREPRVREF CodePoint = 0x214C // Free Previous References
	CodePointMONITOR   CodePoint = 0x1900 // Monitor
	CodePointMONITORRD CodePoint = 0x1C00 // Monitor Reply Data
)

// DRDA Security Mechanism (SECMEC) Constants
const (
	SecMecDCESEC      uint16 = 1  // DCE Security
	SecMecUSRIDPWD    uint16 = 3  // Plain User ID and Password
	SecMecUSRIDONL    uint16 = 4  // User ID Only
	SecMecUSRIDNWPWD  uint16 = 5  // User ID with New Password
	SecMecUSRSBSPWD   uint16 = 6  // User ID and Substitute Password
	SecMecUSRENCPWD   uint16 = 7  // User ID and Encrypted Password (AES)
	SecMecUSRSSBPWD   uint16 = 8  // User ID and Encrypted Substitute Password
	SecMecEUSRIDPWD   uint16 = 9  // Encrypted User ID and Encrypted Password (DES)
	SecMecEUSRIDNWPWD uint16 = 10 // Encrypted User ID and New Encrypted Password
)

// String returns the symbolic name of the CodePoint, or hex format if unknown.
func (cp CodePoint) String() string {
	if name, ok := codePointNames[cp]; ok {
		return name
	}
	return fmt.Sprintf("CodePoint(0x%04X)", uint16(cp))
}

var codePointNames = map[CodePoint]string{
	CodePointEXCSAT:      "EXCSAT",
	CodePointEXCSATRD:    "EXCSATRD",
	CodePointACCSEC:      "ACCSEC",
	CodePointACCSECRD:    "ACCSECRD",
	CodePointSECCHK:      "SECCHK",
	CodePointSECCHKCD:    "SECCHKCD",
	CodePointSECMEC:      "SECMEC",
	CodePointSECMGR:      "SECMGR",
	CodePointSECMGRNM:    "SECMGRNM",
	CodePointSECTKN:      "SECTKN",
	CodePointUSRID:       "USRID",
	CodePointPASSWORD:    "PASSWORD",
	CodePointNEWPASSWORD: "NEWPASSWORD",
	CodePointACCRDB:      "ACCRDB",
	CodePointRDBNAM:      "RDBNAM",
	CodePointRDBINTTKN:   "RDBINTTKN",
	CodePointRDBALWUPD:   "RDBALWUPD",
	CodePointRDBACCCL:    "RDBACCCL",
	CodePointCRRTKN:      "CRRTKN",
	CodePointPRDID:       "PRDID",
	CodePointPRDDTA:      "PRDDTA",
	CodePointSRVNAM:      "SRVNAM",
	CodePointSRVCLSNM:    "SRVCLSNM",
	CodePointSRVRLSLV:    "SRVRLSLV",
	CodePointEXTNAM:      "EXTNAM",
	CodePointSPVNAM:      "SPVNAM",
	CodePointVRSNAM:      "VRSNAM",
	CodePointSRVDGN:      "SRVDGN",
	CodePointAGENT:       "AGENT",
	CodePointMGRLVLLS:    "MGRLVLLS",
	CodePointMGRLVLN:     "MGRLVLN",
	CodePointSQLAM:       "SQLAM",
	CodePointCMNTCPIP:    "CMNTCPIP",
	CodePointCMNAPPC:     "CMNAPPC",
	CodePointCMNSYNCPT:   "CMNSYNCPT",
	CodePointUNICODEMGR:  "UNICODEMGR",
	CodePointCCSIDMGR:    "CCSIDMGR",
	CodePointCCSIDSBC:    "CCSIDSBC",
	CodePointCCSIDDBC:    "CCSIDDBC",
	CodePointCCSIDMBC:    "CCSIDMBC",
	CodePointCSTMBCS:     "CSTMBCS",
	CodePointSUPERVISOR:  "SUPERVISOR",
	CodePointRSYNCMGR:    "RSYNCMGR",
	CodePointSYNCPTMGR:   "SYNCPTMGR",
	CodePointXAMGR:       "XAMGR",
	CodePointDICTIONARY:  "DICTIONARY",
	CodePointRDB:         "RDB",
	CodePointPRPSQLSTT:   "PRPSQLSTT",
	CodePointEXCSQLSTT:   "EXCSQLSTT",
	CodePointEXCSQLIMM:   "EXCSQLIMM",
	CodePointEXCSQLSET:   "EXCSQLSET",
	CodePointDSCSQLSTT:   "DSCSQLSTT",
	CodePointDSCRDBTBL:   "DSCRDBTBL",
	CodePointSQLSTT:      "SQLSTT",
	CodePointSQLATTR:     "SQLATTR",
	CodePointSQLSTTVRB:   "SQLSTTVRB",
	CodePointPKGNAMCT:    "PKGNAMCT",
	CodePointPKGNAMCSN:   "PKGNAMCSN",
	CodePointPKGCNSTKN:   "PKGCNSTKN",
	CodePointPKGID:       "PKGID",
	CodePointPKGSNLST:    "PKGSNLST",
	CodePointPKGDFTCST:   "PKGDFTCST",
	CodePointRDBCOLID:    "RDBCOLID",
	CodePointRTNSQLDA:    "RTNSQLDA",
	CodePointTYPSQLDA:    "TYPSQLDA",
	CodePointTYPDEFNAM:   "TYPDEFNAM",
	CodePointTYPDEFOVR:   "TYPDEFOVR",
	CodePointOPNQRY:      "OPNQRY",
	CodePointCNTQRY:      "CNTQRY",
	CodePointCLSQRY:      "CLSQRY",
	CodePointQRYDSC:      "QRYDSC",
	CodePointQRYDTA:      "QRYDTA",
	CodePointQRYBLKCTL:   "QRYBLKCTL",
	CodePointQRYBLKSZ:    "QRYBLKSZ",
	CodePointQRYBLKRST:   "QRYBLKRST",
	CodePointQRYPRCTYP:   "QRYPRCTYP",
	CodePointQRYCLSIMP:   "QRYCLSIMP",
	CodePointQRYCLSRLS:   "QRYCLSRLS",
	CodePointQRYOPTVAL:   "QRYOPTVAL",
	CodePointQRYINSID:    "QRYINSID",
	CodePointQRYATTUPD:   "QRYATTUPD",
	CodePointQRYRELSCR:   "QRYRELSCR",
	CodePointQRYSCRORN:   "QRYSCRORN",
	CodePointQRYROWNBR:   "QRYROWNBR",
	CodePointQRYROWSNS:   "QRYROWSNS",
	CodePointQRYRFRTBL:   "QRYRFRTBL",
	CodePointQRYATTSCR:   "QRYATTSCR",
	CodePointQRYATTSNS:   "QRYATTSNS",
	CodePointQRYROWSET:   "QRYROWSET",
	CodePointQRYRTNDTA:   "QRYRTNDTA",
	CodePointMAXBLKEXT:   "MAXBLKEXT",
	CodePointMAXRSLCNT:   "MAXRSLCNT",
	CodePointRSLSETFLG:   "RSLSETFLG",
	CodePointNBRROW:      "NBRROW",
	CodePointOUTEXP:      "OUTEXP",
	CodePointOUTOVR:      "OUTOVR",
	CodePointOUTOVROPT:   "OUTOVROPT",
	CodePointPRCNAM:      "PRCNAM",
	CodePointFIXROWPRC:   "FIXROWPRC",
	CodePointFRCFIXROW:   "FRCFIXROW",
	CodePointLMTBLKPRC:   "LMTBLKPRC",
	CodePointSQLDTA:      "SQLDTA",
	CodePointSQLDTARD:    "SQLDTARD",
	CodePointSQLCARD:     "SQLCARD",
	CodePointSQLDARD:     "SQLDARD",
	CodePointSQLRSLRD:    "SQLRSLRD",
	CodePointSQLCINRD:    "SQLCINRD",
	CodePointSQLCSRHLD:   "SQLCSRHLD",
	CodePointEXTDTA:      "EXTDTA",
	CodePointFDODSC:      "FDODSC",
	CodePointFDODTA:      "FDODTA",
	CodePointFDODSCOFF:   "FDODSCOFF",
	CodePointFDOPRMOFF:   "FDOPRMOFF",
	CodePointFDOTRPOFF:   "FDOTRPOFF",
	CodePointRTNEXTDTA:   "RTNEXTDTA",
	CodePointDYNDTAFMT:   "DYNDTAFMT",
	CodePointRDBCMM:      "RDBCMM",
	CodePointRDBRLLBCK:   "RDBRLLBCK",
	CodePointRDBRLLBCK2:  "RDBRLLBCK2",
	CodePointRDBCMTOK:    "RDBCMTOK",
	CodePointUOWDSP:      "UOWDSP",
	CodePointSYNCCTL:     "SYNCCTL",
	CodePointSYNCRSY:     "SYNCRSY",
	CodePointSYNCLOG:     "SYNCLOG",
	CodePointSYNCCRD:     "SYNCCRD",
	CodePointSYNCRRD:     "SYNCRRD",
	CodePointSYNCTYPE:    "SYNCTYPE",
	CodePointRSYNCTYP:    "RSYNCTYP",
	CodePointFORGET:      "FORGET",
	CodePointXID:         "XID",
	CodePointXAFLAGS:     "XAFLAGS",
	CodePointXARETVAL:    "XARETVAL",
	CodePointPRPHRCLST:   "PRPHRCLST",
	CodePointXIDCNT:      "XIDCNT",
	CodePointBGNBND:      "BGNBND",
	CodePointBNDSQLSTT:   "BNDSQLSTT",
	CodePointENDBND:      "ENDBND",
	CodePointDRPPKG:      "DRPPKG",
	CodePointREBIND:      "REBIND",
	CodePointPBSD:        "PBSD",
	CodePointPBSD_ISO:    "PBSD_ISO",
	CodePointPBSD_SCHEMA: "PBSD_SCHEMA",
	CodePointSECCHKRM:    "SECCHKRM",
	CodePointACCRDBRM:    "ACCRDBRM",
	CodePointRDBACCRM:    "RDBACCRM",
	CodePointRDBAFLRM:    "RDBAFLRM",
	CodePointRDBATHRM:    "RDBATHRM",
	CodePointRDBNACRM:    "RDBNACRM",
	CodePointRDBNFNRM:    "RDBNFNRM",
	CodePointRDBUPDRM:    "RDBUPDRM",
	CodePointSQLERRRM:    "SQLERRRM",
	CodePointOPNQRYRM:    "OPNQRYRM",
	CodePointOPNQFLRM:    "OPNQFLRM",
	CodePointENDQRYRM:    "ENDQRYRM",
	CodePointQRYNOPRM:    "QRYNOPRM",
	CodePointQRYPOPRM:    "QRYPOPRM",
	CodePointDTAMCHRM:    "DTAMCHRM",
	CodePointRSLSETRM:    "RSLSETRM",
	CodePointCMDATHRM:    "CMDATHRM",
	CodePointCMDCHKRM:    "CMDCHKRM",
	CodePointCMDNSPRM:    "CMDNSPRM",
	CodePointCMDCMPRM:    "CMDCMPRM",
	CodePointCMDVLTRM:    "CMDVLTRM",
	CodePointCMMRQSRM:    "CMMRQSRM",
	CodePointAGNPRMRM:    "AGNPRMRM",
	CodePointBGNBNDRM:    "BGNBNDRM",
	CodePointABNUOWRM:    "ABNUOWRM",
	CodePointENDUOWRM:    "ENDUOWRM",
	CodePointMGRLVLRM:    "MGRLVLRM",
	CodePointMGRDEPRM:    "MGRDEPRM",
	CodePointOBJNSPRM:    "OBJNSPRM",
	CodePointPRCCNVRM:    "PRCCNVRM",
	CodePointPRMNSPRM:    "PRMNSPRM",
	CodePointPKGBNARM:    "PKGBNARM",
	CodePointPKGBPARM:    "PKGBPARM",
	CodePointRSCLMTRM:    "RSCLMTRM",
	CodePointSYNTAXRM:    "SYNTAXRM",
	CodePointTRGNSPRM:    "TRGNSPRM",
	CodePointVALNSPRM:    "VALNSPRM",
	CodePointDSCINVRM:    "DSCINVRM",
	CodePointCODPNT:      "CODPNT",
	CodePointCODPNTDR:    "CODPNTDR",
	CodePointDEPERRCD:    "DEPERRCD",
	CodePointDSCERRCD:    "DSCERRCD",
	CodePointDIAGLVL:     "DIAGLVL",
	CodePointPRCCNVCD:    "PRCCNVCD",
	CodePointRLSCONV:     "RLSCONV",
	CodePointRSCNAM:      "RSCNAM",
	CodePointRSCTYP:      "RSCTYP",
	CodePointRSNCOD:      "RSNCOD",
	CodePointSTTDECDEL:   "STTDECDEL",
	CodePointSTTSTRDEL:   "STTSTRDEL",
	CodePointSVCERRNO:    "SVCERRNO",
	CodePointSVRCOD:      "SVRCOD",
	CodePointSYNERRCD:    "SYNERRCD",
	CodePointTIMEOUT:     "TIMEOUT",
	CodePointTRGDFTRT:    "TRGDFTRT",
	CodePointFREPRVREF:   "FREPRVREF",
	CodePointMONITOR:     "MONITOR",
	CodePointMONITORRD:   "MONITORRD",
}
