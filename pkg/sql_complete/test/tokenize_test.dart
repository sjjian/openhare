import 'package:sql_parser/parser.dart';
import 'package:sql_complete/training.dart';
import 'package:test/test.dart';

void main() {
  group('TokenExtractor', () {
    test('lexer-only kinds: keyword vs object', () {
      const extractor = TokenExtractor(dialect: DialectType.mysql);
      final tokens = extractor.extract(
        "SELECT user_name FROM users WHERE id = 42 AND city = 'NYC'",
      );
      expect(tokens.map((t) => t.normalized).toList(), [
        'select',
        'user_name',
        'from',
        'users',
        'where',
        'id',
        '=',
        '<NUM>',
        'and',
        'city',
        '=',
        '<STR>',
      ]);
      expect(tokens[0].kind, SqlCompleteKind.keyword);
      expect(tokens[1].kind, SqlCompleteKind.object);
      expect(tokens[3].kind, SqlCompleteKind.object);
      expect(tokens[5].kind, SqlCompleteKind.object);
      expect(tokens[6].kind, isNull); // '='
      expect(tokens[7].kind, isNull); // '<NUM>'
    });

    test('quoted identifiers are objects not strings', () {
      const extractor = TokenExtractor(dialect: DialectType.mysql);
      final tokens = extractor.extract('SELECT `Notes` FROM `t1`');
      expect(tokens.map((t) => t.normalized).toList(), ['select', 'notes', 'from', 't1']);
      expect(tokens[1].kind, SqlCompleteKind.object);
      expect(tokens[3].kind, SqlCompleteKind.object);
    });

    test('collapses objects to <OBJ>', () {
      const extractor = TokenExtractor(
        dialect: DialectType.mysql,
        collapseObjects: true,
      );
      final tokens = extractor.extract(
        'SELECT user_name FROM users AS u WHERE id = 1',
      );
      expect(tokens.map((t) => t.normalized).toList(), [
        'select',
        '<OBJ>',
        'from',
        '<OBJ>',
        'as',
        '<OBJ>',
        'where',
        '<OBJ>',
        '=',
        '<NUM>',
      ]);
      expect(tokens[1].kind, SqlCompleteKind.object);
      expect(tokens[3].kind, SqlCompleteKind.object);
    });
  });

  group('Vocabulary', () {
    test('encodes known and unknown tokens', () {
      const extractor = TokenExtractor();
      final seqs = [
        extractor.extract('SELECT a FROM t'),
        extractor.extract('SELECT b FROM t'),
      ];
      final vocab = Vocabulary.fromTokenSequences(seqs);
      expect(vocab.encodeToken('select'), isNot(vocab.unkId));
      expect(vocab.encodeToken('not_in_vocab_xyz'), vocab.unkId);
    });
  });

  group('token_role', () {
    test('isObjectName 覆盖 ident / 引号名', () {
      const extractor = TokenExtractor(dialect: DialectType.mysql);
      final tokens = extractor.extract('SELECT `c1`, t1 FROM "db"');
      final objects =
          tokens.where((t) => t.isObjectName).map((t) => t.normalized);
      expect(objects, containsAll(['c1', 't1', 'db']));
      expect(
        tokens
            .where((t) => t.normalized == 'select')
            .every((t) => t.isObjectName),
        isFalse,
      );
    });

    test('tagCompleteKinds 只标 keyword/object', () {
      const raw = [
        ModelToken(
          type: TokenType.keyword,
          surface: 'SELECT',
          normalized: 'select',
        ),
        ModelToken(
          type: TokenType.ident,
          surface: 'id',
          normalized: 'id',
        ),
        ModelToken(
          type: TokenType.punctuation,
          surface: '=',
          normalized: '=',
        ),
        ModelToken(
          type: TokenType.number,
          surface: '1',
          normalized: '<NUM>',
        ),
      ];
      final tagged = TokenExtractor.tagCompleteKinds(raw);
      expect(tagged[0].kind, SqlCompleteKind.keyword);
      expect(tagged[1].kind, SqlCompleteKind.object);
      expect(tagged[2].kind, isNull); // '='
      expect(tagged[3].kind, isNull); // '<NUM>'
    });

    test('collapseObjectForInput 折叠各类对象', () {
      const obj = ModelToken(
        type: TokenType.ident,
        surface: 'users',
        normalized: 'users',
        kind: SqlCompleteKind.table,
      );
      final collapsed = TokenExtractor.collapseObjectForInput(obj);
      expect(collapsed.normalized, TokenExtractor.objectToken);
      expect(collapsed.kind, SqlCompleteKind.object);
    });

    test('isPredictTarget 依赖 kind', () {
      const kw = ModelToken(
        type: TokenType.keyword,
        surface: 'SELECT',
        normalized: 'select',
        kind: SqlCompleteKind.keyword,
      );
      const op = ModelToken(
        type: TokenType.punctuation,
        surface: '=',
        normalized: '=',
      );
      expect(kw.isPredictTarget, isTrue);
      expect(op.isPredictTarget, isFalse);
    });
  });
}
