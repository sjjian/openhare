package main

//go:generate sh -c "CGO_ENABLED=1 go tool cgo -exportheader go_impl.h impl.go && cd .. && dart run ffigen --config ffigen.yaml"

/*
#cgo CFLAGS: -I${SRCDIR} -I${SRCDIR}/dart-sdk-include
#include <stdint.h>
#include <stdlib.h>

typedef enum {
  GO_IMPL_QUERY_VALUE_NULL = 0,
  GO_IMPL_QUERY_VALUE_BYTES = 1,
  GO_IMPL_QUERY_VALUE_INT = 2,
  GO_IMPL_QUERY_VALUE_UINT = 3,
  GO_IMPL_QUERY_VALUE_FLOAT = 4,
  GO_IMPL_QUERY_VALUE_DOUBLE = 5,
  GO_IMPL_QUERY_VALUE_DATETIME = 6,
  GO_IMPL_QUERY_VALUE_STRING = 7,
} go_impl_query_value_type_t;

typedef enum {
  GO_IMPL_DB_ORACLE = 0,
  GO_IMPL_DB_MSSQL = 1,
  GO_IMPL_DB_PG = 2,
  GO_IMPL_DB_MYSQL = 3,
  GO_IMPL_DB_SQLITE = 4,
  GO_IMPL_DB_REDIS = 5,
  GO_IMPL_DB_MONGODB = 6,
} go_impl_db_type_t;

typedef enum {
  GO_IMPL_STREAM_EVENT_HEADER = 0,
  GO_IMPL_STREAM_EVENT_ROW = 1,
  GO_IMPL_STREAM_EVENT_ERROR = 2,
  GO_IMPL_STREAM_EVENT_DONE = 3,
  GO_IMPL_STREAM_EVENT_CONN_OPEN_OK = 4,
  GO_IMPL_STREAM_EVENT_CONN_CLOSE_OK = 5,
  GO_IMPL_STREAM_EVENT_CONN_ERROR = 6,
  GO_IMPL_STREAM_EVENT_KILL_OK = 7,
  GO_IMPL_STREAM_EVENT_CANCEL = 8,
} go_impl_stream_event_type_t;

typedef enum {
  GO_IMPL_DATA_TYPE_NUMBER = 0,
  GO_IMPL_DATA_TYPE_CHAR = 1,
  GO_IMPL_DATA_TYPE_TIME = 2,
  GO_IMPL_DATA_TYPE_BLOB = 3,
  GO_IMPL_DATA_TYPE_JSON = 4,
  GO_IMPL_DATA_TYPE_DATA_SET = 5,
} go_impl_data_type_t;

typedef struct db_query_column_t {
  char* name;
  int32_t data_type;
} db_query_column_t;

typedef struct db_query_value_t {
  int32_t type;
  int64_t int_value;
  uint64_t uint_value;
  float float_value;
  double double_value;
  int64_t datetime_value;
  uint8_t* bytes_value;
  int32_t bytes_len;
} db_query_value_t;

typedef struct db_query_row_t {
  db_query_value_t* values;
  int32_t value_count;
} db_query_row_t;

typedef struct db_query_header_t {
  db_query_column_t* columns;
  int32_t column_count;
  int64_t affected_rows;
} db_query_header_t;

#include "stream_bridge.h"
*/
import "C"

import (
	"errors"
	"fmt"
	"runtime/cgo"
	"time"
	"unsafe"
)

var (
	errNativeAllocFailed = errors.New("native allocation failed")
)

const (
	dataTypeNumber  = int32(C.GO_IMPL_DATA_TYPE_NUMBER)
	dataTypeChar    = int32(C.GO_IMPL_DATA_TYPE_CHAR)
	dataTypeTime    = int32(C.GO_IMPL_DATA_TYPE_TIME)
	dataTypeBlob    = int32(C.GO_IMPL_DATA_TYPE_BLOB)
	dataTypeJson    = int32(C.GO_IMPL_DATA_TYPE_JSON)
	dataTypeDataSet = int32(C.GO_IMPL_DATA_TYPE_DATA_SET)
)

type dbQueryColumn struct {
	name     string
	dataType int32
}

type dbQueryHeader struct {
	columns      []dbQueryColumn
	affectedRows int64
}

func (h *dbQueryHeader) allocC() (*C.db_query_header_t, error) {
	ptr := C.calloc(1, C.sizeof_db_query_header_t)
	if ptr == nil {
		return nil, errNativeAllocFailed
	}
	header := (*C.db_query_header_t)(ptr)
	header.affected_rows = C.int64_t(h.affectedRows)
	header.column_count = C.int32_t(len(h.columns))
	if len(h.columns) == 0 {
		return header, nil
	}

	colsPtr := C.calloc(C.size_t(len(h.columns)), C.sizeof_db_query_column_t)
	if colsPtr == nil {
		freeQueryHeader(header)
		return nil, errNativeAllocFailed
	}
	header.columns = (*C.db_query_column_t)(colsPtr)

	cols := unsafe.Slice(header.columns, len(h.columns))
	for i, col := range h.columns {
		cols[i].name = C.CString(col.name)
		if cols[i].name == nil {
			freeQueryHeader(header)
			return nil, errNativeAllocFailed
		}
		cols[i].data_type = C.int32_t(col.dataType)
	}
	return header, nil
}

func freeQueryHeader(header *C.db_query_header_t) {
	if header == nil {
		return
	}
	cols := unsafe.Slice(header.columns, int(header.column_count))
	for i := range cols {
		if cols[i].name != nil {
			C.free(unsafe.Pointer(cols[i].name))
		}
	}
	if header.columns != nil {
		C.free(unsafe.Pointer(header.columns))
	}
	C.free(unsafe.Pointer(header))
}

type dbQueryRow struct {
	values []dbQueryValue
}

func (r *dbQueryRow) allocC() (*C.db_query_row_t, error) {
	ptr := C.calloc(1, C.sizeof_db_query_row_t)
	if ptr == nil {
		return nil, errNativeAllocFailed
	}
	row := (*C.db_query_row_t)(ptr)
	row.value_count = C.int32_t(len(r.values))
	if len(r.values) == 0 {
		return row, nil
	}

	valuesPtr := C.calloc(C.size_t(len(r.values)), C.sizeof_db_query_value_t)
	if valuesPtr == nil {
		freeQueryRow(row)
		return nil, errNativeAllocFailed
	}
	row.values = (*C.db_query_value_t)(valuesPtr)

	cValues := unsafe.Slice(row.values, len(r.values))
	for i, cell := range r.values {
		cValues[i]._type = C.int32_t(cell.valueType)
		cValues[i].int_value = C.int64_t(cell.intValue)
		cValues[i].uint_value = C.uint64_t(cell.uintValue)
		cValues[i].float_value = C.float(cell.floatValue)
		cValues[i].double_value = C.double(cell.doubleValue)
		cValues[i].datetime_value = C.int64_t(cell.datetimeValue)

		if len(cell.bytesValue) == 0 {
			continue
		}
		cValues[i].bytes_value = (*C.uint8_t)(C.CBytes(cell.bytesValue))
		if cValues[i].bytes_value == nil {
			freeQueryRow(row)
			return nil, errNativeAllocFailed
		}
		cValues[i].bytes_len = C.int32_t(len(cell.bytesValue))
	}
	return row, nil
}

func freeQueryRow(row *C.db_query_row_t) {
	if row == nil {
		return
	}
	values := unsafe.Slice(row.values, int(row.value_count))
	for i := range values {
		if values[i].bytes_value != nil {
			C.free(unsafe.Pointer(values[i].bytes_value))
		}
	}
	if row.values != nil {
		C.free(unsafe.Pointer(row.values))
	}
	C.free(unsafe.Pointer(row))
}

type dbQueryValue struct {
	valueType     int32
	intValue      int64
	uintValue     uint64
	floatValue    float32
	doubleValue   float64
	datetimeValue int64
	bytesValue    []byte
}

func buildQueryValue(v any) dbQueryValue {
	if v == nil {
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_NULL)}
	}
	switch vv := v.(type) {
	case []byte:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_BYTES), bytesValue: append([]byte(nil), vv...)}
	case string:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_STRING), bytesValue: []byte(vv)}
	case time.Time:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_DATETIME), datetimeValue: vv.UnixMilli()}
	case int64:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_INT), intValue: vv}
	case int32:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_INT), intValue: int64(vv)}
	case int:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_INT), intValue: int64(vv)}
	case uint64:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_UINT), uintValue: vv}
	case uint32:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_UINT), uintValue: uint64(vv)}
	case float64:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_DOUBLE), doubleValue: vv}
	case float32:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_FLOAT), floatValue: vv}
	case bool:
		if vv {
			return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_INT), intValue: 1}
		}
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_INT), intValue: 0}
	default:
		return dbQueryValue{valueType: int32(C.GO_IMPL_QUERY_VALUE_STRING), bytesValue: []byte(fmt.Sprint(v))}
	}
}

type driverConn interface {
	Close() error
	OpenQuery(sql string) (rowCursor, error)
	KillQuery() error
}

type streamQueryCancelledError struct {
	cause error
}

func (e *streamQueryCancelledError) Error() string {
	return "go_impl: stream query cancelled"
}

func (e *streamQueryCancelledError) Unwrap() error {
	return e.cause
}

func newStreamQueryCancelled(cause error) error {
	return &streamQueryCancelledError{cause: cause}
}

func streamErrIsCancel(err error) bool {
	var ce *streamQueryCancelledError
	return errors.As(err, &ce)
}

type rowCursor interface {
	Close() error
	Header() *dbQueryHeader
	NextRow() (*dbQueryRow, bool, error)
}

func initConnFromHandle(handle C.int64_t) (driverConn, bool) {
	c, ok := cgo.Handle(handle).Value().(driverConn)
	return c, ok
}

//export go_impl_conn_open_async
func go_impl_conn_open_async(dbType C.int32_t, dsn *C.char, dartPort C.int64_t) {
	go go_impl_conn_open(dbType, dsn, dartPort)
}

func go_impl_conn_open(dbType C.int32_t, dsn *C.char, dartPort C.int64_t) {
	sender := streamSender{port: dartPort}
	var conn driverConn
	var err error
	switch dbType {
	case C.GO_IMPL_DB_ORACLE:
		conn, err = openOracleConn(C.GoString(dsn))
	case C.GO_IMPL_DB_MSSQL:
		conn, err = openMssqlConn(C.GoString(dsn))
	case C.GO_IMPL_DB_PG:
		conn, err = openPgConn(C.GoString(dsn))
	case C.GO_IMPL_DB_MYSQL:
		conn, err = openMysqlConn(C.GoString(dsn))
	case C.GO_IMPL_DB_SQLITE:
		conn, err = openSqliteConn(C.GoString(dsn))
	case C.GO_IMPL_DB_REDIS:
		conn, err = openRedisConn(C.GoString(dsn))
	case C.GO_IMPL_DB_MONGODB:
		conn, err = openMongoConn(C.GoString(dsn))
	default:
		err = fmt.Errorf("unsupported db type: %d", dbType)
	}
	if err != nil {
		_ = sender.sendConnError(err)
		return
	}
	h := cgo.NewHandle(conn)
	if !sender.sendConnOpenOk(h) {
		if c, ok := cgo.Handle(h).Value().(driverConn); ok {
			_ = c.Close()
		}
		cgo.Handle(h).Delete()
	}
}

//export go_impl_conn_kill_async
func go_impl_conn_kill_async(handle C.int64_t, dartPort C.int64_t) {
	go go_impl_conn_kill(handle, dartPort)
}

func go_impl_conn_kill(handle C.int64_t, dartPort C.int64_t) {
	sender := streamSender{port: dartPort}
	c, ok := initConnFromHandle(handle)
	if !ok {
		_ = sender.sendConnError(fmt.Errorf("invalid handle: %d", handle))
		return
	}
	if err := c.KillQuery(); err != nil {
		_ = sender.sendConnError(err)
		return
	}
	_ = sender.sendKillOk()
}

//export go_impl_conn_close_async
func go_impl_conn_close_async(handle C.int64_t, dartPort C.int64_t) {
	go go_impl_conn_close(handle, dartPort)
}

func go_impl_conn_close(handle C.int64_t, dartPort C.int64_t) {
	sender := streamSender{port: dartPort}
	h := cgo.Handle(handle)
	var closeErr error
	if c, ok := h.Value().(driverConn); ok {
		closeErr = c.Close()
	}
	h.Delete()
	if closeErr != nil {
		_ = sender.sendConnError(closeErr)
		return
	}
	_ = sender.sendConnCloseOk()
}

//export go_impl_free_cstr
func go_impl_free_cstr(s *C.char) {
	if s == nil {
		return
	}
	C.free(unsafe.Pointer(s))
}

//export go_impl_free_query_header
func go_impl_free_query_header(header *C.db_query_header_t) {
	freeQueryHeader(header)
}

//export go_impl_free_query_row
func go_impl_free_query_row(row *C.db_query_row_t) {
	freeQueryRow(row)
}

//export go_impl_query_stream
func go_impl_query_stream(handle C.int64_t, sql *C.char, dartPort C.int64_t) {
	go runStream(handle, sql, dartPort)
}

func runStream(handle C.int64_t, sql *C.char, dartPort C.int64_t) {
	sender := streamSender{port: dartPort}
	defer sender.sendDone()

	c, ok := initConnFromHandle(handle)
	if !ok {
		_ = sender.sendError(fmt.Errorf("invalid handle: %d", handle))
		return
	}

	q, err := c.OpenQuery(C.GoString(sql))
	if err != nil {
		if streamErrIsCancel(err) {
			_ = sender.sendCancel()
			return
		}
		_ = sender.sendError(err)
		return
	}
	defer func() { _ = q.Close() }()

	if !sender.sendHeader(q.Header()) {
		return
	}
	for {
		row, ok, err := q.NextRow()
		if err != nil {
			if streamErrIsCancel(err) {
				_ = sender.sendCancel()
				return
			}
			_ = sender.sendError(err)
			return
		}
		if !ok {
			break
		}
		if !sender.sendRow(row) {
			return
		}
	}
}

type streamSender struct {
	port C.int64_t
}

func (s *streamSender) sendConnOpenOk(h cgo.Handle) bool {
	return s.send(C.GO_IMPL_STREAM_EVENT_CONN_OPEN_OK, uintptr(h))
}

func (s *streamSender) sendConnCloseOk() bool {
	return s.send(C.GO_IMPL_STREAM_EVENT_CONN_CLOSE_OK, 0)
}

func (s *streamSender) sendKillOk() bool {
	return s.send(C.GO_IMPL_STREAM_EVENT_KILL_OK, 0)
}

func (s *streamSender) sendCancel() bool {
	return s.send(C.GO_IMPL_STREAM_EVENT_CANCEL, 0)
}

func (s *streamSender) sendConnError(err error) bool {
	return s.sendErrorCommon(C.GO_IMPL_STREAM_EVENT_CONN_ERROR, err)
}

func (s *streamSender) sendHeader(h *dbQueryHeader) bool {
	header, err := h.allocC()
	if err != nil {
		return s.sendError(err)
	}
	if !s.send(C.GO_IMPL_STREAM_EVENT_HEADER, uintptr(unsafe.Pointer(header))) {
		freeQueryHeader(header)
		return false
	}
	return true
}

func (s *streamSender) sendRow(r *dbQueryRow) bool {
	row, err := r.allocC()
	if err != nil {
		return s.sendError(err)
	}
	if !s.send(C.GO_IMPL_STREAM_EVENT_ROW, uintptr(unsafe.Pointer(row))) {
		freeQueryRow(row)
		return false
	}
	return true
}

func (s *streamSender) sendError(err error) bool {
	return s.sendErrorCommon(C.GO_IMPL_STREAM_EVENT_ERROR, err)
}

func (s *streamSender) sendDone() bool {
	return s.send(C.GO_IMPL_STREAM_EVENT_DONE, 0)
}

func (s *streamSender) sendErrorCommon(kind int, err error) bool {
	if err == nil {
		return true
	}
	msg := C.CString(err.Error())
	if msg == nil {
		return false
	}
	if s.send(kind, uintptr(unsafe.Pointer(msg))) {
		return true
	}
	C.free(unsafe.Pointer(msg))
	return false
}

func (s *streamSender) send(kind int, payload uintptr) bool {
	return C.go_impl_post_stream_message(
		s.port,
		C.int32_t(kind),
		C.uintptr_t(payload),
	) != 0
}

func main() {}
