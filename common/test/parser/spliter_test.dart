import 'package:test/test.dart';
import 'package:common/parser.dart';

void main() {
  test('test split', () {
    List<SQLChunk> querys =
        Splitter("SELECT * from t1;SELECT\n * from t2", ";").split();
    expect(querys.length, 2);
    expect(querys[0].toString(),
        "cursor:[0 - 16]; pos:[1:1 - 1:17]; content: SELECT * from t1;");
    expect(querys[1].toString(),
        "cursor:[17 - 33]; pos:[1:18 - 2:10]; content: SELECT\n * from t2");
  });
}
