// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class MSSQLConnection extends GoImplConnection {
  MSSQLConnection(super._conn);

  static const bool supportsExplainCapability = false;

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  static const Set<String> _mssqlSystemDatabasesLower = {
    'tempdb',
    'model',
    'msdb',
  };

  static const Set<String> _mssqlSystemSchemasLower = {
    'db_accessadmin',
    'db_backupoperator',
    'db_datareader',
    'db_datawriter',
    'db_ddladmin',
    'db_denydatareader',
    'db_denydatawriter',
    'db_owner',
    'db_securityadmin',
    'guest',
    'information_schema',
    'sys',
  };

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.mssql, sql);

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final database = (schema != null && schema.databaseName().isNotEmpty)
        ? schema.databaseName()
        : meta.getValue("database", "master");
    final encrypt = meta.getValue("encrypt", "true");
    final trustServerCertificate =
        meta.getValue("trustServerCertificate", "true");
    // ref: https://github.com/microsoft/go-mssqldb/issues/33
    final tlsmin = meta.getValue("tlsmin", "1.2");

    final dsn = Uri(
      scheme: 'sqlserver',
      userInfo: '${meta.user}:${Uri.encodeComponent(meta.password)}',
      host: meta.getHost(),
      port: meta.getPort() ?? 1433,
      queryParameters: {
        'database': database,
        'encrypt': encrypt,
        'trustServerCertificate': trustServerCertificate,
        'tlsmin': tlsmin,
      },
    ).toString();

    final conn = await impl.ImplConnection.openMssql(dsn);
    final mc = MSSQLConnection(conn);
    return mc;
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1");
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    // HAS_DBACCESS：无权限库仍会出现在 sys.databases，但跨库读元数据会失败；
    // 只列当前主体可访问的库（issue #112）。
    final results = await query(
      'SELECT name AS SCHEMA_NAME FROM sys.databases '
      'WHERE HAS_DBACCESS(name) = 1 '
      'AND LOWER(name) NOT IN (${_mssqlSystemDatabasesNotInSql()}) ORDER BY name;',
    );
    return results.rows
        .map((r) => r.getString("SCHEMA_NAME") ?? "")
        .where((s) => s.isNotEmpty)
        .map((s) => DatabaseMode(database: s))
        .toList();
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    await query("USE ${_escapeIdent(schema.databaseName())};");
    final currentSchema = await getCurrentSchema();
    onSchemaChanged(
        currentSchema ?? DatabaseMode(database: schema.databaseName()));
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async {
    final results = await query("SELECT DB_NAME() AS CURRENT_SCHEMA;");
    return DatabaseMode(
        database: results.rows.first.getString("CURRENT_SCHEMA") ?? '');
  }

  @override
  Future<String> version() async {
    final results = await query("SELECT @@VERSION AS version;");
    return results.rows.first.getString("version") ?? "";
  }

  String _escapeIdent(String ident) {
    final escaped = ident.replaceAll(']', ']]');
    return '[$escaped]';
  }

  /// `LOWER(col) NOT IN (...)` fragment; literals come only from [_mssqlSystemSchemasLower].
  static String _mssqlSystemSchemasNotInSql() =>
      _mssqlSystemSchemasLower.map((s) => "N'$s'").join(', ');

  /// `LOWER(col) NOT IN (...)` fragment; literals come only from [_mssqlSystemDatabasesLower].
  static String _mssqlSystemDatabasesNotInSql() =>
      _mssqlSystemDatabasesLower.map((s) => "N'$s'").join(', ');

  /// Schemas in [catalog] (database).
  Future<List<String>> _schemaNamesInCatalog(String catalog) async {
    final p = _escapeIdent(catalog);
    final r = await query(
      'SELECT s.name AS SCHEMA_NAME FROM $p.sys.schemas s '
      'WHERE LOWER(s.name) NOT IN (${_mssqlSystemSchemasNotInSql()}) ORDER BY s.name;',
    );
    return r.rows
        .map((row) => row.getString('SCHEMA_NAME') ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Tables/columns in [catalog] via that database's `INFORMATION_SCHEMA`.
  Future<List<QueryResultRow>> _tableColumnRowsInCatalog(String catalog) async {
    final p = _escapeIdent(catalog);
    final r = await query('''SELECT
    t.TABLE_CATALOG AS TABLE_CATALOG,
    t.TABLE_SCHEMA AS TABLE_SCHEMA,
    t.TABLE_NAME AS TABLE_NAME,
    c.COLUMN_NAME AS COLUMN_NAME,
    c.DATA_TYPE AS DATA_TYPE
FROM $p.INFORMATION_SCHEMA.TABLES t
JOIN $p.INFORMATION_SCHEMA.COLUMNS c
    ON t.TABLE_CATALOG = c.TABLE_CATALOG
    AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
    AND t.TABLE_NAME = c.TABLE_NAME
WHERE
    t.TABLE_TYPE IN ('BASE TABLE', 'VIEW')
    AND LOWER(t.TABLE_SCHEMA) NOT IN (${_mssqlSystemSchemasNotInSql()})
ORDER BY
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    c.ORDINAL_POSITION;''');
    return r.rows;
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final databaseList = await schemas();
    if (databaseList.isEmpty) return [];

    // Single ImplConnection handle: one in-flight streamQuery at a time — no Future.wait.
    final byCatalog = <String, List<QueryResultRow>>{};
    final schemaByCatalog = <String, Set<String>>{};
    for (final catalog in databaseList) {
      byCatalog[catalog.databaseName()] =
          await _tableColumnRowsInCatalog(catalog.databaseName());
      schemaByCatalog[catalog.databaseName()] =
          (await _schemaNamesInCatalog(catalog.databaseName())).toSet();
    }

    final databaseNodes = <MetaDataNode>[];
    for (final catalog in databaseList) {
      final databaseNode =
          MetaDataNode(MetaType.database, catalog.databaseName());
      databaseNodes.add(databaseNode);

      final catalogRows = byCatalog[catalog.databaseName()]!;
      final fromTables =
          catalogRows.map((r) => r.getString('TABLE_SCHEMA')!).toSet();
      final schemaNames = {
        ...schemaByCatalog[catalog.databaseName()]!,
        ...fromTables,
      }.toList()
        ..sort();

      final schemaNodes = <MetaDataNode>[];
      for (final schema in schemaNames) {
        final schemaNode = MetaDataNode(MetaType.schema, schema);
        schemaNodes.add(schemaNode);

        final schemaTableRows = catalogRows
            .where((r) => r.getString('TABLE_SCHEMA') == schema)
            .toList();
        final tableRows =
            schemaTableRows.groupListsBy((r) => r.getString('TABLE_NAME')!);

        final tableNodes = <MetaDataNode>[];
        for (final table in tableRows.keys) {
          final tableNode = MetaDataNode(MetaType.table, table);
          tableNodes.add(tableNode);

          final columnRows = tableRows[table]!;
          final columnNodes = columnRows
              .map((result) => MetaDataNode(
                  MetaType.column, result.getString("COLUMN_NAME")!)
                ..withProp(MetaDataPropType.dataType,
                    _getDataType(result.getString("DATA_TYPE")!)))
              .toList();
          tableNode.items = columnNodes;
        }

        schemaNode.items = tableNodes;
      }

      databaseNode.items = schemaNodes;
    }

    return databaseNodes;
  }

  static DataType _getDataType(String dataType) {
    final t = dataType.toLowerCase();
    return switch (t) {
      "int" ||
      "bigint" ||
      "smallint" ||
      "tinyint" ||
      "decimal" ||
      "numeric" ||
      "money" ||
      "smallmoney" ||
      "float" ||
      "real" =>
        DataType.number,
      "char" ||
      "varchar" ||
      "nchar" ||
      "nvarchar" ||
      "text" ||
      "ntext" ||
      "uniqueidentifier" =>
        DataType.char,
      "date" ||
      "time" ||
      "datetime" ||
      "smalldatetime" ||
      "datetime2" ||
      "datetimeoffset" =>
        DataType.time,
      "binary" || "varbinary" || "image" => DataType.blob,
      "xml" => DataType.json,
      "bit" => DataType.dataSet,
      _ => DataType.char,
    };
  }

  /// Maps [go-mssqldb](https://github.com/microsoft/go-mssqldb) `ColumnType.DatabaseTypeName()` to UI data types.
  static DataType columnDataTypeFromDriverName(String typeName) {
    final t = typeName.toUpperCase().trim();
    if (t.isEmpty) return DataType.char;
    // Before matching INT (e.g. `DATETIME2` contains "INT").
    if (t.contains('DATE') || t.contains('TIME')) return DataType.time;
    if (t.contains('INT') && !t.contains('POINT')) return DataType.number;
    if (t.contains('DECIMAL') || t.contains('NUMERIC') || t.contains('MONEY')) {
      return DataType.number;
    }
    if (t.contains('FLOAT') || t.contains('REAL')) return DataType.number;
    if (t.contains('BINARY') ||
        t.contains('IMAGE') ||
        t.contains('VARBINARY')) {
      return DataType.blob;
    }
    if (t == 'BIT') return DataType.dataSet;
    if (t.contains('XML')) return DataType.json;
    if (t.contains('CHAR') ||
        t.contains('TEXT') ||
        t.contains('UNIQUEIDENTIFIER')) {
      return DataType.char;
    }
    return DataType.char;
  }
}
