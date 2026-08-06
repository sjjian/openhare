package duckdb

import (
	"context"
	"database/sql/driver"
	"errors"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// Appender wraps functionality around the DuckDB appender.
// It enables efficient bulk transformations.
type Appender struct {
	// The raw sql.Conn's driver connection.
	conn *Conn
	// The DuckDB appender.
	appender mapping.Appender
	// True, if the appender has been closed.
	closed bool

	// The chunk to append to.
	chunk DataChunk
	// The column types of the table to append to.
	types []mapping.LogicalType
	// The number of appended rows.
	rowCount int
}

// NewAppenderFromConn returns a new Appender for the default catalog.
// The Appender batches rows via AppendRow. Upon reaching the auto-flush threshold or
// upon calling Flush or Close, it appends these rows to the table.
// Thus, it can be used instead of INSERT INTO statements to enable bulk insertions.
// `driverConn` is the raw sql.Conn's driver connection.
// `schema` and `table` specify the table (`schema.table`) to append to.
func NewAppenderFromConn(driverConn driver.Conn, schema, table string) (*Appender, error) {
	return NewAppender(driverConn, "", schema, table)
}

// NewAppender returns a new Appender.
// The Appender batches rows via AppendRow. Upon reaching the auto-flush threshold or
// upon calling Flush or Close, it appends these rows to the table.
// Thus, it can be used instead of INSERT INTO statements to enable bulk insertions.
// `driverConn` is the raw sql.Conn's driver connection.
// `catalog`, `schema` and `table` specify the table (`catalog.schema.table`) to append to.
func NewAppender(driverConn driver.Conn, catalog, schema, table string) (*Appender, error) {
	return newTableAppender(driverConn, catalog, schema, table, nil)
}

// NewAppenderWithColumns returns a new Appender that is restricted to a subset of columns.
// This enables more efficient appends by narrowing the appender scope to only the provided columns.
// The Appender batches rows via AppendRow. Each row must provide values for exactly the selected columns.
// DuckDB will fill columns not selected with their DEFAULT values (or NULL).
// Note: Changing the active column set causes a flush in DuckDB. Therefore, we cannot change them later during the
// lifetime of the Appender.
// Important: `QueryAppender` is the recommended and more performant way to append data to a table with a subset
// of columns, we expose this mostly for backwards compatibility.
func NewAppenderWithColumns(driverConn driver.Conn, catalog, schema, table string, columns []string) (*Appender, error) {
	if len(columns) == 0 {
		return nil, invalidInputError("empty array", "non-empty array")
	}
	return newTableAppender(driverConn, catalog, schema, table, columns)
}

// newTableAppender consolidates the common logic of creating an appender, optionally narrowing
// it to a subset of columns before fetching types. NewAppender and NewAppenderWithColumns delegate to this helper
func newTableAppender(driverConn driver.Conn, catalog, schema, table string, columns []string) (*Appender, error) {
	var a Appender
	err := a.appenderConn(driverConn)
	if err != nil {
		return nil, err
	}

	state := mapping.AppenderCreateExt(a.conn.conn, catalog, schema, table, &a.appender)
	if state == mapping.StateError {
		err = errorDataError(mapping.AppenderErrorData(a.appender))
		mapping.AppenderDestroy(&a.appender)
		return nil, getError(errAppenderCreation, err)
	}

	// If a subset of columns is provided, activate only those columns on the appender
	// BEFORE fetching types, so the type enumeration reflects only the active columns.
	if len(columns) > 0 {
		if err := a.initTableColumns(columns); err != nil {
			mapping.AppenderDestroy(&a.appender)
			return nil, err
		}
		return a.initAppenderChunk()
	}

	// Get the column types for all columns when no subset is specified (already happens in C++ side when not
	// activating columns).
	// (In DuckDB, if columns are not added, BaseAppender::GetActiveTypes() will return all table columns)
	columnCount := mapping.AppenderColumnCount(a.appender)
	for i := range uint64(columnCount) {
		colType := mapping.AppenderColumnType(a.appender, mapping.IdxT(i))
		a.types = append(a.types, colType)

		// Ensure that we only create an appender for supported column types.
		t := mapping.GetTypeId(colType)
		// TODO: duckdb-rs can append scalars into VARIANT columns because it
		// uses DuckDB's row-wise duckdb_append_* API, which lets DuckDB coerce
		// each value. This appender writes typed data chunks through Go vector
		// setters, so enabling VARIANT here needs a separate write path or
		// setter design rather than only removing it from the unsupported map.
		name, found := unsupportedValueTypeToStringMap[t]
		if found {
			err = addIndexToError(unsupportedTypeError(name), int(i)+1)
			destroyLogicalTypes(a.types)
			mapping.AppenderDestroy(&a.appender)
			return nil, getError(errAppenderCreation, err)
		}
	}

	return a.initAppenderChunk()
}

// When providing columns to the appender (during initialization), we activate them and fetch their types.
func (a *Appender) initTableColumns(columns []string) error {
	// When the subset is greater than all table columns, early-out with an error.
	if mapping.AppenderColumnCount(a.appender) < mapping.IdxT(len(columns)) {
		return getError(errAppenderCreation, errors.New("column count exceeds table column count"))
	}

	activatedColumns := make(map[string]struct{}, len(columns))
	for i, col := range columns {
		if _, exists := activatedColumns[col]; exists {
			destroyLogicalTypes(a.types)
			return getError(errAppenderCreation, errors.New("duplicate column in appender columns list: "+col))
		}

		if mapping.AppenderAddColumn(a.appender, col) == mapping.StateError {
			destroyLogicalTypes(a.types)
			duckError := getDuckDBError(mapping.AppenderError(a.appender))
			return getError(errAppenderCreation, duckError)
		}

		// In DuckDB, when activating a column (`AppenderAddColumn`), we push it to the active types,
		// and then `AppenderColumnType` will result in the logical type corresponding to that index
		colType := mapping.AppenderColumnType(a.appender, mapping.IdxT(i))
		a.types = append(a.types, colType)

		// Ensure that we only create an appender for supported column types.
		t := mapping.GetTypeId(colType)
		// TODO: Keep this in sync with the all-column appender path above.
		// VARIANT support here needs an appender design that delegates scalar
		// coercion to DuckDB instead of routing through Go vector setters.
		if name, found := unsupportedValueTypeToStringMap[t]; found {
			err := addIndexToError(unsupportedTypeError(name), i+1)
			destroyLogicalTypes(a.types)
			return getError(errAppenderCreation, err)
		}

		activatedColumns[col] = struct{}{}
	}

	// Sanity check: active column count should match provided columns
	if mapping.AppenderColumnCount(a.appender) != mapping.IdxT(len(columns)) {
		destroyLogicalTypes(a.types)
		return getError(errAppenderCreation, errors.New("duckdb: column count mismatch after activation"))
	}
	return nil
}

// NewQueryAppender returns a new query Appender.
// The Appender batches rows via AppendRow. Upon reaching the auto-flush threshold or
// upon calling Flush or Close, it executes the query, treating the batched rows as a temporary table.
// `driverConn` is the raw sql.Conn's driver connection.
// `query` is the query to execute. It can be a INSERT, DELETE, UPDATE or MERGE INTO statement.
// `table` is the (optional) table name of the temporary table containing the batched rows.
// It defaults to `appended_data`.
// `colTypes` are the column types of the temporary table.
// `colNames` are the (optional) names of the columns of the temporary table containing the batched rows.
// They default to `col1`, `col2`, ...
func NewQueryAppender(driverConn driver.Conn, query, table string, colTypes []TypeInfo, colNames []string) (*Appender, error) {
	var a Appender
	err := a.appenderConn(driverConn)
	if err != nil {
		return nil, err
	}

	if query == "" {
		return nil, getError(errAppenderEmptyQuery, nil)
	}
	if len(colTypes) == 0 {
		return nil, getError(errAppenderEmptyColumnTypes, nil)
	}
	if len(colNames) != 0 && len(colTypes) != 0 {
		if len(colNames) != len(colTypes) {
			return nil, getError(errAppenderColumnMismatch, nil)
		}
	}

	// Get the logical types via the type infos.
	for _, ct := range colTypes {
		a.types = append(a.types, ct.logicalType())
	}

	state := mapping.AppenderCreateQuery(a.conn.conn, query, a.types, table, colNames, &a.appender)
	if state == mapping.StateError {
		destroyLogicalTypes(a.types)
		err = errorDataError(mapping.AppenderErrorData(a.appender))
		mapping.AppenderDestroy(&a.appender)
		return nil, getError(errAppenderCreation, err)
	}

	return a.initAppenderChunk()
}

// NewTableAppender returns a new query based on a target table.
// The Appender batches rows via AppendRow. Upon reaching the auto-flush threshold or
// upon calling Flush or Close, it executes the query, treating the batched rows as a temporary table.
// The temporary table of the NewTableAppender expects the same column types as the target table,
// omitting the need to specify the column types yourself (as is necessary for NewQueryAppender).
// `driverConn` is the raw sql.Conn's driver connection.
// `query` is the query to execute. It can be a INSERT, DELETE, UPDATE or MERGE INTO statement.
// The name of the temporary table is `appended_data`, and its column names are `col1`, `col2`, ...
// `catalog`, `schema` and `table` specify the target table to append to.
// The column types of the temporary table match the column types of the target table.
// `colNames` must be columns in the target table.
// It defaults to all columns, if empty.
func NewTableAppender(driverConn driver.Conn, query, catalog, schema, table string, colNames []string) (*Appender, error) {
	var a Appender
	err := a.appenderConn(driverConn)
	if err != nil {
		return nil, err
	}

	if query == "" {
		return nil, getError(errAppenderEmptyQuery, nil)
	}

	// Get the logical types via the table description.
	var desc mapping.TableDescription
	state := mapping.TableDescriptionCreateExt(a.conn.conn, catalog, schema, table, &desc)
	defer mapping.TableDescriptionDestroy(&desc)
	if state == mapping.StateError {
		errStr := mapping.TableDescriptionError(desc)
		return nil, getError(errAppenderCreation, errors.New(errStr))
	}

	// First, put the names in a map.
	allColumns := len(colNames) == 0
	m := make(map[string]bool)
	if !allColumns {
		for _, name := range colNames {
			if _, ok := m[name]; ok {
				return nil, getError(errAppenderDuplicateColumn, nil)
			}
			m[name] = true
		}
	}

	// Now set the logical types.
	colCount := mapping.TableDescriptionGetColumnCount(desc)
	for i := range uint64(colCount) {
		if !allColumns {
			colName := mapping.TableDescriptionGetColumnName(desc, mapping.IdxT(i))
			if _, ok := m[colName]; !ok {
				continue
			}
		}
		logicalType := mapping.TableDescriptionGetColumnType(desc, mapping.IdxT(i))
		a.types = append(a.types, logicalType)
	}
	if !allColumns && len(a.types) != len(colNames) {
		destroyLogicalTypes(a.types)
		return nil, getError(errAppenderColumnMismatch, nil)
	}

	state = mapping.AppenderCreateQuery(a.conn.conn, query, a.types, "", []string{}, &a.appender)
	if state == mapping.StateError {
		destroyLogicalTypes(a.types)
		err = errorDataError(mapping.AppenderErrorData(a.appender))
		mapping.AppenderDestroy(&a.appender)
		return nil, getError(errAppenderCreation, err)
	}

	return a.initAppenderChunk()
}

// Flush the data chunks to the underlying table and clear the internal cache.
// Does not close the appender, even if it returns an error. Unless you have a good reason to call this,
// call Close when you are done with the appender.
func (a *Appender) Flush() error {
	if err := a.appendDataChunk(); err != nil {
		return getError(errAppenderFlush, invalidatedAppenderError(err))
	}

	if err := a.flush(); err != nil {
		return getError(errAppenderFlush, invalidatedAppenderError(err))
	}

	return nil
}

// FlushWithCancel flushes the data chunks to the underlying table and clears the internal cache.
// Does not close the appender, even if it returns an error. Unless you have a good reason to call this,
// call CloseWithCancel when you are done with the appender.
// Takes a context for cancellation. Unlike query execution, an already-canceled ctx does not
// skip starting the flush, but that flush may be interrupted immediately.
func (a *Appender) FlushWithCancel(ctx context.Context) error {
	if err := a.appendDataChunk(); err != nil {
		return getError(errAppenderFlush, invalidatedAppenderError(err))
	}

	if err := a.flushWithCancel(ctx); err != nil {
		return getError(errAppenderFlush, invalidatedAppenderError(err))
	}

	return nil
}

// Clear clears the appender's internal state, discarding any appended but not yet flushed data.
// This resets the DuckDB appender's internal state.
// Clear is typically used after an error occurs during Flush or FlushWithCancel to avoid memory leaks
// before closing the appender. After calling Clear, the appender can be reused for appending new rows.
func (a *Appender) Clear() error {
	errClear := a.clearAppender()
	a.chunk.reset(true)
	a.rowCount = 0

	return errClear
}

// clearAppender clears only DuckDB's appender state; it does not touch the Go chunk buffer.
func (a *Appender) clearAppender() error {
	if mapping.AppenderClear(a.appender) == mapping.StateError {
		errClear := getDuckDBError(mapping.AppenderError(a.appender))
		return getError(invalidatedAppenderClearError(errClear), nil)
	}

	return nil
}

// Close the appender. This will flush the appender to the underlying table.
// It is vital to call this when you are done with the appender to avoid leaking memory.
func (a *Appender) Close() error {
	return a.CloseWithCancel(context.Background())
}

// CloseWithCancel closes the appender. This flushes any remaining data chunks to the underlying table.
// The flush operation can be cancelled via the provided context. If the flush fails, the appender is cleared
// before closing to prevent a memory leak. It is essential to call this function when you are done with
// the appender to avoid leaking memory. It uses the same cancellation behavior as FlushWithCancel.
func (a *Appender) CloseWithCancel(ctx context.Context) error {
	if a.closed {
		return getError(errAppenderDoubleClose, nil)
	}
	a.closed = true

	// Append all remaining chunks.
	errAppend := a.appendDataChunk()
	a.chunk.close()

	// We flush before closing to get a meaningful error message.
	errFlush := a.flushWithCancel(ctx)

	var errClear error
	if errFlush != nil {
		errClear = a.clearAppender()
	}
	// Destroy all appender data and the appender.
	destroyLogicalTypes(a.types)
	var errClose error
	if mapping.AppenderDestroy(&a.appender) == mapping.StateError {
		errClose = errAppenderClose
	}
	err := errors.Join(errAppend, errFlush, errClose, errClear)
	if err != nil {
		return getError(errAppenderClose, err)
	}

	return nil
}

// AppendRow loads a row of values into the appender. The values are provided as separate arguments.
func (a *Appender) AppendRow(args ...driver.Value) error {
	if a.closed {
		return getError(errAppenderAppendAfterClose, nil)
	}

	err := a.appendRowSlice(args)
	if err != nil {
		return getError(errAppenderAppendRow, err)
	}

	return nil
}

func (a *Appender) appenderConn(driverConn driver.Conn) error {
	var ok bool
	a.conn, ok = driverConn.(*Conn)
	if !ok {
		return getError(errInvalidCon, nil)
	}
	if a.conn.closed {
		return getError(errClosedCon, nil)
	}

	return nil
}

func (a *Appender) initAppenderChunk() (*Appender, error) {
	if err := a.chunk.initFromTypes(a.types, true); err != nil {
		a.chunk.close()
		destroyLogicalTypes(a.types)
		mapping.AppenderDestroy(&a.appender)
		return nil, getError(errAppenderCreation, err)
	}

	return a, nil
}

func (a *Appender) appendRowSlice(args []driver.Value) error {
	// Early-out, if the number of args does not match the column count.
	if len(args) != len(a.types) {
		return columnCountError(len(args), len(a.types))
	}

	// Create a new data chunk if the current chunk is full.
	if a.rowCount == GetDataChunkCapacity() {
		if err := a.appendDataChunk(); err != nil {
			return err
		}
	}

	// Set all values.
	for i, val := range args {
		err := a.chunk.SetValue(i, a.rowCount, val)
		if err != nil {
			return err
		}
	}
	a.rowCount++

	return nil
}

func (a *Appender) appendDataChunk() error {
	if a.rowCount == 0 {
		// Nothing to append.
		return nil
	}
	if err := a.chunk.SetSize(a.rowCount); err != nil {
		return err
	}
	if mapping.AppendDataChunk(a.appender, a.chunk.chunk) == mapping.StateError {
		return getDuckDBError(mapping.AppenderError(a.appender))
	}

	a.chunk.reset(true)
	a.rowCount = 0

	return nil
}

func (a *Appender) flush() error {
	if mapping.AppenderFlush(a.appender) == mapping.StateError {
		return getDuckDBError(mapping.AppenderError(a.appender))
	}
	return nil
}

func (a *Appender) flushWithCancel(ctx context.Context) error {
	mainDoneCh := make(chan struct{})
	bgDoneCh := make(chan struct{})

	// Appender cancellation always starts the flush, even if ctx is already
	// canceled. The background routine may interrupt the flush immediately.
	go interruptRoutine(&mainDoneCh, &bgDoneCh, ctx, a.conn)

	state := mapping.AppenderFlush(a.appender)

	// We finished executing the flush operation.
	// Close the main channel.
	close(mainDoneCh)

	// Wait for the background go-routine to finish, too.
	// Sometimes the go-routine is not scheduled immediately.
	// By the time it is scheduled, another query might be running on this connection.
	// If we don't wait for the go-routine to finish, it can cancel that new query.
	<-bgDoneCh

	if state == mapping.StateError {
		return errors.Join(ctx.Err(), getDuckDBError(mapping.AppenderError(a.appender)))
	}

	return nil
}
