library;

export 'src/lexer/token.dart';
export 'src/lexer/scanner.dart';
export 'src/lexer/lexer.dart';
export 'src/parser/parser.dart';
export 'src/parser/match.dart';

import 'package:sql_parser/src/parser/match.dart';

import 'src/dialect/mysql/lexer.dart';
import 'src/dialect/mysql/parser.dart';
import 'src/dialect/mssql/lexer.dart';
import 'src/dialect/mssql/parser.dart';
import 'src/dialect/oracle/lexer.dart';
import 'src/dialect/oracle/parser.dart';
import 'src/dialect/pg/lexer.dart';
import 'src/dialect/pg/parser.dart';
import 'src/dialect/sqlite/lexer.dart';
import 'src/dialect/sqlite/parser.dart';
import 'src/dialect/redis/lexer.dart';
import 'src/dialect/redis/parser.dart';
import 'src/dialect/mongodb/lexer.dart';
import 'src/dialect/mongodb/parser.dart';
import 'src/dialect/duckdb/lexer.dart';
import 'src/dialect/duckdb/parser.dart';
import 'src/lexer/lexer.dart';
import 'src/parser/parser.dart';
import 'src/dialect/mysql/keyword.dart' as mysql_keywords;
import 'src/dialect/mssql/keyword.dart' as mssql_keywords;
import 'src/dialect/oracle/keyword.dart' as oracle_keywords;
import 'src/dialect/pg/keyword.dart' as pg_keywords;
import 'src/dialect/sqlite/keyword.dart' as sqlite_keywords;
import 'src/dialect/redis/keyword.dart' as redis_keywords;
import 'src/dialect/mongodb/keyword.dart' as mongodb_keywords;
import 'src/dialect/duckdb/keyword.dart' as duckdb_keywords;

// 定义方言类型枚举
enum DialectType { mysql, oracle, pg, mssql, sqlite, redis, mongodb, duckdb }

Lexer createLexer(DialectType dialect, String content) {
  switch (dialect) {
    case DialectType.mysql:
      return MySQLLexer(content);
    case DialectType.oracle:
      return OracleLexer(content);
    case DialectType.pg:
      return PgLexer(content);
    case DialectType.mssql:
      return MssqlLexer(content);
    case DialectType.sqlite:
      return SqliteLexer(content);
    case DialectType.redis:
      return RedisLexer(content);
    case DialectType.mongodb:
      return MongoLexer(content);
    case DialectType.duckdb:
      return DuckdbLexer(content);
  }
}

List<SQLChunk> splitSQL(DialectType dialect, String content,
    {String delimiter = ";", bool skipWhitespace = false, bool skipComment = false}) {
  switch (dialect) {
    case DialectType.mysql:
      return MysqlSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.oracle:
      return OracleSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.pg:
      return PgSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.mssql:
      return MssqlSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.sqlite:
      return SqliteSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.redis:
      return RedisSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.mongodb:
      return MongoSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
    case DialectType.duckdb:
      return DuckdbSplitter(content).split(skipWhitespace: skipWhitespace, skipComment: skipComment);
  }
}

bool match(DialectType dialect, String content, String pattern) {
  switch (dialect) {
    case DialectType.mysql:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.oracle:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.pg:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.mssql:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.sqlite:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.redis:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.mongodb:
      return Matcher(createLexer(dialect, content)).match(pattern);
    case DialectType.duckdb:
      return Matcher(createLexer(dialect, content)).match(pattern);
  }
}

SQLDefiner parser(DialectType dialect, String content) {
  switch (dialect) {
    case DialectType.mysql:
      return MysqlSQLDefiner(content);
    case DialectType.oracle:
      return OracleSQLDefiner(content);
    case DialectType.pg:
      return PgSQLDefiner(content);
    case DialectType.mssql:
      return MssqlSQLDefiner(content);
    case DialectType.sqlite:
      return SqliteSQLDefiner(content);
    case DialectType.redis:
      return RedisSQLDefiner(content);
    case DialectType.mongodb:
      return MongoSQLDefiner(content);
    case DialectType.duckdb:
      return DuckdbSQLDefiner(content);
  }
}

Set<String> keywords(DialectType dialect) {
  switch (dialect) {
    case DialectType.mysql:
      return mysql_keywords.keywords;
    case DialectType.oracle:
      return oracle_keywords.keywords;
    case DialectType.pg:
      return pg_keywords.keywords;
    case DialectType.mssql:
      return mssql_keywords.keywords;
    case DialectType.sqlite:
      return sqlite_keywords.keywords;
    case DialectType.redis:
      return redis_keywords.keywords;
    case DialectType.mongodb:
      return mongodb_keywords.keywords;
    case DialectType.duckdb:
      return duckdb_keywords.keywords;
  }
}
