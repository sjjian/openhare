import 'package:sql_complete/training.dart';
import 'package:test/test.dart';

import 'sample_spans.dart';

void main() {
  test('token model predicts typed object placeholders from objectSpans', () async {
    final samples = [
      sampleWithSpans('SELECT id FROM users WHERE age > 18', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
        SqlCompleteKind.column,
      ]),
      sampleWithSpans('SELECT name FROM users WHERE age > 20', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
        SqlCompleteKind.column,
      ]),
      sampleWithSpans('SELECT id FROM users WHERE id = 1', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
        SqlCompleteKind.column,
      ]),
      sampleWithSpans('SELECT name FROM users ORDER BY name', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
        SqlCompleteKind.column,
      ]),
      sampleWithSpans(
        'SELECT COUNT(*) FROM users',
        const [SqlCompleteKind.table],
      ),
    ];

    final trainer = SqlTokenTrainer(
      config: const TrainConfig(
        epochs: 12,
        learningRate: 1e-2,
        embedDim: 16,
        hiddenDim: 16,
        numLayers: 1,
        logEvery: 0,
        shuffle: true,
        seed: 7,
        valRatio: 0,
      ),
    );

    final ckpt = await trainer.fit(samples);
    expect(ckpt.vocab.idToToken, containsAll(['<OBJ>', '<TABLE>', '<COLUMN>']));

    final predictor = ckpt.toPredictor();
    final afterFrom = predictor.predict('SELECT id FROM', topK: 5);
    expect(afterFrom.any((p) => p.token == '<TABLE>' || p.token == '<OBJ>'), isTrue);

    final afterSelect = predictor.predict('SELECT', topK: 5);
    expect(
      afterSelect.any((p) =>
          p.token == '<COLUMN>' || p.token == '<OBJ>' || p.token == '*'),
      isTrue,
    );
  });

  test('checkpoint roundtrip', () async {
    final samples = [
      sampleWithSpans('SELECT a FROM t', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
      ]),
      sampleWithSpans('SELECT b FROM t', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
      ]),
    ];
    final trainer = SqlTokenTrainer(
      config: const TrainConfig(
        epochs: 1,
        embedDim: 8,
        hiddenDim: 8,
        numLayers: 1,
        logEvery: 0,
        valRatio: 0,
      ),
    );
    final ckpt = await trainer.fit(samples);
    final restored = Checkpoint.fromJson(ckpt.toJson());
    expect(restored.vocab.size, ckpt.vocab.size);
    expect(restored.tokenKinds.containsKey('<TABLE>'), isTrue);
    expect(restored.tokenKinds.containsKey('<COLUMN>'), isTrue);
  });

  test('checkpoint rejects vocabSize mismatch', () async {
    final samples = [
      sampleWithSpans('SELECT a FROM t', const [
        SqlCompleteKind.column,
        SqlCompleteKind.table,
      ]),
    ];
    final trainer = SqlTokenTrainer(
      config: const TrainConfig(
        epochs: 1,
        embedDim: 8,
        hiddenDim: 8,
        numLayers: 1,
        logEvery: 0,
        valRatio: 0,
      ),
    );
    final ckpt = await trainer.fit(samples);
    final json = ckpt.toJson();
    (json['model'] as Map)['config'] =
        Map<String, dynamic>.from(json['model']['config'] as Map)
          ..['vocabSize'] = (json['model']['config']['vocabSize'] as int) + 1;
    expect(
      () => Checkpoint.fromJson(json),
      throwsA(isA<StateError>()),
    );
  });

  test('maxVocab 仍保留语料中的关键字', () {
    final samples = [
      for (final kw in ['SELECT', 'GRANT', 'REVOKE', 'TRUNCATE', 'DESCRIBE'])
        sampleWithSpans('$kw x FROM t', const [SqlCompleteKind.table]),
    ];
    final trainer = SqlTokenTrainer(
      config: const TrainConfig(
        epochs: 1,
        embedDim: 8,
        hiddenDim: 8,
        numLayers: 1,
        maxVocab: 12,
        logEvery: 0,
        valRatio: 0,
      ),
    );
    final (vocab, _) = trainer.prepare(samples);
    for (final kw in ['select', 'grant', 'revoke', 'truncate', 'describe']) {
      expect(vocab.tokenToId.containsKey(kw), isTrue, reason: kw);
      expect(vocab.encodeToken(kw), isNot(vocab.unkId));
    }
  });

  test('fit keeps best by val accuracy', () async {
    final samples = [
      for (var i = 0; i < 20; i++)
        sampleWithSpans(
          'SELECT col_$i FROM t$i WHERE id = $i',
          const [
            SqlCompleteKind.column,
            SqlCompleteKind.table,
            SqlCompleteKind.column,
          ],
        ),
      for (var i = 0; i < 20; i++)
        sampleWithSpans(
          'UPDATE t$i SET name = $i WHERE id = $i',
          const [
            SqlCompleteKind.table,
            SqlCompleteKind.column,
            SqlCompleteKind.column,
          ],
        ),
    ];
    final trainer = SqlTokenTrainer(
      config: const TrainConfig(
        epochs: 3,
        learningRate: 1e-2,
        embedDim: 16,
        hiddenDim: 16,
        numLayers: 1,
        logEvery: 0,
        valRatio: 0.25,
        maxValSamples: 20,
        seed: 3,
      ),
    );
    final ckpt = await trainer.fit(samples);
    expect(ckpt.meta['bestValAcc'], isNotNull);
    expect((ckpt.meta['bestValAcc'] as num) >= 0, isTrue);
  });
}
