import 'package:test/test.dart';
import 'package:sql_parser/parser.dart';

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
  test('test split with ;', () {
    List<SQLChunk> querys =
        Splitter("SELECT * from t1;SELECT\n * from t2;", ";").split();
    expect(querys.length, 2);
    expect(querys[0].toString(),
        "cursor:[0 - 16]; pos:[1:1 - 1:17]; content: SELECT * from t1;");
    expect(querys[1].toString(),
        "cursor:[17 - 34]; pos:[1:18 - 2:11]; content: SELECT\n * from t2;");
  });

  test('test split with ; and skipTrim', () {
    List<SQLChunk> querys =
        Splitter("SELECT * from t1;\n\nSELECT\n * from t2;", ";", skipWhitespace: true).split();
    expect(querys.length, 2);
    expect(querys[0].toString(),
        "cursor:[0 - 16]; pos:[1:1 - 1:17]; content: SELECT * from t1;");
    expect(querys[1].toString(),
        "cursor:[19 - 36]; pos:[3:1 - 4:11]; content: SELECT\n * from t2;");
  });

  test('test split with ; and skipTrim 2', () {
    List<SQLChunk> querys =
        Splitter("\r\nSELECT * from t1;\n\nSELECT\n * from t2;", ";", skipWhitespace: true).split();
    expect(querys.length, 2);
    expect(querys[0].toString(),
        "cursor:[2 - 18]; pos:[2:1 - 2:17]; content: SELECT * from t1;");
    expect(querys[1].toString(),
        "cursor:[21 - 38]; pos:[4:1 - 5:11]; content: SELECT\n * from t2;");
  });

  test('test split with ; and skipTrim 3', () {
    List<SQLChunk> querys =
        Splitter("\r\nSELECT * from t1;\n\nSELECT\n * from t2;\n\n\n", ";", skipWhitespace: true).split();
    expect(querys.length, 2);
    expect(querys[0].toString(),
        "cursor:[2 - 18]; pos:[2:1 - 2:17]; content: SELECT * from t1;");
    expect(querys[1].toString(),
        "cursor:[21 - 38]; pos:[4:1 - 5:11]; content: SELECT\n * from t2;");
  });
}
