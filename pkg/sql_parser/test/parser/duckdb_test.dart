import 'package:sql_parser/parser.dart';
import 'package:test/test.dart';

void main() {
  test('duckdb lexer keyword/comment', () {
    final l = createLexer(
      DialectType.duckdb,
      "-- line\nselect * from t1",
    );

    final first = l.firstTrim();
    expect(first, isNotNull);
    expect(first!.id, TokenType.keyword);
    expect(first.content, "select");
  });

  test('duckdb splitter with dollar quote body', () {
    final sql = r"""
SELECT $tag$hello;world$tag$;
SELECT 1;
""";
    final chunks =
        splitSQL(DialectType.duckdb, sql, skipWhitespace: true, skipComment: true);
    expect(chunks.length, 2);
    expect(chunks.first.content.toLowerCase().startsWith("select"), isTrue);
    expect(chunks.last.content.toLowerCase().startsWith("select"), isTrue);
  });

  test('duckdb splitter skips semicolon in comments', () {
    final sql = """
SELECT 1; -- note; still comment
SELECT 2;
""";
    final chunks =
        splitSQL(DialectType.duckdb, sql, skipWhitespace: true, skipComment: true);
    expect(chunks.length, 2);
  });

  test('duckdb sql type', () {
    expect(parser(DialectType.duckdb, "select * from t1").sqlType, SQLType.dql);
    expect(parser(DialectType.duckdb, "describe t1").sqlType, SQLType.dql);
    expect(parser(DialectType.duckdb, "install httpfs").sqlType, SQLType.ddl);
    expect(parser(DialectType.duckdb, "copy t1 from 'a.csv'").sqlType, SQLType.dml);
  });

  test('duckdb wrap limit', () {
    final wrapped =
        parser(DialectType.duckdb, "select * from t1;").wrapLimit("select * from t1", 20);
    expect(wrapped, "SELECT * FROM (select * from t1) AS dt_1 LIMIT 20");
  });
}
