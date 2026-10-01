import 'package:sql_parser/src/parser/parser.dart';
import 'package:sql_parser/src/parser/match.dart';
import 'package:sql_parser/src/lexer/token.dart';

import 'lexer.dart';

class ClickhouseSplitter extends Splitter {
  ClickhouseSplitter(String content) : super(ClickhouseLexer(content));

  @override
  List<SQLChunk> split({String delimiter = ";", bool skipWhitespace = false, bool skipComment = false}) {
    Token? splitWhereFunc() => l.scanWhere(
          (tok) => (tok.id == TokenType.punctuation && tok.content == delimiter),
        );
    return splitWhere(splitWhereFunc, skipWhitespace: skipWhitespace, skipComment: skipComment);
  }
}

class ClickhouseSQLDefiner extends SQLDefiner {
  final String content;
  ClickhouseSQLDefiner(this.content);

  @override
  SQLType get sqlType {
    if (Matcher(ClickhouseLexer(content)).match("{select|show|explain|exists|desc|describe} {*}")) {
      return SQLType.dql;
    }

    if (Matcher(ClickhouseLexer(content)).match("with {*}")) {
      if (Matcher(ClickhouseLexer(content)).match("with {*} select {*}")) {
        return SQLType.dql;
      }
      return SQLType.dml;
    }

    if (Matcher(ClickhouseLexer(content)).match("{insert|update|delete} {*}")) {
      return SQLType.dml;
    }

    if (Matcher(ClickhouseLexer(content)).match("{create|alter|drop|truncate|rename|attach|detach|optimize} {*}")) {
      return SQLType.ddl;
    }

    if (Matcher(ClickhouseLexer(content)).match("{grant|revoke} {*}")) {
      return SQLType.dcl;
    }

    return SQLType.other;
  }

  @override
  bool get isDangerousSQL {
    if (Matcher(ClickhouseLexer(content)).match("{truncate|drop} {*}")) {
      return true;
    }
    if (Matcher(ClickhouseLexer(content)).match("{delete|update} {*}")) {
      if (!Matcher(ClickhouseLexer(content)).match("{delete|update} {*} where {*}")) {
        return true;
      }
    }
    if (Matcher(ClickhouseLexer(content)).match("alter {*} {delete|update} {*}")) {
      if (!Matcher(ClickhouseLexer(content)).match("alter {*} {delete|update} {*} where {*}")) {
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
    if (!_isSelect) {
      return false;
    }
    return !_hasFormatOrSettings;
  }

  @override
  bool get changeSchema {
    return Matcher(ClickhouseLexer(content)).match("use {*}");
  }

  @override
  String wrapLimit(String sql, int limit) {
    if (!_isSelect || _hasFormatOrSettings) {
      return sql;
    }
    return "SELECT * FROM ($sql) AS dt_1 LIMIT $limit";
  }

  @override
  String trimDelimiter(String sql) {
    final sql = ClickhouseLexer(content).trimEndWhere((token) {
      return token.id == TokenType.whitespace ||
          token.id == TokenType.comment ||
          (token.id == TokenType.punctuation && token.content == ";");
    });
    return sql;
  }

  bool get _isSelect => Matcher(ClickhouseLexer(content)).match("select {*}");

  bool get _hasFormatOrSettings =>
      Matcher(ClickhouseLexer(content)).match("select {*} format {*}") ||
      Matcher(ClickhouseLexer(content)).match("select {*} settings {*}");
}
