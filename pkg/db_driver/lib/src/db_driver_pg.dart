// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class PGConnection extends GoImplConnection {
  PGConnection(super._conn);

  static const bool supportsExplainCapability = true;

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.schemaMode;

  static const Set<String> _pgSystemSchemasLower = {
    'information_schema',
    'pg_catalog',
    'pg_logical',
    'pg_toast',
  };

  static String _pgSystemSchemasNotInSql() =>
      _pgSystemSchemasLower.map((s) => "'$s'").join(', ');

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.pg, sql);

  @override
  Future<BaseQueryResult> explain(String sql) {
    sql = parser(sql).trimDelimiter(sql);
    return query('EXPLAIN $sql');
  }

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final defaultDb = meta.getValue("database", "postgres");

    final schemaToApply = switch (schema) {
      null => null,
      // 兼容旧数据：PG 上曾用 currentSchema 存 schema, 在其他数据库都代表的database, 连接库用配置里的 database。
      DatabaseMode(database: final schemaName) => SchemaMode(
          database: defaultDb,
          schema: schemaName,
        ),
      SchemaMode(database: final databaseName, schema: final schemaName) =>
        SchemaMode(
          database: databaseName.isNotEmpty ? databaseName : defaultDb,
          schema: schemaName,
        ),
    };

    final dsnDatabase = schemaToApply?.databaseName() ?? defaultDb;

    final sslmode = meta.getValue("sslmode", "disable");
    final connectTimeout = meta.getIntValue("connectTimeout", 10);
    final queryTimeout = meta.getIntValue("queryTimeout", 600);

    final dsn = Uri(
      scheme: 'postgres',
      userInfo: '${meta.user}:${Uri.encodeComponent(meta.password)}',
      host: meta.getHost(),
      port: meta.getPort() ?? 5432,
      path: '/$dsnDatabase',
      queryParameters: {
        'sslmode': sslmode,
        'connect_timeout': connectTimeout.toString(),
      },
    ).toString();

    final conn = await impl.ImplConnection.openPg(dsn);
    final pg = PGConnection(conn);

    await pg.query("SET statement_timeout = '${queryTimeout}s'");

    if (schemaToApply != null) {
      await pg.setCurrentSchema(schemaToApply);
    }

    return pg;
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1");
  }

  @override
  Future<String> version() async {
    final results = await query("SELECT version() AS version");
    return results.rows.first.getString("version") ?? "";
  }

  Future<String> _currentDatabase() async {
    final results = await query("SELECT current_database() AS db");
    return results.rows.first.getString("db") ?? "";
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    if (schema is! SchemaMode) {
      return;
    }
    final dbName = await _currentDatabase();
    if (schema.database.isNotEmpty && schema.database != dbName) {
      throw StateError(
        "PostgreSQL cannot switch database on an existing connection "
        "(current: $dbName, requested: ${schema.database}).",
      );
    }
    final nsp = schema.schemaName();
    final escaped = nsp.replaceAll("'", "''");
    await query("SET search_path TO '$escaped'");
    onSchemaChanged(SchemaMode(database: dbName, schema: nsp));
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async {
    final results = await query(
      "SELECT current_database() AS db, current_schema() AS sch",
    );
    final db = results.rows.first.getString("db") ?? "";
    final sch = results.rows.first.getString("sch") ?? "";
    if (sch.isEmpty) {
      return null;
    }
    return SchemaMode(database: db, schema: sch);
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    final db = await _currentDatabase();
    final results = await query(
      'SELECT nspname FROM pg_namespace '
      'WHERE LOWER(nspname) NOT IN (${_pgSystemSchemasNotInSql()}) '
      'ORDER BY nspname;',
    );
    return results.rows
        .map((r) => r.getString("nspname") ?? "")
        .where((s) => s.isNotEmpty)
        .map((s) => SchemaMode(database: db, schema: s))
        .toList();
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final dbName = await _currentDatabase();
    if (dbName.isEmpty) {
      return [];
    }

    final schemaList =
        (await schemas()).whereType<SchemaMode>().toList(growable: false);

    final results = await query("""SELECT 
    t.table_schema,
    t.table_name,
    c.column_name,
    c.data_type
FROM 
    information_schema.tables t
JOIN 
    information_schema.columns c 
    ON t.table_name = c.table_name 
    AND t.table_schema = c.table_schema
WHERE 
    t.table_type IN ('BASE TABLE', 'VIEW')
ORDER BY
    t.table_schema,
    t.table_name, 
    c.ordinal_position;""");

    final rows = results.rows;
    final schemaRows =
        rows.groupListsBy((result) => result.getString("table_schema")!);

    final schemaNodes = <MetaDataNode>[];
    for (final schemaRef in schemaList) {
      final schemaNode = MetaDataNode(MetaType.schema, schemaRef.schemaName());
      schemaNodes.add(schemaNode);

      final tableNodes = <MetaDataNode>[];
      final tableRowsForSchema = schemaRows[schemaRef.schemaName()];
      if (tableRowsForSchema != null) {
        final byTable = tableRowsForSchema
            .groupListsBy((result) => result.getString("table_name")!);
        for (final table in byTable.keys) {
          final tableNode = MetaDataNode(MetaType.table, table);
          tableNodes.add(tableNode);

          final columnRows = byTable[table]!;
          final columnNodes = columnRows
              .map((result) => MetaDataNode(
                  MetaType.column, result.getString("column_name")!)
                ..withProp(MetaDataPropType.dataType,
                    _getDataType(result.getString("data_type")!)))
              .toList();
          tableNode.items = columnNodes;
        }
      }
      schemaNode.items = tableNodes;
    }

    final databaseNode = MetaDataNode(MetaType.database, dbName);
    databaseNode.items = schemaNodes;
    return [databaseNode];
  }

  static DataType _getDataType(String dataType) {
    final t = dataType.toLowerCase().trim();
    return switch (t) {
      "integer" ||
      "bigint" ||
      "smallint" ||
      "serial" ||
      "bigserial" ||
      "smallserial" ||
      "numeric" ||
      "decimal" ||
      "real" ||
      "double precision" =>
        DataType.number,
      "character varying" ||
      "varchar" ||
      "character" ||
      "char" ||
      "text" =>
        DataType.char,
      "timestamp without time zone" ||
      "timestamp with time zone" ||
      "timestamptz" ||
      "timestamp" ||
      "date" ||
      "time without time zone" ||
      "time with time zone" ||
      "time" ||
      "interval" =>
        DataType.time,
      "bytea" => DataType.blob,
      "json" || "jsonb" => DataType.json,
      "boolean" => DataType.dataSet,
      "uuid" => DataType.char,
      "array" || "user-defined" => DataType.blob,
      _ => DataType.char,
    };
  }
}
