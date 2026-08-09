import 'package:sql_complete/training.dart';
import 'package:test/test.dart';

import 'sample_spans.dart';

void main() {
  test('loadBundledCheckpoint 同步可用', () {
    final ckpt = loadBundledCheckpoint();
    expect(ckpt.vocab.size, greaterThan(0));
    expect(ckpt.targetIds, isNotEmpty);
    final preds = ckpt.toPredictor().predict('SELECT ', topK: 3);
    expect(preds, isNotEmpty);
  });

  test('SqlCompletionEngine 默认启用预置模型', () {
    final engine = SqlCompletionEngine(
      catalog: const SqlCompleteCatalog(
        keywords: [
          SqlCompleteCatalogEntry(text: 'SELECT', kind: SqlCompleteKind.keyword),
        ],
      ),
    );
    expect(engine.predictor, isNotNull);
    final result = engine.complete(const SqlCompletionRequest(
      sqlPrefix: 'SELECT ',
      lineBefore: 'SELECT ',
    ));
    expect(result.items, isNotEmpty);
  });

  test('toCompactJson 截断后 top-1 / top-5 成员不变', () async {
    final ckpt = await _tinyCheckpoint();
    final reference = ckpt.toPredictor();
    final truncated = Checkpoint.fromJsonString(
      ckpt.toCompactJson(fractionDigits: 6),
    ).toPredictor();

    final prefixes = [
      'SELECT',
      'SELECT id FROM',
      'SELECT name FROM users',
      'INSERT INTO',
      'UPDATE',
    ];

    for (final prefix in prefixes) {
      final a = reference.predict(prefix, topK: 5).map((e) => e.token).toList();
      final b = truncated.predict(prefix, topK: 5).map((e) => e.token).toList();
      expect(b.firstOrNull, a.firstOrNull, reason: 'top-1 <$prefix>');
      expect(
        b.toSet(),
        a.toSet(),
        reason: 'top-5 成员 <$prefix>\n  全精度 ${a.join("|")}\n  截断 ${b.join("|")}',
      );
    }
  });

  group('预置模型场景抽检', () {
    late SqlTokenPredictor predictor;

    setUpAll(() {
      predictor = loadBundledCheckpoint().toPredictor(dialect: DialectType.mysql);
    });

    for (final c in _probeCases) {
      test('${c.name}: top-5 命中期望', () {
        final tokens =
            predictor.predict(c.prefix, topK: 5).map((e) => e.token).toSet();
        expect(
          tokens.intersection(c.expect),
          isNotEmpty,
          reason: 'prefix=${c.prefix} expect=${c.expect.join("|")} got=$tokens',
        );
      });
    }
  });
}

final _probeCases = <({String name, String prefix, Set<String> expect})>[
  (name: 'SELECT 后', prefix: 'SELECT', expect: {'<COLUMN>', '<OBJ>', '*', 'distinct'}),
  (name: 'SELECT 列后', prefix: 'SELECT name', expect: {'from', ',', 'as'}),
  (name: 'FROM 后', prefix: 'SELECT name FROM', expect: {'<TABLE>', '<OBJ>'}),
  (
    name: '表名后(空格)',
    prefix: 'select cat_id from t_sales ',
    expect: {'where', 'group', 'order', 'limit', 'join', 'inner', 'as', ';'},
  ),
  (
    name: '表名后(无空格)',
    prefix: 'select cat_id from t_sales',
    expect: {'where', 'group', 'order', 'limit', 'join', 'inner', 'as', ';'},
  ),
  (name: '子查询 FROM (', prefix: 'SELECT * FROM (', expect: {'select'}),
  // 预置模型在 DDL/DML 表位更常出 <TABLE> 而非泛化 <OBJ>
  (name: 'INSERT INTO', prefix: 'INSERT INTO', expect: {'<TABLE>', '<OBJ>'}),
  (name: 'UPDATE', prefix: 'UPDATE', expect: {'<TABLE>', '<OBJ>'}),
  (name: 'DELETE FROM', prefix: 'DELETE FROM', expect: {'<TABLE>', '<OBJ>'}),
  (
    name: 'WHERE 后',
    prefix: 'select cat_id from t_sales where',
    expect: {'<COLUMN>', '<OBJ>'},
  ),
  (name: 'JOIN 后', prefix: 'select a from t1 join', expect: {'<TABLE>', '<OBJ>'}),
  (name: 'SET 后', prefix: 'update t_sales set', expect: {'<COLUMN>', '<OBJ>'}),
  (
    name: 'GRANT',
    prefix: 'GRANT',
    expect: {'select', 'insert', 'update', 'delete', 'all', '<OBJ>'},
  ),
  (name: 'USE', prefix: 'USE', expect: {'<OBJ>', 'database'}),
  // ORDER/GROUP BY 后模型常直接出列名 token，而非占位符
  (
    name: 'ORDER BY',
    prefix: 'select a from t order by',
    expect: {'<OBJ>', '<COLUMN>', 'year', 'name', 'date', 'current_date', 'case'},
  ),
  (
    name: 'GROUP BY',
    prefix: 'select a from t group by',
    expect: {'<OBJ>', '<COLUMN>', 'year', 'name', 'date', 'current_date', 'case'},
  ),
];

Future<Checkpoint> _tinyCheckpoint() async {
  final samples = [
    for (final table in ['users', 'orders', 't'])
      sampleWithSpans(
        'SELECT id FROM $table',
        const [SqlCompleteKind.column, SqlCompleteKind.table],
      ),
    for (final table in ['users', 'orders'])
      sampleWithSpans(
        'SELECT name FROM $table',
        const [SqlCompleteKind.column, SqlCompleteKind.table],
      ),
  ];
  final trainer = SqlTokenTrainer(
    config: const TrainConfig(
      epochs: 20,
      learningRate: 1e-2,
      embedDim: 16,
      hiddenDim: 16,
      numLayers: 1,
      logEvery: 0,
      shuffle: true,
      seed: 3,
      valRatio: 0,
      prefixStride: 1,
    ),
  );
  return trainer.fit(samples);
}
