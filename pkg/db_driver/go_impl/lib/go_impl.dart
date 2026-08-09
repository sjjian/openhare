library;

import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'go_impl_bindings_generated.dart';

const String _libName = 'go_impl';

final NativeImpl _lib = () {
  final DynamicLibrary dylib;
  if (Platform.isMacOS || Platform.isIOS) {
    dylib = DynamicLibrary.open('$_libName.framework/$_libName');
  } else if (Platform.isAndroid || Platform.isLinux) {
    dylib = DynamicLibrary.open('lib$_libName.so');
  } else if (Platform.isWindows) {
    dylib = DynamicLibrary.open('$_libName.dll');
  } else {
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }
  final lib = NativeImpl(dylib);
  final rc = lib.go_impl_init_dart_api(NativeApi.initializeApiDLData);
  if (rc != 0) {
    throw StateError('go_impl_init_dart_api failed: $rc');
  }
  return lib;
}();

final class ImplConnection {
  ImplConnection._(this._handle);
  final int _handle; // go impl 里的连接句柄指针

  static Future<ImplConnection> open(go_impl_db_type_t dbType, String dsn) async {
    final port = ReceivePort();
    final p = dsn.toNativeUtf8();
    try {
      _lib.go_impl_conn_open_async(dbType.value, p.cast<Char>(), port.sendPort.nativePort);
      final msg = await port.first;
      final envelope = _decodeQueryStreamMessage(msg);
      switch (envelope.type) {
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_OPEN_OK:
          return ImplConnection._(envelope.address);
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_ERROR:
          throw Exception(_decodeError(envelope.address));
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_KILL_OK:
            throw StateError('unexpected GO_IMPL_STREAM_EVENT_KILL_OK in conn open');
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CANCEL:
            throw StateError('unexpected GO_IMPL_STREAM_EVENT_CANCEL in conn open');
          default:
          throw StateError('unexpected open response: ${envelope.type}');
      }
    } finally {
      malloc.free(p);
      port.close();
    }
  }

  static Future<ImplConnection> openOracle(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_ORACLE, dsn);

  static Future<ImplConnection> openMssql(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_MSSQL, dsn);

  static Future<ImplConnection> openPg(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_PG, dsn);

  static Future<ImplConnection> openMysql(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_MYSQL, dsn);

  static Future<ImplConnection> openSqlite(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_SQLITE, dsn);

  static Future<ImplConnection> openRedis(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_REDIS, dsn);

  static Future<ImplConnection> openMongo(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_MONGODB, dsn);

  static Future<ImplConnection> openDuckdb(String dsn) => open(go_impl_db_type_t.GO_IMPL_DB_DUCKDB, dsn);

  Stream<DbQueryEvent> streamQuery(String sql) async* {
    final port = ReceivePort();
    final sqlPtr = sql.toNativeUtf8();
    try {
      _lib.go_impl_query_stream(_handle, sqlPtr.cast(), port.sendPort.nativePort);
      await for (final msg in port) {
        final envelope = _decodeQueryStreamMessage(msg);
        switch (envelope.type) {
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_HEADER:
            yield DbQueryHeader.fromAddress(envelope.address);
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_ROW:
            yield DbQueryRow.fromAddress(envelope.address);
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_ERROR:
            throw Exception(_decodeError(envelope.address));
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_DONE:
            return;
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_OPEN_OK:
            throw StateError('unexpected GO_IMPL_STREAM_EVENT_CONN_OPEN_OK in query stream');
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_CLOSE_OK:
            throw StateError('unexpected GO_IMPL_STREAM_EVENT_CONN_CLOSE_OK in query stream');
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_ERROR:
            throw StateError('unexpected GO_IMPL_STREAM_EVENT_CONN_ERROR in query stream');
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_KILL_OK:
            throw StateError('unexpected GO_IMPL_STREAM_EVENT_KILL_OK in query stream');
          case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CANCEL:
            yield const DbQueryCancel();
        }
      }
    } finally {
      malloc.free(sqlPtr);
      port.close();
    }
  }

  Future<void> killQuery() async {
    final port = ReceivePort();
    try {
      _lib.go_impl_conn_kill_async(_handle, port.sendPort.nativePort);
      final msg = await port.first;
      final envelope = _decodeQueryStreamMessage(msg);
      switch (envelope.type) {
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_KILL_OK:
          return;
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_ERROR:
          throw Exception(_decodeError(envelope.address));
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CANCEL:
          throw StateError('unexpected GO_IMPL_STREAM_EVENT_CANCEL in kill_query');
        default:
          throw StateError('unexpected kill_query response: ${envelope.type}');
      }
    } finally {
      port.close();
    }
  }

  Future<void> close() async {
    final port = ReceivePort();
    try {
      _lib.go_impl_conn_close_async(_handle, port.sendPort.nativePort);
      final msg = await port.first;
      final envelope = _decodeQueryStreamMessage(msg);
      switch (envelope.type) {
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_CLOSE_OK:
          return;
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CONN_ERROR:
          throw Exception(_decodeError(envelope.address));
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_KILL_OK:
          throw StateError('unexpected GO_IMPL_STREAM_EVENT_KILL_OK in conn close');
        case go_impl_stream_event_type_t.GO_IMPL_STREAM_EVENT_CANCEL:
          throw StateError('unexpected GO_IMPL_STREAM_EVENT_CANCEL in conn close');
        default:
          throw StateError('unexpected conn_close response: ${envelope.type}');
      }
    } finally {
      port.close();
    }
  }
}

sealed class DbQueryEvent {
  const DbQueryEvent();
}

final class DbQueryCancel extends DbQueryEvent {
  const DbQueryCancel();
}

final class DbQueryHeader extends DbQueryEvent {
  DbQueryHeader({
    required this.affectedRows,
    required this.columnCount,
    required this.columns,
  });

  factory DbQueryHeader.fromAddress(int address) {
    if (address == 0) {
      throw StateError('missing header payload');
    }
    final ptr = Pointer<db_query_header_t>.fromAddress(address);
    try {
      final header = ptr.ref;
      final cols = List<DbQueryColumn>.generate(header.column_count, (i) {
        final col = (header.columns + i).ref;
        return DbQueryColumn(
          name: _readCString(col.name),
          dataType: DbDataType.fromNative(col.data_type),
        );
      }, growable: false);
      return DbQueryHeader(
        affectedRows: BigInt.from(header.affected_rows),
        columnCount: header.column_count,
        columns: cols,
      );
    } finally {
      _lib.go_impl_free_query_header(ptr);
    }
  }

  final BigInt affectedRows;
  final int columnCount;
  final List<DbQueryColumn> columns;
}

final class DbQueryRow extends DbQueryEvent {
  DbQueryRow({required this.valueCount, required this.values});

  factory DbQueryRow.fromAddress(int address) {
    if (address == 0) {
      throw StateError('missing row payload');
    }
    final ptr = Pointer<db_query_row_t>.fromAddress(address);
    try {
      final row = ptr.ref;
      final values = List<DbQueryValue>.generate(
        row.value_count,
        (i) => DbQueryValue.fromNative((row.values + i).ref),
        growable: false,
      );
      return DbQueryRow(valueCount: row.value_count, values: values);
    } finally {
      _lib.go_impl_free_query_row(ptr);
    }
  }

  final int valueCount;
  final List<DbQueryValue> values;
}

final class DbQueryColumn {
  const DbQueryColumn({required this.name, required this.dataType});
  final String name;
  final DbDataType dataType;
}

enum DbDataType {
  number,
  char,
  time,
  blob,
  json,
  dataSet,
  ;

  static DbDataType fromNative(int value) {
    return switch (value) {
      0 => DbDataType.number,
      1 => DbDataType.char,
      2 => DbDataType.time,
      3 => DbDataType.blob,
      4 => DbDataType.json,
      5 => DbDataType.dataSet,
      _ => DbDataType.char,
    };
  }
}

final class DbQueryValue {
  const DbQueryValue(this.type, this.value);

  factory DbQueryValue.fromNative(db_query_value_t value) {
    final vt = go_impl_query_value_type_t.fromValue(value.type);
    switch (vt) {
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_NULL:
        return const DbQueryValue(go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_NULL, null);
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_BYTES:
        return DbQueryValue(vt, _readBytes(value.bytes_value, value.bytes_len));
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_INT:
        return DbQueryValue(vt, value.int_value);
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_UINT:
        return DbQueryValue(vt, value.uint_value);
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_FLOAT:
        return DbQueryValue(vt, value.float_value);
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_DOUBLE:
        return DbQueryValue(vt, value.double_value);
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_DATETIME:
        return DbQueryValue(vt, value.datetime_value);
      case go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_STRING:
        return DbQueryValue(
          vt,
          _decodeUtf8(_readBytes(value.bytes_value, value.bytes_len)),
        );
    }
  }

  final go_impl_query_value_type_t type;
  final Object? value;

  int? _intLikeValue() => switch (type) {
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_NULL => null,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_INT => value as int?,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_UINT => value as int?,
    _ => null,
  };

  num? _numberValue() => switch (type) {
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_NULL => null,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_FLOAT => value as num?,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_DOUBLE => value as num?,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_INT => value as num?,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_UINT => value as num?,
    _ => null,
  };

  Uint8List asBytes() {
    return switch (type) {
      go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_BYTES => (value as Uint8List?) ?? Uint8List(0),
      go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_STRING => Uint8List.fromList(
        utf8.encode((value as String?) ?? ''),
      ),
      _ => Uint8List(0),
    };
  }

  int? asInt() => _intLikeValue();

  int? asUInt() => _intLikeValue();

  double? asDouble() => _numberValue()?.toDouble();

  DateTime? asDateTimeUtc() => switch (type) {
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_NULL => null,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_DATETIME => DateTime.fromMillisecondsSinceEpoch(
      (value as int?) ?? 0,
      isUtc: true,
    ),
    _ => null,
  };

  String? asString() => switch (type) {
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_NULL => null,
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_BYTES => _decodeUtf8(asBytes()),
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_STRING => (value as String?) ?? '',
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_DATETIME => asDateTimeUtc()?.toIso8601String() ?? '',
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_INT => ((value as int?) ?? 0).toString(),
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_UINT => ((value as int?) ?? 0).toString(),
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_FLOAT => ((value as num?)?.toDouble() ?? 0.0).toString(),
    go_impl_query_value_type_t.GO_IMPL_QUERY_VALUE_DOUBLE => ((value as num?)?.toDouble() ?? 0.0).toString(),
  };
}

String _decodeUtf8(Uint8List bytes) => utf8.decode(bytes, allowMalformed: true);

String _readCString(Pointer<Char> ptr) {
  if (ptr == nullptr) {
    return '';
  }
  return ptr.cast<Utf8>().toDartString();
}

Uint8List _readBytes(Pointer<Uint8> ptr, int length) {
  if (ptr == nullptr || length <= 0) {
    return Uint8List(0);
  }
  return Uint8List.fromList(ptr.asTypedList(length));
}

typedef QueryStreamMessage = ({go_impl_stream_event_type_t type, int address});

QueryStreamMessage _decodeQueryStreamMessage(Object? message) {
  if (message is! List || message.length != 2) {
    throw StateError('bad stream envelope');
  }
  final rawKind = switch (message[0]) {
    final num n => n.toInt(),
    _ => throw StateError('bad stream kind'),
  };
  final address = switch (message[1]) {
    final num n => n.toInt(),
    _ => throw StateError('bad stream payload address'),
  };
  return (type: go_impl_stream_event_type_t.fromValue(rawKind), address: address);
}

String _decodeError(int address) {
  if (address == 0) {
    return 'go_impl_query_stream failed';
  }
  final ptr = Pointer<Char>.fromAddress(address);
  try {
    return _readCString(ptr);
  } finally {
    _lib.go_impl_free_cstr(ptr);
  }
}
