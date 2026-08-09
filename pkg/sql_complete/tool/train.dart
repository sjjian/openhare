import 'dart:io';

import 'package:sql_complete/training.dart';

import 'export.dart';

/// 使用混合语料训练下一词元模型。
///
/// 只读 `data/trainset`（由 `tool/build_trainset.py` 生成）。
///
/// ```bash
/// .venv/bin/python tool/build_trainset.py --download
/// dart run tool/train.dart --full --epochs=3   # 默认 --export，写入库内权重
/// dart run tool/train.dart --full --no-export  # 只写 out/
/// ```
Future<void> main(List<String> args) async {
  final full = args.contains('--full');
  final export = args.contains('--export') ||
      (full && !args.contains('--no-export'));
  final maxSamples = full ? null : _argInt(args, 'max', 3000);
  final epochs = _argInt(args, 'epochs', full ? 3 : 2);

  final sw = Stopwatch()..start();
  final samples = await _loadSamples(maxSamples);
  stdout.writeln('loaded ${samples.length} SQL samples in ${sw.elapsed}');
  if (samples.isNotEmpty) {
    stdout.writeln('example: ${samples.first.sql}');
  }

  final trainer = SqlTokenTrainer(
    config: TrainConfig(
      epochs: epochs,
      learningRate: full ? 1e-3 : 3e-3,
      embedDim: 32,
      hiddenDim: 32,
      numLayers: 2,
      maxVocab: 256,
      minFreq: 1,
      maxPrefixLen: 32,
      prefixStride: full ? 2 : 1,
      logEvery: full ? 5000 : 500,
      dialect: DialectType.mysql,
      onlySuggestTargets: true,
      valRatio: _argDouble(args, 'val', 0.1),
      maxValSamples: full ? 3000 : 500,
    ),
    extractor: const TokenExtractor(
      dialect: DialectType.mysql,
      collapseObjects: true,
    ),
    onLog: stdout.writeln,
  );

  stdout.writeln(
    'model: attn embed=32 hidden=32 layers=2 '
    'input=<OBJ> output=<TABLE>/<COLUMN>/… prefixStride=${full ? 2 : 1} '
    'valRatio=${_argDouble(args, 'val', 0.1)}',
  );

  final ckpt = await trainer.fit(samples);
  await Directory('out').create(recursive: true);
  await ckpt.save('out/trainset_model.checkpoint.json');
  stdout.writeln('checkpoint saved -> out/trainset_model.checkpoint.json');
  if (ckpt.meta['bestValAcc'] != null) {
    stdout.writeln(
      'best epoch=${ckpt.meta['bestEpoch']} '
      'val_acc=${((ckpt.meta['bestValAcc'] as num) * 100).toStringAsFixed(2)}%',
    );
  }

  if (export) {
    final outPath = _firstExisting([
          defaultBundledCheckpointDataPath,
          'pkg/sql_complete/$defaultBundledCheckpointDataPath',
        ]) ??
        defaultBundledCheckpointDataPath;
    final file = await exportBundledCheckpointData(ckpt, path: outPath);
    stdout.writeln(
      'bundled data -> ${file.path} (${await file.length()} bytes)',
    );
  } else {
    stdout.writeln('skip bundled export (pass --export, or --full without --no-export)');
  }

  stdout.writeln('total elapsed: ${sw.elapsed}');
  stdout.writeln('vocab(${ckpt.vocab.size}): ${ckpt.vocab.idToToken}');

  final predictor = ckpt.toPredictor(dialect: DialectType.mysql);

  for (final prefix in [
    'SELECT',
    'SELECT name FROM',
    'SELECT * FROM (',
    'INSERT INTO',
    'UPDATE',
    'CREATE TABLE',
    'GRANT',
    'USE',
  ]) {
    final preds = predictor.predict(prefix, topK: 5);
    stdout.writeln('prefix: $prefix -> $preds');
  }
}

Future<List<SqlSample>> _loadSamples(int? maxSamples) async {
  const loader = TrainsetLoader();
  final trainsetJsonl = _firstExisting([
    'data/trainset/sqls.jsonl',
    'pkg/sql_complete/data/trainset/sqls.jsonl',
  ]);
  if (trainsetJsonl != null) {
    stdout.writeln('loading trainset jsonl: $trainsetJsonl ...');
    return loader.loadJsonl(trainsetJsonl, maxSamples: maxSamples);
  }

  final trainsetTxt = _firstExisting([
    'data/trainset/sqls.txt',
    'pkg/sql_complete/data/trainset/sqls.txt',
  ]);
  if (trainsetTxt != null) {
    stdout.writeln('loading trainset txt (no spans): $trainsetTxt ...');
    return loader.loadTxt(trainsetTxt, maxSamples: maxSamples);
  }

  stderr.writeln(
    'No training data. Build trainset first:\n'
    '  .venv/bin/python tool/build_trainset.py --download',
  );
  exit(1);
}

String? _firstExisting(List<String> paths) {
  for (final p in paths) {
    if (File(p).existsSync() || Directory(p).existsSync()) return p;
  }
  return null;
}

int _argInt(List<String> args, String name, int fallback) {
  for (final a in args) {
    if (a.startsWith('--$name=')) {
      return int.tryParse(a.substring(name.length + 3)) ?? fallback;
    }
  }
  return fallback;
}

double _argDouble(List<String> args, String name, double fallback) {
  for (final a in args) {
    if (a.startsWith('--$name=')) {
      return double.tryParse(a.substring(name.length + 3)) ?? fallback;
    }
  }
  return fallback;
}
