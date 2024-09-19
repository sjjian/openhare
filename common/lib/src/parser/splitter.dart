import 'lexer.dart';
import 'token.dart';

class Splitter {
  String content;

  String delimiter;

  Splitter(this.content, this.delimiter);

  List<String> split() {
    List<String> sqlList = List.empty(growable: true);
    /*
      找下一个分号, 存在两种情况:
        1. 没有分号则整个字符串是一个SQL, 
        2. 若有分号则将分号及之前的字符串片段切下来，剩余部分继续递归这个过程 
    */
    Token? tok = Lexer(content).scanWhere(
      (tok) => (tok.id == TokenType.punctuation && tok.content == ';'),
    );
    if (tok == null) {
      sqlList.add(content);
      return sqlList;
    }

    String leftContent = content.substring(0, tok.endPos.cursor + 1);
    String rightContent = content.substring(tok.endPos.cursor + 1);

    sqlList.add(leftContent);
    if (rightContent.isEmpty) {
      return sqlList;
    }
    List<String> nextSplit = Splitter(rightContent, delimiter).split();
    if (nextSplit.isNotEmpty) sqlList.addAll(nextSplit);
    return sqlList;
  }
}
