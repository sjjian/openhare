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
  static Set<String> keywords = {"select", "update"};

  static TokenBuilder builder = TokenRooter(<TokenBuilder>[
    EOFTokenBuilder(),
    SpaceTokenBuilder(),
    KeyWordTokenBuilder(Lexer.keywords),
    SingleQValueTokenBuilder(),
    DoubleQValueTokenBuilder(),
    BackQValueTokenBuilder(),
    NumberTokenBuilder(),
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

  Token genToken(TokenType tok) {
    return Token(tok, scanner.subString(startPos, scanner.pos), startPos.copy(),
        scanner.pos.copy());
  }
}
