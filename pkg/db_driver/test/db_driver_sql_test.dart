import 'package:db_driver/db_driver.dart';
import 'package:test/test.dart';

void main() {
  group('qualifyRelation', () {
    test('优先 schema，否则 database，否则仅表名', () {
      expect(
        qualifyRelation(MySQLConnection.quoteIdent, name: 't', database: 'db', schema: 's'),
        '`s`.`t`',
      );
      expect(
        qualifyRelation(MySQLConnection.quoteIdent, name: 't', database: 'db'),
        '`db`.`t`',
      );
      expect(qualifyRelation(SQLiteConnection.quoteIdent, name: 't'), '"t"');
    });
  });

  group('MySQLConnection', () {
    test('SELECT 无列用 *', () {
      expect(
        MySQLConnection.buildSelectSql(name: 'users', database: 'app'),
        'SELECT\n  *\nFROM `app`.`users`;',
      );
    });

    test('INSERT 无列不按库分叉', () {
      expect(
        MySQLConnection.buildInsertSql(name: 't', database: 'db'),
        'INSERT INTO `db`.`t`;',
      );
    });
  });

  group('PGConnection', () {
    test('SELECT 用双引号', () {
      expect(
        PGConnection.buildSelectSql(
          name: 'users',
          schema: 'public',
          columns: ['id', 'name'],
        ),
        'SELECT\n  "id",\n  "name"\nFROM "public"."users";',
      );
    });

    test('INSERT 占位符为 \$n', () {
      expect(
        PGConnection.buildInsertSql(
          name: 't',
          schema: 'public',
          columns: ['id', 'name'],
        ),
        'INSERT INTO "public"."t" ("id", "name")\nVALUES (\$1, \$2);',
      );
    });
  });

  group('MSSQLConnection', () {
    test('INSERT 占位符为 @pN', () {
      expect(
        MSSQLConnection.buildInsertSql(
          name: 't',
          schema: 'dbo',
          columns: ['id'],
        ),
        'INSERT INTO [dbo].[t] ([id])\nVALUES (@p1);',
      );
    });
  });

  group('OracleConnection', () {
    test('INSERT 占位符为 :n', () {
      expect(
        OracleConnection.buildInsertSql(
          name: 't',
          database: 'HR',
          columns: ['id'],
        ),
        'INSERT INTO "HR"."t" ("id")\nVALUES (:1);',
      );
    });
  });

  group('SQLiteConnection', () {
    test('无前缀仅表名', () {
      expect(
        SQLiteConnection.buildSelectSql(name: 't'),
        'SELECT\n  *\nFROM "t";',
      );
    });
  });

  group('ConnectionWrapper capabilities', () {
    test('SQL 库支持 SelectSql / InsertSql', () {
      for (final type in [
        DatabaseType.mysql,
        DatabaseType.pg,
        DatabaseType.mssql,
        DatabaseType.oracle,
        DatabaseType.sqlite,
        DatabaseType.duckdb,
      ]) {
        expect(ConnectionWrapper.supportsSelectSqlOf(type), isTrue, reason: '$type');
        expect(ConnectionWrapper.supportsInsertSqlOf(type), isTrue, reason: '$type');
      }
    });

    test('Redis / MongoDB 暂不支持 SelectSql / InsertSql', () {
      for (final type in [DatabaseType.redis, DatabaseType.mongodb]) {
        expect(ConnectionWrapper.supportsSelectSqlOf(type), isFalse, reason: '$type');
        expect(ConnectionWrapper.supportsInsertSqlOf(type), isFalse, reason: '$type');
      }
    });
  });
}
