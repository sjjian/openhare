import 'package:pg/pg.dart';
import 'db_driver_interface.dart';
import 'db_driver_conn_meta.dart';
import 'db_driver_metadata.dart';

class PGQueryValue extends BaseQueryValue {
  final Object? _value;

  PGQueryValue(this._value);

  @override
  String? getString() {
    if (_value == null) {
      return null;
    }
    return _value.toString();
  }

  @override
  List<int> getBytes() {
    // todo
    return List.empty();
  }
}

class PGQueryColumn extends BaseQueryColumn {
  final ResultSchemaColumn _column;

  PGQueryColumn(this._column);

  @override
  String get name => _column.columnName ?? "";

  @override
  DataType dataType() {
    return switch (_column.type) {
      Type.json || Type.jsonb || Type.jsonbArray => DataType.json, // JSON

      Type.text ||
      Type.textArray ||
      Type.byteArray =>
        DataType.blob, // BLOB, TINY_BLOB, MEDIUM_BLOB, LONG_BLOB

      Type.character ||
      Type.varChar ||
      Type.varCharArray =>
        DataType.char, // STRING, VARCHAR, VAR_STRING

      Type.time ||
      Type.timeArray ||
      Type.timestamp ||
      Type.timestampArray ||
      Type.timestampRange ||
      Type.timestampTz ||
      Type.timestampTzArray ||
      Type.timestampRange ||
      Type.timestampWithTimezone ||
      Type.timestampWithoutTimezone ||
      Type.date ||
      Type.dateArray ||
      Type.dateRange =>
        DataType.time, // DATE, DATETIME, TIMESTAMP

      Type.bigInteger ||
      Type.bigIntegerArray ||
      Type.bigIntegerRange ||
      Type.bigSerial ||
      Type.integer ||
      Type.integerArray ||
      Type.integerRange ||
      Type.smallInteger ||
      Type.smallIntegerArray =>
        DataType.number, // number

      _ => DataType.char,
    };
  }
}

class PGConnection extends BaseConnection {
  final PGConn _conn;

  PGConnection(this._conn);

  static Future<BaseConnection> open(
      {required ConnectValue meta, String? schema}) async {
    final conn = await PGConn.open(
        endpoint: Endpoint(
      host: meta.host,
      port: meta.port?? 5432,
      password: meta.password,
      username: meta.user,
      database: meta.getValue("database", "postgres"),
    ));

    final pgConn = PGConnection(conn);
    if (schema != null) {
      pgConn.setCurrentSchema(schema);
    }
    return pgConn;
  }

  @override
  Future<BaseQueryResult> query(String sql) async {
    final qs = await _conn.query(query: sql);
    final columns = qs.schema.columns
        .map<PGQueryColumn>((qs) => PGQueryColumn(qs))
        .toList();
    List<QueryResultRow> rows = List.empty(growable: true);
    for (final r in qs) {
      rows.add(QueryResultRow(columns, r.map((v) => PGQueryValue(v)).toList()));
    }
    return BaseQueryResult(columns, rows, BigInt.from(qs.affectedRows));
  }

  @override
  Future<void> close() async {
    await _conn.close();
  }

  @override
  Future<MetaDataNode> metadata() async {
    return MetaDataNode(MetaType.instance, "");
  }

  @override
  Future<void> setCurrentSchema(String schema) async {
    await query("SET search_path TO $schema");
    final currentSchema = await getCurrentSchema();
    onSchemaChanged(currentSchema!);
    return;
  }

  @override
  Future<String?> getCurrentSchema() async {
    final results = await query("SELECT current_schema();");
    final rows = results.rows;
    final currentSchema = rows.first.getString("current_schema");
    return currentSchema;
  }

  @override
  Future<List<String>> schemas() async {
    List<String> schemas = List.empty(growable: true);
    final results = await query("SELECT nspname FROM pg_namespace;");
    for (final result in results.rows) {
      schemas.add(result.getString("nspname") ?? "");
    }
    return schemas;
  }
}
