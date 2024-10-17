import "token.dart";
import "scanner.dart";
import "token_builder.dart";

class LexerContext {
  Pos startPos;
  Scanner scanner;
  bool eof = false; // 当 scanner 偏移到最后一位时，再次偏移就返回 eof.

  LexerContext(String content)
      : scanner = Scanner(content),
        startPos = Pos.init();
}

class Lexer extends LexerContext {
  static Set<String> keywords = {"select", "update", "use"};

  static TokenBuilder builder = TokenRooter(<TokenBuilder>[
    EOFTokenBuilder(),
    SpaceTokenBuilder(),
    KeyWordTokenBuilder(Lexer.keywords),
    SingleQValueTokenBuilder(),
    DoubleQValueTokenBuilder(),
    BackQValueTokenBuilder(),
    NumberTokenBuilder(),
    CommentBuilder(),
    PunctuationTokenBuilder(),
  ]);

  Lexer(String content) : super(content);

  Token scan() {
    if (eof) {
      return Token(TokenType.eof, "", Pos.none(), Pos.none());
    }
    var (match, tok) = builder.matchToken(this);

    Token token =
        (!match || tok == null) ? genToken(TokenType.invalid) : genToken(tok);

    // 如果scanner next 失败, 则代表已经偏移结束了
    scanner.next() ? startPos = scanner.pos : eof = true;
    return token;
  }

  Token? scanWhere(bool Function(Token token) check) {
    while (!eof) {
      Token token = scan();
      if (check(token)) return token;
    }
    return null;
  }

  // 获取第一个token,
  Token? first(bool Function(Token token) skip) {
    while (!eof) {
      Token token = scan();
      if (skip(token)) {
        continue;
      } else {
        return token;
      }
    }
    return null;
  }

  // 获取第一个token, 去掉空格或注释.
  Token? firstTrim() {
    return first((token) =>
        (token.id == TokenType.whitespace || token.id == TokenType.comment));
  }

  Token genToken(TokenType tok) {
    return Token(tok, scanner.subString(startPos, scanner.pos), startPos.copy(),
        scanner.pos.copy());
  }
}
