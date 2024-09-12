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
    // int pos = 0;
    int startPos = 0;
    Int endPos = 0;
    while (true) {
      Token tok = lexer.scan();
      if (tok.id != TokenType.eof) {
        endPos = tok.endPos;
      }
      if ((tok.id == TokenType.punctuation && tok.content == ';')) {
          String data = lexer.scanner.subString(startPos, tok.endPos);
          sqlList.add(data);
          startPos = lexer.startPos;
      }

      if (
          tok.id == TokenType.eof) {
        print("[${tok.content}]");

        print(data);
        
        startPos = lexer.startPos;
      }
      if (tok.id == TokenType.eof) {
        break;
      }
    }
    return sqlList;
  }
}
