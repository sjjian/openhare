import 'dart:convert';
import 'dart:io';

import 'package:sql_complete/training.dart';
import 'package:test/test.dart';

import 'sample_spans.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('sql_complete_loader_');
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('TrainsetLoader 读 jsonl', () async {
    final path = '${tmp.path}/samples.jsonl';
    File(path).writeAsStringSync([
      // 闭区间 [start, end]（id=7..8, users=15..19, age=27..29）
      _jsonlRow('SELECT id FROM users WHERE age > 1', [
        {'start': 7, 'end': 8, 'role': 'column'},
        {'start': 15, 'end': 19, 'role': 'table'},
        {'start': 27, 'end': 29, 'role': 'column'},
      ]),
      _jsonlRow('SELECT name FROM orders', [
        {'start': 7, 'end': 10, 'role': 'column'},
        {'start': 17, 'end': 22, 'role': 'table'},
      ]),
      _jsonlRow("INSERT INTO users (name) VALUES ('a')", [
        {'start': 12, 'end': 16, 'role': 'table'},
        {'start': 19, 'end': 22, 'role': 'column'},
      ]),
    ].join('\n'));

    final samples = await const TrainsetLoader().loadJsonl(path);
    expect(samples, hasLength(3));
    expect(samples.first.sql.toLowerCase(), contains('select'));
    expect(samples.first.objectSpans, isNotEmpty);
    expect(
      samples.first.objectSpans.any((s) => s.role == SqlCompleteKind.table),
      isTrue,
    );
    expect(samples.first.objectSpans.first.end, 8);
  });

  test('TrainsetLoader 读 txt', () async {
    final path = '${tmp.path}/samples.txt';
    File(path).writeAsStringSync(
      'SELECT id FROM users;\n'
      'SELECT COUNT(*) FROM orders;\n'
      "INSERT INTO users (name) VALUES ('a');\n"
      "UPDATE users SET name = 'b' WHERE id = 1;\n"
      'DELETE FROM sessions WHERE expired = 1;\n',
    );

    final samples = await const TrainsetLoader().loadTxt(path);
    expect(samples, hasLength(5));
    expect(samples.first.sql.toLowerCase(), contains('select'));
  });

  test('TrainsetLoader maxSamples 截断', () async {
    final path = '${tmp.path}/samples.jsonl';
    File(path).writeAsStringSync([
      _jsonlRow('SELECT 1', const []),
      _jsonlRow('SELECT 2', const []),
      _jsonlRow('SELECT 3', const []),
    ].join('\n'));
    final samples =
        await const TrainsetLoader().loadJsonl(path, maxSamples: 2);
    expect(samples, hasLength(2));
  });

  test('SqlSample.fromJson / toJson 往返', () {
    final sample = SqlSample(
      sql: 'SELECT id FROM t',
      source: 'test',
      objectSpans: [
        ObjectRoleSpan(start: 7, end: 8, role: SqlCompleteKind.column),
        ObjectRoleSpan(start: 15, end: 15, role: SqlCompleteKind.table),
      ],
    );
    final round = SqlSample.fromJson(sample.toJson());
    expect(round.sql, sample.sql);
    expect(round.source, sample.source);
    expect(round.objectSpans.map((s) => s.role), [
      SqlCompleteKind.column,
      SqlCompleteKind.table,
    ]);
    expect(round.objectSpans.map((s) => (s.start, s.end)).toList(), [
      (7, 8),
      (15, 15),
    ]);
  });

  group('ObjectRoleSpan 闭区间契约', () {
    test('contains：含首尾，不含 end+1', () {
      final span = ObjectRoleSpan(
        start: 7,
        end: 8,
        role: SqlCompleteKind.column,
      );
      expect(span.contains(6), isFalse);
      expect(span.contains(7), isTrue);
      expect(span.contains(8), isTrue);
      expect(span.contains(9), isFalse);
    });

    test('fromStartLength：end = start + length - 1', () {
      final span = ObjectRoleSpan.fromStartLength(
        start: 7,
        length: 2,
        role: SqlCompleteKind.column,
      );
      expect(span.start, 7);
      expect(span.end, 8);
      expect(span.contains(8), isTrue);
      expect(span.contains(9), isFalse);
    });

    test('闭区间 span 附着后目标含 TABLE/COLUMN', () {
      final samples = [
        sampleWithSpans(
          'SELECT id FROM users WHERE age > 1',
          const [
            SqlCompleteKind.column,
            SqlCompleteKind.table,
            SqlCompleteKind.column,
          ],
          source: 'test',
        ),
      ];
      expect(samples.first.objectSpans.map((s) => (s.start, s.end)).toList(), [
        (7, 8),
        (15, 19),
        (27, 29),
      ]);

      final trainer = SqlTokenTrainer(
        config: const TrainConfig(
          epochs: 1,
          embedDim: 8,
          hiddenDim: 8,
          numLayers: 1,
          logEvery: 0,
          valRatio: 0,
          seed: 1,
        ),
      );
      final (vocab, examples) = trainer.prepare(samples);
      expect(vocab.idToToken, containsAll(['<OBJ>', '<TABLE>', '<COLUMN>']));
      expect(
        examples.any((e) => e.targetKind == SqlCompleteKind.table),
        isTrue,
      );
      expect(
        examples.any((e) => e.targetKind == SqlCompleteKind.column),
        isTrue,
      );
    });
  });
}

String _jsonlRow(String sql, List<Map<String, Object>> spans) {
  return jsonEncode({
    'sql': sql,
    'source': 'test',
    'object_spans': spans,
  });
}
