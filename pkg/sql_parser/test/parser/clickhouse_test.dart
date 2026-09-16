import 'package:sql_parser/parser.dart';
import 'package:test/test.dart';

void main() {
  test('clickhouse lexer keyword/comment', () {
    final l = createLexer(
      DialectType.clickhouse,
      "-- line\nselect * from t1",
    );

    final first = l.firstTrim();
    expect(first, isNotNull);
    expect(first!.id, TokenType.keyword);
    expect(first.content, "select");
  });

  test('clickhouse splitter skips semicolon in comments', () {
    final sql = """
SELECT 1; -- note; still comment
SELECT 2;
""";
    final chunks =
        splitSQL(DialectType.clickhouse, sql, skipWhitespace: true, skipComment: true);
    expect(chunks.length, 2);
  });

  test('clickhouse sql type', () {
    expect(parser(DialectType.clickhouse, "select * from t1").sqlType, SQLType.dql);
    expect(parser(DialectType.clickhouse, "show databases").sqlType, SQLType.dql);
    expect(parser(DialectType.clickhouse, "describe t1").sqlType, SQLType.dql);
    expect(parser(DialectType.clickhouse, "insert into t values (1)").sqlType, SQLType.dml);
    expect(parser(DialectType.clickhouse, "create table t (id UInt64) engine = Memory").sqlType, SQLType.ddl);
    expect(parser(DialectType.clickhouse, "optimize table t").sqlType, SQLType.ddl);
  });

  test('clickhouse wrap limit', () {
    final wrapped =
        parser(DialectType.clickhouse, "select * from t1;").wrapLimit("select * from t1", 20);
    expect(wrapped, "SELECT * FROM (select * from t1) AS dt_1 LIMIT 20");
  });

  test('clickhouse wrap limit skips FORMAT', () {
    final sql = "select * from t1 FORMAT JSON";
    final wrapped = parser(DialectType.clickhouse, sql).wrapLimit(sql, 20);
    expect(wrapped, sql);
  });

  test('clickhouse change schema', () {
    expect(parser(DialectType.clickhouse, "use analytics").changeSchema, isTrue);
  });

  test('clickhouse dangerous alter update without where', () {
    expect(
      parser(DialectType.clickhouse, "alter table t update x = 1").isDangerousSQL,
      isTrue,
    );
    expect(
      parser(DialectType.clickhouse, "alter table t update x = 1 where id = 1").isDangerousSQL,
      isFalse,
    );
  });
}
