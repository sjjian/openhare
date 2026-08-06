import 'lexer.dart';
import 'token.dart';
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
      ctx.scanner.seek(ctx.startPos);
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
    var onlyDigit = true;
    if (!Char.isDigit(ctx.scanner.curChar())) {
      onlyDigit = false;
    }
    if (!isIdentChar(ctx.scanner.curChar())) {
      return (false, null);
    }
    while (ctx.scanner.hasNext() && isIdentChar(ctx.scanner.nextChar())) {
      ctx.scanner.next();
    }
    if (onlyDigit) {
      return (false, null);
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
    if (match &&
        keywords.contains(ctx.scanner
            .subString(ctx.startPos, ctx.scanner.pos)
            .toUpperCase())) {
      return (match, TokenType.keyword);
    }
    return (match, tok);
  }
}

class BetweenTokenBuilder implements TokenBuilder {
  final String _start;
  final String _end;
  final bool _escape;
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

class PunctuationTokenBuilder implements TokenBuilder {
  PunctuationTokenBuilder();

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (Char.isPunctuation(ctx.scanner.curChar())) {
      return (true, TokenType.punctuation);
    }
    return (false, null);
  }
}

class NumberTokenBuilder implements TokenBuilder {
  NumberTokenBuilder();

  (bool, TokenType?) matchFloat(LexerContext ctx, bool needDigit) {
    var hasDigit = false;
    while (ctx.scanner.hasNext() && Char.isDigit(ctx.scanner.nextChar())) {
      hasDigit = true;
      ctx.scanner.next();
    }
    if (needDigit && !hasDigit) {
      return (false, null);
    }
    return (true, TokenType.number);
  }

  (bool, TokenType?) matchInt(LexerContext ctx) {
    while (ctx.scanner.hasNext()) {
      if (Char.isDigit(ctx.scanner.nextChar())) {
        ctx.scanner.next();
        continue;
      } else if (ctx.scanner.nextChar() == Char.period) {
        ctx.scanner.next();
        return matchFloat(ctx, false);
      } else {
        break;
      }
    }
    return (true, TokenType.number);
  }

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (ctx.scanner.curChar() == Char.period) {
      return matchFloat(ctx, true);
    }
    if (Char.isDigit(ctx.scanner.curChar())) {
      return matchInt(ctx);
    }
    return (false, null);
  }
}

class EOFTokenBuilder implements TokenBuilder {
  EOFTokenBuilder();

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (ctx.scanner.curChar() == 0) {
      return (true, TokenType.eof);
    }
    return (false, null);
  }
}

class CommentBuilder implements TokenBuilder {
  CommentBuilder();

  (bool, TokenType?) _matchUntilNewLine(LexerContext ctx) {
    while (ctx.scanner.hasNext() && ctx.scanner.next()) {
      // \n
      if (ctx.scanner.curChar() == Char.$n) {
        return (true, TokenType.comment);
      }
      // \r 或 \r\n
      if (ctx.scanner.curChar() == Char.$r) {
        if (ctx.scanner.hasNext() && ctx.scanner.nextChar() == Char.$n) {
          ctx.scanner.next();
        }
        return (true, TokenType.comment);
      }
    }
    // 匹配到结束也算注释的一部分
    return (true, TokenType.comment);
  }

  (bool, TokenType?) _matchUntilRightComment(LexerContext ctx) {
    while (ctx.scanner.hasNext() && ctx.scanner.next()) {
      if (ctx.scanner.curChar() == Char.star &&
          ctx.scanner.hasNext() &&
          ctx.scanner.nextChar() == Char.slash) {
        ctx.scanner.next();
        return (true, TokenType.comment);
      }
    }
    return (false, null);
  }

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (ctx.scanner.startWith("--")) {
      ctx.scanner.nextN(2);
      return _matchUntilNewLine(ctx);
    }
    if (ctx.scanner.startWith("/*")) {
      ctx.scanner.nextN(2);
      return _matchUntilRightComment(ctx);
    }
    return (false, null);
  }
}

class BracketValueTokenBuilder implements TokenBuilder {
  static final int _leftBracket = "[".codeUnitAt(0);
  static final int _rightBracket = "]".codeUnitAt(0);

  BracketValueTokenBuilder();

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (ctx.scanner.curChar() != _leftBracket) {
      return (false, null);
    }

    while (ctx.scanner.hasNext() && ctx.scanner.next()) {
      if (ctx.scanner.curChar() == _rightBracket) {
        if (ctx.scanner.hasNext() && ctx.scanner.nextChar() == _rightBracket) {
          ctx.scanner.next();
          continue;
        }
        return (true, TokenType.bracketValue);
      }
    }
    return (false, null);
  }
}

/// dollar-quoted string: `$tag$...$tag$` or `$$...$$`.
class DollarQuotedTokenBuilder implements TokenBuilder {
  DollarQuotedTokenBuilder();

  bool _isTagStart(int char) {
    return Char.isLowercaseLatin(char) ||
        Char.isUppercaseLatin(char) ||
        char == Char.$_;
  }

  bool _isTagPart(int char) {
    return _isTagStart(char) || Char.isDigit(char);
  }

  @override
  (bool, TokenType?) matchToken(LexerContext ctx) {
    if (ctx.scanner.curChar() != Char.$$) {
      return (false, null);
    }

    final openStart = ctx.startPos.copy();

    if (!ctx.scanner.hasNext() || !ctx.scanner.next()) {
      return (false, null);
    }

    if (ctx.scanner.curChar() != Char.$$) {
      if (!_isTagStart(ctx.scanner.curChar())) {
        return (false, null);
      }
      while (true) {
        if (ctx.scanner.curChar() == Char.$$) {
          break;
        }
        if (!_isTagPart(ctx.scanner.curChar())) {
          return (false, null);
        }
        if (!ctx.scanner.hasNext() || !ctx.scanner.next()) {
          return (false, null);
        }
      }
    }

    final delimiter = ctx.scanner.subString(openStart, ctx.scanner.pos);
    while (ctx.scanner.hasNext() && ctx.scanner.next()) {
      if (ctx.scanner.startWith(delimiter)) {
        ctx.scanner.nextN(delimiter.length - 1);
        return (true, TokenType.singleQValue);
      }
    }
    return (false, null);
  }
}
