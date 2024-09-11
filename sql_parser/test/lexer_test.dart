import 'package:sql_parser/sql_parser.dart';
import 'package:sql_parser/src/token.dart';
import 'package:test/test.dart';

void main() {
  test('test lexer scan', () {
    var l = Lexer(
        "aaa_123 \"abc\"   \"a\\\"bc\" 'abc' select a\$aa `\"abc` 123 123.1abc.1 ;");
    Token tok = l.scan();
    expect(tok.id, TokenType.ident);
    expect(tok.content, "aaa_123");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.doubleQValue);
    expect(tok.content, "\"abc\"");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, "   ");

    tok = l.scan();
    expect(tok.id, TokenType.doubleQValue);
    expect(tok.content, "\"a\\\"bc\"");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.singleQValue);
    expect(tok.content, "'abc'");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.keyword);
    expect(tok.content, "select");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.ident);
    expect(tok.content, "a\$aa");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.backQValue);
    expect(tok.content, "`\"abc`");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.number);
    expect(tok.content, "123");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.number);
    expect(tok.content, "123.1");

    tok = l.scan();
    expect(tok.id, TokenType.ident);
    expect(tok.content, "abc");

    tok = l.scan();
    expect(tok.id, TokenType.number);
    expect(tok.content, ".1");

    tok = l.scan();
    expect(tok.id, TokenType.whitespace);
    expect(tok.content, " ");

    tok = l.scan();
    expect(tok.id, TokenType.punctuation);
    expect(tok.content, ";");

    tok = l.scan();
    expect(tok.id, TokenType.eof);
    expect(tok.content, "");
  });
}
