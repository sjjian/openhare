import "token.dart";
import "scanner.dart";
import "token_builder.dart";

class LexerContext {
  Pos startPos;
  Scanner scanner;

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
    var (match, tok) = builder.matchToken(this);
    if (!match || tok == null) {
      return genToken(TokenType.invalid);
    } else {
      Token token = genToken(tok);
      scanner.next();
      startPos = scanner.pos;
      return token;
    }
  }

  Token genToken(TokenType tok) {
    return Token(tok, scanner.subString(startPos, scanner.pos), startPos.copy(),
        scanner.pos.copy());
  }

  //   String subString() {
  //   return scanner.subString(startPos, scanner.pos);
  // }
}
