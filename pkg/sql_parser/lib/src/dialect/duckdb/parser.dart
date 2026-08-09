import 'package:sql_parser/src/parser/parser.dart';
import 'package:sql_parser/src/parser/match.dart';
import 'package:sql_parser/src/lexer/token.dart';

import 'lexer.dart';

class DuckdbSplitter extends Splitter {
  DuckdbSplitter(String content) : super(DuckdbLexer(content));

  @override
  List<SQLChunk> split({String delimiter = ";", bool skipWhitespace = false, bool skipComment = false}) {
    Token? splitWhereFunc() => l.scanWhere(
          (tok) => (tok.id == TokenType.punctuation && tok.content == delimiter),
        );
    return splitWhere(splitWhereFunc, skipWhitespace: skipWhitespace, skipComment: skipComment);
  }
}

class DuckdbSQLDefiner extends SQLDefiner {
  final String content;
  DuckdbSQLDefiner(this.content);

  @override
  SQLType get sqlType {
    if (Matcher(DuckdbLexer(content)).match("{select|show|explain|values|describe|summarize|pragma} {*}")) {
      return SQLType.dql;
    }

    if (Matcher(DuckdbLexer(content)).match("with {*}")) {
      if (Matcher(DuckdbLexer(content)).match("with {*} select {*}")) {
        return SQLType.dql;
      }
      return SQLType.dml;
    }

    if (Matcher(DuckdbLexer(content)).match("{insert|update|delete|merge|copy|call|export|import} {*}")) {
      return SQLType.dml;
    }

    if (Matcher(DuckdbLexer(content)).match("{create|alter|drop|truncate|rename|comment|install|load|attach|detach|pivot|unpivot} {*}")) {
      return SQLType.ddl;
    }

    if (Matcher(DuckdbLexer(content)).match("{grant|revoke} {*}")) {
      return SQLType.dcl;
    }

    return SQLType.other;
  }

  @override
  bool get isDangerousSQL {
    if (Matcher(DuckdbLexer(content)).match("{truncate|drop} {*}")) {
      return true;
    }
    if (Matcher(DuckdbLexer(content)).match("{delete|update} {*}")) {
      if (!Matcher(DuckdbLexer(content)).match("{delete|update} {*} where {*}")) {
        return true;
      }
    }
    return false;
  }

  @override
  bool get canLimit {
    if (sqlType != SQLType.dql) {
      return false;
    }
    return Matcher(DuckdbLexer(content)).match("select {*}");
  }

  @override
  bool get changeSchema {
    return Matcher(DuckdbLexer(content)).match("set schema {*}") ||
        Matcher(DuckdbLexer(content)).match("use {*}") ||
        Matcher(DuckdbLexer(content)).match("set search_path {*}") ||
        Matcher(DuckdbLexer(content)).match("set search_path to {*}");
  }

  @override
  String wrapLimit(String sql, int limit) {
    if (!Matcher(DuckdbLexer(content)).match("select {*}")) {
      return sql;
    }
    return "SELECT * FROM ($sql) AS dt_1 LIMIT $limit";
  }

  @override
  String trimDelimiter(String sql) {
    final sql = DuckdbLexer(content).trimEndWhere((token) {
      return token.id == TokenType.whitespace ||
          token.id == TokenType.comment ||
          (token.id == TokenType.punctuation && token.content == ";");
    });
    return sql;
  }
}
