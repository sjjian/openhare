import 'dart:collection';

import 'package:sql_parser/src/lexer.dart';

import 'scanner.dart';
import "character.dart";

abstract class TokenBuilder {
  (bool, TokenType?) matchToken(LexerContext ctx);
}

class TokenRooter implements TokenBuilder {
  List<TokenBuilder> entry;

  TokenRooter(this.entry);

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    for (var node in entry) {
      var (match, tok) = node.matchToken(ctx);
      if (match) {
        return (match, tok);
      }
      ctx.scanner.seek(ctx.lastPos);
    }
    return (false, null);
  }
}

class KeyWordTokenBuilder implements TokenBuilder {
  Set<String>? keywords;

  KeyWordTokenBuilder(HashMap<int, String> keywords) {
    this.keywords = keywords.values.toSet();
  }

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (ctx.scanner.curChar() == Char.$0) {
      return (false, null);
    }

    return (false, null);
  }
}

class IdentTokenBuilder implements TokenBuilder {
  IdentTokenBuilder();

  bool isIdentChar(int char) {
    return (Char.isLowercaseLatin(char) ||
        Char.isUppercaseLatin(char) ||
        Char.isDigit(char) ||
        char == Char.$_ ||
        char == Char.$$);
  }

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (!isIdentChar(ctx.scanner.curChar())) {
      return (false, null);
    }
    while (ctx.scanner.hasNext() && isIdentChar(ctx.scanner.nextChar())) {
      ctx.scanner.next();
    }
    return (true, TokenType.ident);
  }
}

enum TokenType {
  eof,
  invalid,
  keyword,
  ident,
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
