import 'package:test/test.dart';
import 'package:sql_parser/src/sql_splitter.dart';
import 'package:sql_parser/src/lexer.dart';

void main() {
  test('test split', () {
    SqlSplitter sp =
        SqlSplitter(Lexer("SELECT * from t1;SELECT * from t2"), ";");
    expect(sp.split(),
        List<String>.from(<String>["SELECT * from t1;", "SELECT * from t2"]));
  });
}
