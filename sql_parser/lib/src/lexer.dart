import "token.dart";
import "scanner.dart";
import "token_builder.dart";

class LexerContext {
  Pos lastPos;
  Scanner scanner;

  LexerContext(String content)
      : scanner = Scanner(content),
        lastPos = Pos.init();

  LexerContext.from(LexerContext parent)
      : scanner = parent.scanner,
        lastPos = parent.scanner.pos.copy();

  Token genToken(TokenType tok) {
    return Token(
        tok, scanner.subString(lastPos, scanner.pos), lastPos, scanner.pos);
  }

  String subString() {
    return scanner.subString(lastPos, scanner.pos);
  }
}

class Lexer {
  static Set<String> keywords = {"select", "update"};

  static TokenBuilder builder = TokenRooter(<TokenBuilder>[
    SpaceTokenBuilder(),
    KeyWordTokenBuilder(Lexer.keywords),
    SingleQValueTokenBuilder(),
    DoubleQValueTokenBuilder(),
    BackQValueTokenBuilder(),
    NumberTokenBuilder(),
    PunctuationTokenBuilder()
  ]);

  LexerContext ctx;

  Lexer(String content) : ctx = LexerContext(content);

  Token scan() {
    if (!ctx.scanner.next()) {
      ctx = LexerContext.from(ctx);
      return ctx.genToken(TokenType.eof);
    }
    ctx = LexerContext.from(ctx);
    var (match, tok) = builder.matchToken(ctx);
    if (!match || tok == null) {
      return ctx.genToken(TokenType.invalid);
    } else {
      return ctx.genToken(tok);
    }
  }
}
