import 'package:sql_parser/src/lexer.dart';
import 'package:sql_parser/src/scanner.dart';
import 'package:sql_parser/src/token.dart';

class SqlSpliter {
  Lexer lexer;

  String delimiter;

  SqlSpliter(this.lexer, this.delimiter);

  List<String> split() {
    List<String> sqlList = List.empty(growable: true);
    Pos curPos = Pos.init();
    while (true) {
      Token tok = lexer.scan();
      if ((tok.id == TokenType.ident && tok.content == ";") ||
          tok.id == TokenType.eof) {
        sqlList.add(lexer.ctx.scanner.subString(curPos, tok.endPos));
      }
      if (tok.id == TokenType.eof) {
        break;
      }
    }
    return sqlList;
  }
}
