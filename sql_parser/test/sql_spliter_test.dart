import 'package:test/test.dart';
import 'package:sql_parser/src/sql_splitter.dart';

void main() {
  test('test split', () {
    expect(
      SqlSplitter("SELECT * from t1;SELECT * from t2", ";").split(),
      List<String>.from(<String>["SELECT * from t1;", "SELECT * from t2"]),
    );
    expect(
      SqlSplitter("SELECT * from t1;SELECT * from t2;", ";").split(),
      List<String>.from(<String>["SELECT * from t1;", "SELECT * from t2;"]),
    );
  });
}
