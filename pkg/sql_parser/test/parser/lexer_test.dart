import 'package:common/parser.dart';
import 'package:common/src/parser/token.dart';
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
  test('test lexer scanWhere', () {
    var l = Lexer(
        "aaa_123 \"abc\"   \"a\\\"bc\" 'abc' select a\$aa `\"abc` 123 123.1abc.1 ;");

    Token? token = l.scanWhere(
        (token) => (token.id == TokenType.number && token.content == "123.1"));
    expect(token!.id, TokenType.number);

    token = l.scanWhere(
        (token) => (token.id == TokenType.punctuation && token.content == ";"));
    expect(token!.id, TokenType.punctuation);

    token = l.scanWhere(
        (token) => (token.id == TokenType.ident && token.content == "no"));
    expect(token, null);
  });

  test("test lexer first", () {
    var l = Lexer("/* test */    select;");
    Token? token = l.first((token) =>
        (token.id == TokenType.whitespace || token.id == TokenType.comment));
    expect(token!.id, TokenType.keyword);
    expect(token.content, "select");

    l = Lexer("-- abc\n select;");
    token = l.first((token) =>
        (token.id == TokenType.whitespace || token.id == TokenType.comment));
    expect(token!.id, TokenType.keyword);
    expect(token.content, "select");

    l = Lexer("# abc\r\n select;");
    token = l.first((token) =>
        (token.id == TokenType.whitespace || token.id == TokenType.comment));
    expect(token!.id, TokenType.keyword);
    expect(token.content, "select");

    l = Lexer("-- cba\r\n# cba\r select;");
    token = l.firstTrim();
    expect(token!.id, TokenType.keyword);
    expect(token.content, "select");
  });
}
