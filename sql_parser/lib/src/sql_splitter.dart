import 'dart:ffi';

import 'package:sql_parser/src/lexer.dart';
import 'package:sql_parser/src/scanner.dart';
import 'package:sql_parser/src/token.dart';

class SqlSplitter {
  Lexer lexer;

  String delimiter;

  SqlSplitter(this.lexer, this.delimiter);

  List<String> split() {
    List<String> sqlList = List.empty(growable: true);
    int pos = 0;
    while (true) {
      Token tok = lexer.scan();
      print("[${tok.id}][${tok.content}][${tok.endPos.cursor}]");
      if ((tok.id == TokenType.punctuation && tok.content == ';') ||
          tok.id == TokenType.eof) {
        sqlList.add(lexer.ctx.scanner.buf.substring(pos, tok.endPos.cursor+1));
        pos = tok.endPos.cursor;
      }
      if (tok.id == TokenType.eof) {
        break;
      }
    }
    return sqlList;
  }
}
