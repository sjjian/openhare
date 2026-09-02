package db2

import (
	"database/sql/driver"
	"io"
	"reflect"
	"time"

	"github.com/go-db2/go-db2/network"
	"github.com/go-db2/go-db2/types"
)

// ResultSet represents a single tabular result set of columns and rows.
type ResultSet struct {
	Columns []network.ColumnDescription
	Data    [][]driver.Value
}

// Rows implements database/sql/driver.Rows, driver.RowsNextResultSet, and column type introspection interfaces.
type Rows struct {
	resultSets   []ResultSet
	currSetIndex int
	cursor       int
	closed       bool
}

// NewRows instantiates a new driver.Rows container for a single result set.
func NewRows(columns []network.ColumnDescription, data [][]driver.Value) *Rows {
	return &Rows{
		resultSets: []ResultSet{
			{Columns: columns, Data: data},
		},
		currSetIndex: 0,
		cursor:       0,
	}
}

// NewMultiRows instantiates a new driver.Rows container for multiple result sets.
func NewMultiRows(sets []ResultSet) *Rows {
	if len(sets) == 0 {
		sets = []ResultSet{{}}
	}
	return &Rows{
		resultSets:   sets,
		currSetIndex: 0,
		cursor:       0,
	}
}

// currentSet returns the active result set.
func (r *Rows) currentSet() *ResultSet {
	if r.currSetIndex >= 0 && r.currSetIndex < len(r.resultSets) {
		return &r.resultSets[r.currSetIndex]
	}
	return &ResultSet{}
}

// Columns returns the names of the columns in the current result set.
func (r *Rows) Columns() []string {
	cur := r.currentSet()
	names := make([]string, len(cur.Columns))
	for i, c := range cur.Columns {
		names[i] = c.Name
	}
	return names
}

// Close closes the rows iterator.
func (r *Rows) Close() error {
	r.closed = true
	r.resultSets = nil
	return nil
}

// Next is called to populate the next row of data into the provided slice.
func (r *Rows) Next(dest []driver.Value) error {
	if r.closed {
		return io.EOF
	}
	cur := r.currentSet()
	if r.cursor >= len(cur.Data) {
		return io.EOF
	}

	row := cur.Data[r.cursor]
	r.cursor++

	for i := range dest {
		if i < len(row) {
			dest[i] = row[i]
		} else {
			dest[i] = nil
		}
	}

	return nil
}

// HasNextResultSet returns whether there are more result sets available.
func (r *Rows) HasNextResultSet() bool {
	return !r.closed && r.currSetIndex+1 < len(r.resultSets)
}

// NextResultSet advances the iterator to the next result set.
func (r *Rows) NextResultSet() error {
	if r.closed {
		return io.EOF
	}
	if !r.HasNextResultSet() {
		return io.EOF
	}
	r.currSetIndex++
	r.cursor = 0
	return nil
}

// ColumnTypeScanType returns the Go type that can be used to scan types into.
func (r *Rows) ColumnTypeScanType(index int) reflect.Type {
	cur := r.currentSet()
	if index < 0 || index >= len(cur.Columns) {
		return reflect.TypeOf(new(any)).Elem()
	}

	sqlType := types.SQLType(cur.Columns[index].SQLType).BaseType()
	switch sqlType {
	case types.SQLTypeSmall:
		return reflect.TypeOf(int16(0))
	case types.SQLTypeInteger:
		return reflect.TypeOf(int32(0))
	case types.SQLTypeBigInt:
		return reflect.TypeOf(int64(0))
	case types.SQLTypeFloat:
		return reflect.TypeOf(float64(0))
	case types.SQLTypeDate, types.SQLTypeTimestamp:
		return reflect.TypeOf(time.Time{})
	case types.SQLTypeBlob, types.SQLTypeBinary, types.SQLTypeVarBinary:
		return reflect.TypeOf([]byte{})
	case types.SQLTypeBoolean:
		return reflect.TypeOf(true)
	default:
		return reflect.TypeOf("")
	}
}

// ColumnTypeDatabaseTypeName returns the database system type name.
func (r *Rows) ColumnTypeDatabaseTypeName(index int) string {
	cur := r.currentSet()
	if index < 0 || index >= len(cur.Columns) {
		return ""
	}
	return types.SQLType(cur.Columns[index].SQLType).BaseType().String()
}

// ColumnTypeNullable returns whether the column is nullable.
func (r *Rows) ColumnTypeNullable(index int) (nullable, ok bool) {
	cur := r.currentSet()
	if index < 0 || index >= len(cur.Columns) {
		return false, false
	}
	return cur.Columns[index].Nullable, true
}

// ColumnTypeLength returns the length of the column type if variable length.
func (r *Rows) ColumnTypeLength(index int) (length int64, ok bool) {
	cur := r.currentSet()
	if index < 0 || index >= len(cur.Columns) {
		return 0, false
	}
	return cur.Columns[index].Length, true
}

// ColumnTypePrecisionScale returns the precision and scale for decimal and numeric types.
func (r *Rows) ColumnTypePrecisionScale(index int) (precision, scale int64, ok bool) {
	cur := r.currentSet()
	if index < 0 || index >= len(cur.Columns) {
		return 0, 0, false
	}
	col := cur.Columns[index]
	if col.Precision > 0 || col.Scale > 0 {
		return int64(col.Precision), int64(col.Scale), true
	}
	return 0, 0, false
}

var (
	_ driver.Rows                           = (*Rows)(nil)
	_ driver.RowsNextResultSet              = (*Rows)(nil)
	_ driver.RowsColumnTypeScanType         = (*Rows)(nil)
	_ driver.RowsColumnTypeDatabaseTypeName = (*Rows)(nil)
	_ driver.RowsColumnTypeNullable         = (*Rows)(nil)
	_ driver.RowsColumnTypeLength           = (*Rows)(nil)
	_ driver.RowsColumnTypePrecisionScale   = (*Rows)(nil)
)
