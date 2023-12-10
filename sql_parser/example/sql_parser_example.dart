import 'package:sql_parser/sql_parser.dart';
import 'package:sql_parser/src/token.dart';

void main() {
  var l = Lexer("aaa_123 a\$aa");
  while (true) {
    Token tok = l.scan();
    print("[$tok]:[${tok.id}]:[${tok.startPos.cursor}]:[${tok.endPos.cursor}]");
    if (tok.id == TokenType.eof) {
      return;
    }
  }
}
