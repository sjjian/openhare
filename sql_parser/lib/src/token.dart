import 'scanner.dart';

enum TokenType {
  eof,
  whitespace,
  invalid,
  keyword,
  ident,
  number,
  punctuation,
  doubleQValue, // 双引号字符串, "hello".
  singleQValue, // 单引号字符串, 'hello'.
  backQValue, // 反引号字符串, `hello`.
}

class Token {
  TokenType id;
  String content;
  Pos startPos;
  Pos endPos;

  Token(this.id, this.content, this.startPos, this.endPos);

  @override
  String toString() => content;
}

