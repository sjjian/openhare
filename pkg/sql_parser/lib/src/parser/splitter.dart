import 'lexer.dart';
import 'token.dart';
import 'scanner.dart';

class SQLChunk {
  String content;
  Pos start;
  Pos end;

  SQLChunk(this.start, this.end, this.content);

  SQLChunk.empty() : this(Pos.none(), Pos.none(), "");

  @override
  String toString() =>
      "cursor:[${start.cursor} - ${end.cursor}]; pos:[${start.line}:${start.row} - ${end.line}:${end.row}]; content: $content";
}

class Splitter {
  Lexer l;

  String delimiter;

  bool skipWhitespace;

  Splitter(String content, this.delimiter, {this.skipWhitespace = false})
      : l = Lexer(content);

  List<SQLChunk> split() {
    List<SQLChunk> sqlList = List.empty(growable: true);
    /*
      找下一个分号, 存在两种情况:
        1. 没有分号会一直匹配到结束,
        2. 若有分号则将分号及之前的字符串片段切下来，剩余部分继续找分号直到情况1.
    */
    Pos startPos = l.startPos;
    if (skipWhitespace) {
      startPos = l.first((token) => (token.id == TokenType.whitespace))?.startPos ?? startPos;
    }
    while (true) {
      Token? tok = l.scanWhere(
        (tok) => (tok.id == TokenType.punctuation && tok.content == delimiter),
      );
      if (tok == null) {
        sqlList.add(SQLChunk(startPos, l.scanner.pos,
            l.scanner.subString(startPos, l.scanner.pos)));
        return sqlList;
      }
      sqlList.add(SQLChunk(
          startPos, tok.endPos, l.scanner.subString(startPos, tok.endPos)));

      startPos = l.scanner.pos;
      if (skipWhitespace) { 
        final tt = l.first((token) => (token.id == TokenType.whitespace));
        startPos = tt?.startPos ?? l.scanner.pos;
      }
      // 当最后一个字符是";", 直接跳过了.
      if (!l.scanner.hasNext()) {
        return sqlList;
      }
    }
  }
}
