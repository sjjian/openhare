import 'package:sql_parser/sql_parser.dart';
import 'package:sql_parser/src/token.dart';
import 'package:test/test.dart';

void main() {
  test('First Test', () {
    var l = Lexer(
        "aaa_123 \"abc\"   \"a\\\"bc\" select a\$aa `\"abc` 123 123.1abc.1 ;");
    Token tok = l.scan();
    expect(tok.id, TokenType.ident);
    expect(tok.content, "aaa_123");

    tok = l.scan();
    // expect(tok.id, TokenType.whitespace);
    expect(tok.content, "abc");
    // expect(actual, matcher)
  });
}
