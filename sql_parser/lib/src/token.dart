import 'lexer.dart';
import 'scanner.dart';
import "character.dart";

enum TokenType {
  eof,
  whitespace,
  invalid,
  keyword,
  ident,
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

class SpaceTokenBuilder implements TokenBuilder {
  SpaceTokenBuilder();

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (!Char.isWhitespace(ctx.scanner.curChar())) {
      return (false, null);
    }
    while (ctx.scanner.hasNext() && Char.isWhitespace(ctx.scanner.nextChar())) {
      ctx.scanner.next();
    }
    return (true, TokenType.whitespace);
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

class KeyWordTokenBuilder extends IdentTokenBuilder {
  Set<String> keywords;

  KeyWordTokenBuilder(this.keywords) : super();

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    var (match, tok) = super.matchToken(ctx);
    // 设计的不合理
    if (match && keywords.contains(ctx.subString().toLowerCase())) {
      return (match, TokenType.keyword);
    }
    return (match, tok);
  }
}

class BetweenTokenBuilder implements TokenBuilder {
  String _start;
  String _end;
  bool _escape;
  TokenType tokenType;

  BetweenTokenBuilder(this.tokenType, this._start, this._end, this._escape);

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (!ctx.scanner.startWith(_start)) {
      return (false, null);
    }
    ctx.scanner.nextN(_start.length - 1);

    while (ctx.scanner.hasNext() && ctx.scanner.next()) {
      if (_escape && ctx.scanner.curChar() == Char.escape) {
        // 当遇到转义符时，跳过后面一个字符
        if (ctx.scanner.hasNext()) {
          ctx.scanner.next();
        }
        continue;
      }
      if (ctx.scanner.startWith(_end)) {
        ctx.scanner.nextN(_end.length - 1);
        return (true, tokenType);
      }
    }
    return (false, null);
  }
}

class SingleQValueTokenBuilder extends BetweenTokenBuilder {
  SingleQValueTokenBuilder() : super(TokenType.singleQValue, "'", "'", true);
}

class DoubleQValueTokenBuilder extends BetweenTokenBuilder {
  DoubleQValueTokenBuilder() : super(TokenType.doubleQValue, "\"", "\"", true);
}

class BackQValueTokenBuilder extends BetweenTokenBuilder {
  BackQValueTokenBuilder() : super(TokenType.backQValue, "`", "`", false);
}
