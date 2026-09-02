import 'package:sql_parser/src/parser/parser.dart';
import 'package:sql_parser/src/parser/match.dart';
import 'package:sql_parser/src/lexer/token.dart';

import 'lexer.dart';

class Db2Splitter extends Splitter {
  Db2Splitter(String content) : super(Db2Lexer(content));

  @override
  List<SQLChunk> split({String delimiter = ";", bool skipWhitespace = false, bool skipComment = false}) {
    Token? splitWhereFunc() => l.scanWhere(
          (tok) => (tok.id == TokenType.punctuation && tok.content == delimiter),
        );

    return splitWhere(splitWhereFunc, skipWhitespace: skipWhitespace, skipComment: skipComment);
  }
}

class Db2SQLDefiner extends SQLDefiner {
  final String content;
  Db2SQLDefiner(this.content);

  @override
  SQLType get sqlType {
    // DQL: Query statements
    if (Matcher(Db2Lexer(content)).match("{select|with|values|explain|describe} {*}")) {
      return SQLType.dql;
    }

    // DML: Data manipulation statements
    if (Matcher(Db2Lexer(content)).match("{insert|update|delete|merge|call} {*}")) {
      return SQLType.dml;
    }

    // DDL: Data definition statements
    if (Matcher(Db2Lexer(content)).match("{create|alter|drop|truncate|rename|comment} {*}")) {
      return SQLType.ddl;
    }

    // DCL: Data control statements
    if (Matcher(Db2Lexer(content)).match("{grant|revoke} {*}")) {
      return SQLType.dcl;
    }

    return SQLType.other;
  }

  @override
  bool get isDangerousSQL {
    if (Matcher(Db2Lexer(content)).match("{truncate|drop} {*}")) {
      return true;
    }
    if (Matcher(Db2Lexer(content)).match("{delete|update} {*}")) {
      if (!Matcher(Db2Lexer(content)).match("{delete|update} {*} where {*}")) {
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
    return Matcher(Db2Lexer(content)).match("select {*}");
  }

  @override
  bool get changeSchema {
    return Matcher(Db2Lexer(content)).match("set current schema {*}") ||
        Matcher(Db2Lexer(content)).match("set current_schema {*}") ||
        Matcher(Db2Lexer(content)).match("set schema {*}");
  }

  @override
  String wrapLimit(String sql, int limit) {
    if (!Matcher(Db2Lexer(content)).match("select {*}")) {
      return sql;
    }
    return "SELECT * FROM ($sql) dt_1 FETCH FIRST $limit ROWS ONLY";
  }

  @override
  String trimDelimiter(String sql) {
    final trimmed = Db2Lexer(content).trimEndWhere((token) {
      return token.id == TokenType.whitespace ||
          token.id == TokenType.comment ||
          (token.id == TokenType.punctuation && token.content == ";");
    });
    return trimmed;
  }
}
