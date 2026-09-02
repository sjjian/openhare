package types

import "fmt"

// SQLType represents an IBM Db2 SQL data type identifier.
type SQLType uint16

// IBM Db2 SQL Type Constants
const (
	SQLTypeDate       SQLType = 384
	SQLTypeNDate      SQLType = 385 // Nullable Date
	SQLTypeTime       SQLType = 388
	SQLTypeNTime      SQLType = 389 // Nullable Time
	SQLTypeTimestamp  SQLType = 392
	SQLTypeNTimestamp SQLType = 393 // Nullable Timestamp
	SQLTypeDataLink   SQLType = 396
	SQLTypeNDataLink  SQLType = 397 // Nullable DataLink

	SQLTypeBlob    SQLType = 404
	SQLTypeNBlob   SQLType = 405 // Nullable Blob
	SQLTypeClob    SQLType = 408
	SQLTypeNClob   SQLType = 409 // Nullable Clob
	SQLTypeDbClob  SQLType = 412
	SQLTypeNDbClob SQLType = 413 // Nullable DbClob

	SQLTypeVarChar   SQLType = 448
	SQLTypeNVarChar  SQLType = 449 // Nullable VarChar
	SQLTypeChar      SQLType = 452
	SQLTypeNChar     SQLType = 453 // Nullable Char
	SQLTypeLong      SQLType = 456
	SQLTypeNLong     SQLType = 457 // Nullable Long VarChar
	SQLTypeCStr      SQLType = 460
	SQLTypeNCStr     SQLType = 461 // Nullable C-String
	SQLTypeVarGraph  SQLType = 464
	SQLTypeNVarGraph SQLType = 465 // Nullable VarGraphic
	SQLTypeGraphic   SQLType = 468
	SQLTypeNGraphic  SQLType = 469 // Nullable Graphic
	SQLTypeLonGraph  SQLType = 472
	SQLTypeNLonGraph SQLType = 473 // Nullable Long Graphic

	SQLTypeLStr  SQLType = 476
	SQLTypeNLStr SQLType = 477 // Nullable L-String

	SQLTypeFloat    SQLType = 480
	SQLTypeNFloat   SQLType = 481 // Nullable Float
	SQLTypeDecimal  SQLType = 484
	SQLTypeNDecimal SQLType = 485 // Nullable Decimal
	SQLTypeZoned    SQLType = 488
	SQLTypeNZoned   SQLType = 489 // Nullable Zoned Decimal

	SQLTypeBigInt   SQLType = 492
	SQLTypeNBigInt  SQLType = 493 // Nullable BigInt
	SQLTypeInteger  SQLType = 496
	SQLTypeNInteger SQLType = 497 // Nullable Integer
	SQLTypeSmall    SQLType = 500
	SQLTypeNSmall   SQLType = 501 // Nullable SmallInt

	SQLTypeNumeric  SQLType = 504
	SQLTypeNNumeric SQLType = 505 // Nullable Numeric

	SQLTypeRowID      SQLType = 904
	SQLTypeNRowID     SQLType = 905 // Nullable RowID
	SQLTypeVarBinary  SQLType = 908
	SQLTypeNVarBinary SQLType = 909 // Nullable VarBinary
	SQLTypeBinary     SQLType = 912
	SQLTypeNBinary    SQLType = 913 // Nullable Binary

	SQLTypeBlobLocator    SQLType = 960
	SQLTypeNBlobLocator   SQLType = 961 // Nullable Blob Locator
	SQLTypeClobLocator    SQLType = 964
	SQLTypeNClobLocator   SQLType = 965 // Nullable Clob Locator
	SQLTypeDbClobLocator  SQLType = 968
	SQLTypeNDbClobLocator SQLType = 969 // Nullable DbClob Locator

	SQLTypeXML  SQLType = 988
	SQLTypeNXML SQLType = 989 // Nullable XML

	SQLTypeDecFloat  SQLType = 996
	SQLTypeNDecFloat SQLType = 997 // Nullable DecFloat

	SQLTypeFakeUDT  SQLType = 2000
	SQLTypeFakeNUDT SQLType = 2001

	SQLTypeBoolean  SQLType = 2436
	SQLTypeNBoolean SQLType = 2437 // Nullable Boolean
)

// IsNullable returns true if the SQL type allows NULL values (odd numbers).
func (t SQLType) IsNullable() bool {
	return t%2 != 0
}

// BaseType returns the non-nullable base SQL type.
func (t SQLType) BaseType() SQLType {
	if t.IsNullable() {
		return t - 1
	}
	return t
}

// String returns the human-readable representation of the SQLType.
func (t SQLType) String() string {
	if name, ok := sqlTypeNames[t]; ok {
		return name
	}
	return fmt.Sprintf("SQLType(%d)", uint16(t))
}

var sqlTypeNames = map[SQLType]string{
	SQLTypeDate:           "DATE",
	SQLTypeNDate:          "DATE (NULLABLE)",
	SQLTypeTime:           "TIME",
	SQLTypeNTime:          "TIME (NULLABLE)",
	SQLTypeTimestamp:      "TIMESTAMP",
	SQLTypeNTimestamp:     "TIMESTAMP (NULLABLE)",
	SQLTypeDataLink:       "DATALINK",
	SQLTypeNDataLink:      "DATALINK (NULLABLE)",
	SQLTypeBlob:           "BLOB",
	SQLTypeNBlob:          "BLOB (NULLABLE)",
	SQLTypeClob:           "CLOB",
	SQLTypeNClob:          "CLOB (NULLABLE)",
	SQLTypeDbClob:         "DBCLOB",
	SQLTypeNDbClob:        "DBCLOB (NULLABLE)",
	SQLTypeVarChar:        "VARCHAR",
	SQLTypeNVarChar:       "VARCHAR (NULLABLE)",
	SQLTypeChar:           "CHAR",
	SQLTypeNChar:          "CHAR (NULLABLE)",
	SQLTypeLong:           "LONG VARCHAR",
	SQLTypeNLong:          "LONG VARCHAR (NULLABLE)",
	SQLTypeCStr:           "CSTR",
	SQLTypeNCStr:          "CSTR (NULLABLE)",
	SQLTypeVarGraph:       "VARGRAPHIC",
	SQLTypeNVarGraph:      "VARGRAPHIC (NULLABLE)",
	SQLTypeGraphic:        "GRAPHIC",
	SQLTypeNGraphic:       "GRAPHIC (NULLABLE)",
	SQLTypeLonGraph:       "LONG GRAPHIC",
	SQLTypeNLonGraph:      "LONG GRAPHIC (NULLABLE)",
	SQLTypeLStr:           "LSTR",
	SQLTypeNLStr:          "LSTR (NULLABLE)",
	SQLTypeFloat:          "FLOAT",
	SQLTypeNFloat:         "FLOAT (NULLABLE)",
	SQLTypeDecimal:        "DECIMAL",
	SQLTypeNDecimal:       "DECIMAL (NULLABLE)",
	SQLTypeZoned:          "ZONED",
	SQLTypeNZoned:         "ZONED (NULLABLE)",
	SQLTypeBigInt:         "BIGINT",
	SQLTypeNBigInt:        "BIGINT (NULLABLE)",
	SQLTypeInteger:        "INTEGER",
	SQLTypeNInteger:       "INTEGER (NULLABLE)",
	SQLTypeSmall:          "SMALLINT",
	SQLTypeNSmall:         "SMALLINT (NULLABLE)",
	SQLTypeNumeric:        "NUMERIC",
	SQLTypeNNumeric:       "NUMERIC (NULLABLE)",
	SQLTypeRowID:          "ROWID",
	SQLTypeNRowID:         "ROWID (NULLABLE)",
	SQLTypeVarBinary:      "VARBINARY",
	SQLTypeNVarBinary:     "VARBINARY (NULLABLE)",
	SQLTypeBinary:         "BINARY",
	SQLTypeNBinary:        "BINARY (NULLABLE)",
	SQLTypeBlobLocator:    "BLOB LOCATOR",
	SQLTypeNBlobLocator:   "BLOB LOCATOR (NULLABLE)",
	SQLTypeClobLocator:    "CLOB LOCATOR",
	SQLTypeNClobLocator:   "CLOB LOCATOR (NULLABLE)",
	SQLTypeDbClobLocator:  "DBCLOB LOCATOR",
	SQLTypeNDbClobLocator: "DBCLOB LOCATOR (NULLABLE)",
	SQLTypeXML:            "XML",
	SQLTypeNXML:           "XML (NULLABLE)",
	SQLTypeDecFloat:       "DECFLOAT",
	SQLTypeNDecFloat:      "DECFLOAT (NULLABLE)",
	SQLTypeBoolean:        "BOOLEAN",
	SQLTypeNBoolean:       "BOOLEAN (NULLABLE)",
}
