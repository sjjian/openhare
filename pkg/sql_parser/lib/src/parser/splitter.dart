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
  bool skipComment;

  Splitter(
    String content,
    this.delimiter, {
    this.skipWhitespace = false,
    this.skipComment = false,
  }) : l = Lexer(content);

  List<SQLChunk> split() {
    bool skipFunc(Token token) {
      if (skipComment && token.id == TokenType.comment) {
        return true;
      }
      if (skipWhitespace && token.id == TokenType.whitespace) {
        return true;
      }
      return false;
    }
    /*
      找下一个分号, 存在两种情况:
        1. 没有分号会一直匹配到结束,
        2. 若有分号则将分号及之前的字符串片段切下来，剩余部分继续找分号直到情况1.
    */
    List<SQLChunk> sqlList = List.empty(growable: true);
    while (true) {
      // 获取第一个token的位置，并跳过指定字符.
      Pos? startPos = l.first(skipFunc)?.startPos;
      if (startPos == null) {
        return sqlList;
      }
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

      // 当最后一个字符是";", 直接跳过了.
      if (!l.scanner.hasNext()) {
        return sqlList;
      }
    }
  }
}
