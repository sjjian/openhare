import 'package:sql_parser/parser.dart';
import 'package:test/test.dart';

void main() {
  test('db2 lexer keyword/comment', () {
    final l = createLexer(
      DialectType.db2,
      "-- line\nselect * from SYSIBM.SYSDUMMY1",
    );

    final first = l.firstTrim();
    expect(first, isNotNull);
    expect(first!.id, TokenType.keyword);
    expect(first.content, "select");
  });

  test('db2 splitter with quotes and semicolons', () {
    final sql = """
SELECT 'hello;world' FROM SYSIBM.SYSDUMMY1;
SELECT 1 FROM SYSIBM.SYSDUMMY1;
""";
    final chunks =
        splitSQL(DialectType.db2, sql, skipWhitespace: true, skipComment: true);
    expect(chunks.length, 2);
    expect(chunks.first.content.toLowerCase().startsWith("select"), isTrue);
    expect(chunks.last.content.toLowerCase().startsWith("select"), isTrue);
  });

  test('db2 splitter skips semicolon in comments', () {
    final sql = """
SELECT 1 FROM SYSIBM.SYSDUMMY1; -- note; still comment
SELECT 2 FROM SYSIBM.SYSDUMMY1;
""";
    final chunks =
        splitSQL(DialectType.db2, sql, skipWhitespace: true, skipComment: true);
    expect(chunks.length, 2);
  });

  test('db2 sql type', () {
    expect(parser(DialectType.db2, "select * from t1").sqlType, SQLType.dql);
    expect(parser(DialectType.db2, "values current schema").sqlType, SQLType.dql);
    expect(parser(DialectType.db2, "describe table t1").sqlType, SQLType.dql);
    expect(parser(DialectType.db2, "create table t1(id int)").sqlType, SQLType.ddl);
    expect(parser(DialectType.db2, "insert into t1 values (1)").sqlType, SQLType.dml);
  });

  test('db2 wrap limit', () {
    final wrapped =
        parser(DialectType.db2, "select * from t1;").wrapLimit("select * from t1", 20);
    expect(wrapped, "SELECT * FROM (select * from t1) dt_1 FETCH FIRST 20 ROWS ONLY");
  });

  test('db2 dangerous query check', () {
    expect(parser(DialectType.db2, "delete from t1").isDangerousSQL, isTrue);
    expect(parser(DialectType.db2, "delete from t1 where id = 1").isDangerousSQL, isFalse);
    expect(parser(DialectType.db2, "drop table t1").isDangerousSQL, isTrue);
  });

  test('db2 change schema check', () {
    expect(parser(DialectType.db2, "set current schema = MY_SCHEMA").changeSchema, isTrue);
    expect(parser(DialectType.db2, "set schema MY_SCHEMA").changeSchema, isTrue);
    expect(parser(DialectType.db2, "select 1 from t1").changeSchema, isFalse);
  });
}
