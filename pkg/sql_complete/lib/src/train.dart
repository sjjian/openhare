import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:sql_parser/parser.dart';

import 'checkpoint.dart';
import 'dataset.dart';
import 'nn.dart';
import 'tokenize.dart';

/// 从磁盘读取 checkpoint（训练 / tool 侧；运行时用 [loadBundledCheckpoint]）。
Future<Checkpoint> loadCheckpoint(String path) async {
  final raw = await File(path).readAsString();
  return Checkpoint.fromJsonString(raw);
}

extension CheckpointFileIo on Checkpoint {
  /// [fractionDigits] 截断权重小数位；训练产物默认全精度，导出预置模型时再截断。
  Future<void> save(
    String path, {
    bool indent = true,
    int? fractionDigits,
  }) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final encoder =
        indent ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    final Object json = fractionDigits == null
        ? toJson()
        : jsonDecode(toCompactJson(fractionDigits: fractionDigits));
    await file.writeAsString(encoder.convert(json));
  }
}

class TrainConfig {
  final int epochs;
  final double learningRate;
  final int embedDim;
  final int hiddenDim;
  final int numLayers;
  final int minFreq;
  final int? maxVocab;
  final int maxPrefixLen;
  /// 前缀采样步长：1=每个位置，2=隔一个取一个（样本约减半）。
  final int prefixStride;
  /// 只训练关键字/对象目标。
  final bool onlySuggestTargets;
  final int seed;
  final DialectType dialect;
  final bool shuffle;
  final int logEvery;

  /// 从训练样本中划出验证集比例；0 表示不划。显式传入 [SqlTokenTrainer.fit] 的 valSamples 时优先生效。
  final double valRatio;

  /// 验证集最多评估多少条 SQL（加速）；null 表示全部。
  final int? maxValSamples;

  /// 验证时前缀步长，默认与 [prefixStride] 相同。
  final int? evalPrefixStride;

  const TrainConfig({
    this.epochs = 3,
    this.learningRate = 1e-3,
    this.embedDim = 32,
    this.hiddenDim = 32,
    this.numLayers = 1,
    this.minFreq = 1,
    this.maxVocab,
    this.maxPrefixLen = 64,
    this.prefixStride = 1,
    this.onlySuggestTargets = true,
    this.seed = 42,
    this.dialect = DialectType.mysql,
    this.shuffle = true,
    this.logEvery = 200,
    this.valRatio = 0.1,
    this.maxValSamples = 3000,
    this.evalPrefixStride,
  });
}

class TrainStats {
  final int epoch;
  final double loss;
  final double accuracy;
  final int examples;
  final double? valAccuracy;
  final int? valExamples;

  const TrainStats({
    required this.epoch,
    required this.loss,
    required this.accuracy,
    required this.examples,
    this.valAccuracy,
    this.valExamples,
  });

  @override
  String toString() {
    final val = valAccuracy == null
        ? ''
        : ' val_acc=${(valAccuracy! * 100).toStringAsFixed(2)}%'
            '${valExamples == null ? '' : ' val_n=$valExamples'}';
    return 'epoch=$epoch loss=${loss.toStringAsFixed(4)} '
        'acc=${(accuracy * 100).toStringAsFixed(2)}% n=$examples$val';
  }
}

/// 基于开源 SQL 语料的下一词元 训练器。
class SqlTokenTrainer {
  final TrainConfig config;
  final TokenExtractor extractor;
  final void Function(String message)? onLog;

  Vocabulary? vocab;
  SqlTokenModel? model;
  Set<int> targetIds = {};
  Map<String, SqlCompleteKind> tokenKinds = {};

  SqlTokenTrainer({
    this.config = const TrainConfig(),
    TokenExtractor? extractor,
    this.onLog,
  }) : extractor = extractor ??
            TokenExtractor(dialect: config.dialect, collapseObjects: true);

  void _log(String msg) => onLog?.call(msg);

  /// 从样本构建词表与下一词元例子。
  ///
  /// 输入前缀：Dart 切词，对象折叠为 `<OBJ>`。
  /// 输出目标：sqlglot [ObjectRoleSpan] 按源码位置附着；
  /// 命中则 `<TABLE>`/`<COLUMN>`/…，未命中则 `<OBJ>`。
  (Vocabulary, List<NextTokenExample>) prepare(List<SqlSample> samples) {
    final rawExtractor = TokenExtractor(
      dialect: config.dialect,
      collapseObjects: false,
    );
    final collapsedSequences = <List<ModelToken>>[];
    final rawSequences = <List<ModelToken>>[];
    final keptSamples = <SqlSample>[];
    final sqls = <String>[];

    for (final s in samples) {
      final raw = rawExtractor.extract(s.sql);
      if (raw.length < 2) continue;
      final collapsed = [
        for (final t in raw) TokenExtractor.collapseObjectForInput(t),
      ];
      rawSequences.add(raw);
      collapsedSequences.add(collapsed);
      keptSamples.add(s);
      sqls.add(s.sql);
    }

    final vocab = Vocabulary.fromTokenSequences(
      collapsedSequences,
      minFreq: config.minFreq,
      maxSize: config.maxVocab,
    );
    for (final p in TokenExtractor.objectPlaceholders) {
      vocab.ensureToken(p);
    }
    // 关键字强制进词表，避免 encode→<UNK> 后被推理过滤。
    for (final seq in collapsedSequences) {
      for (final t in seq) {
        if (t.kind == SqlCompleteKind.keyword) {
          vocab.ensureToken(t.normalized);
        }
      }
    }

    final kinds = <String, SqlCompleteKind>{
      for (final p in TokenExtractor.objectPlaceholders)
        p: TokenExtractor.kindOfObjectPlaceholder(p) ?? SqlCompleteKind.object,
    };
    final targets = <int>{};
    final stride = math.max(1, config.prefixStride);
    final examples = <NextTokenExample>[];
    final bosId = vocab.encodeToken(Vocabulary.bos);
    final unkId = vocab.unkId;
    const bosToken = ModelToken(
      type: TokenType.keyword,
      surface: Vocabulary.bos,
      normalized: Vocabulary.bos,
      kind: SqlCompleteKind.keyword,
    );

    for (var si = 0; si < collapsedSequences.length; si++) {
      final collapsed = collapsedSequences[si];
      final raw = rawSequences[si];
      final ids = vocab.encode(collapsed);
      final sql = sqls[si];
      final kindByIndex = _objectKindByTokenIndex(raw, keptSamples[si]);
      final limit = math.min(collapsed.length, config.maxPrefixLen + 1);
      // i=0：空前缀用 BOS → 预测首词。
      for (var i = 0; i < limit; i++) {
        final rawTarget = raw[i];
        if (!_keepSuggestPosition(
          rawTarget,
          index: i,
          stride: stride,
          onlySuggestTargets: config.onlySuggestTargets,
        )) {
          continue;
        }
        if (rawTarget.kind == null) continue;
        final resolved = _resolveSuggestTarget(
          rawTarget: rawTarget,
          collapsedToken: collapsed[i],
          objectKind: kindByIndex[i],
        );
        final targetId = vocab.encodeToken(resolved.token);
        // 目标为 <UNK> 则跳过。
        if (targetId == unkId) continue;
        kinds[resolved.token] = resolved.kind;
        targets.add(targetId);
        examples.add(NextTokenExample(
          prefixIds: i == 0 ? [bosId] : ids.sublist(0, i),
          prefixTokens: i == 0 ? const [bosToken] : collapsed.sublist(0, i),
          targetId: targetId,
          targetKind: resolved.kind,
          sql: sql,
        ));
      }
    }

    for (final seq in collapsedSequences) {
      for (final t in seq) {
        if (t.kind != SqlCompleteKind.keyword) continue;
        final id = vocab.encodeToken(t.normalized);
        if (id == unkId) continue;
        targets.add(id);
        kinds.putIfAbsent(t.normalized, () => SqlCompleteKind.keyword);
      }
    }
    for (final p in TokenExtractor.objectPlaceholders) {
      targets.add(vocab.encodeToken(p));
    }

    this.vocab = vocab;
    targetIds = targets;
    tokenKinds = kinds;
    _log(
      'vocab=${vocab.size} sequences=${collapsedSequences.length} '
      'examples=${examples.length} targets=${targets.length} '
      '(suggest targets only=${config.onlySuggestTargets}; '
      'output=<TABLE>/<COLUMN>/… via objectSpans)',
    );
    return (vocab, examples);
  }

  /// 将 span 附着到 object 词元：start 落在 span 内则用其角色，否则 `<OBJ>`。
  Map<int, SqlCompleteKind> _objectKindByTokenIndex(
    List<ModelToken> raw,
    SqlSample sample,
  ) {
    final spans = sample.objectSpans;
    final out = <int, SqlCompleteKind>{};
    for (var i = 0; i < raw.length; i++) {
      final k = raw[i].kind;
      if (k == null || k == SqlCompleteKind.keyword) continue;
      final start = raw[i].start;
      if (start == null || spans.isEmpty) {
        out[i] = SqlCompleteKind.object;
        continue;
      }
      ObjectRoleSpan? hit;
      for (final s in spans) {
        if (s.contains(start)) {
          hit = s;
          break;
        }
      }
      // 未命中 span → <OBJ>。
      out[i] = hit?.role ?? SqlCompleteKind.object;
    }
    return out;
  }

  /// 关键字 → 原文；对象 → span 角色对应占位符。
  static ({String token, SqlCompleteKind kind}) _resolveSuggestTarget({
    required ModelToken rawTarget,
    required ModelToken collapsedToken,
    required SqlCompleteKind? objectKind,
  }) {
    if (rawTarget.kind == SqlCompleteKind.keyword) {
      return (token: collapsedToken.normalized, kind: SqlCompleteKind.keyword);
    }
    final kind = objectKind ?? SqlCompleteKind.object;
    return (
      token: TokenExtractor.outputPlaceholderFor(kind),
      kind: kind,
    );
  }

  /// 在 [targetIds] 上取 logits 最大者；集合为空则扫全词表。
  static int _argmaxOverTargets(Tensor logits, Set<int> targets) {
    var bestId = -1;
    var bestScore = -double.infinity;
    if (targets.isNotEmpty) {
      for (final id in targets) {
        if (id < 0 || id >= logits.cols) continue;
        final s = logits.data[id];
        if (s > bestScore) {
          bestScore = s;
          bestId = id;
        }
      }
    } else {
      for (var i = 0; i < logits.cols; i++) {
        final s = logits.data[i];
        if (s > bestScore) {
          bestScore = s;
          bestId = i;
        }
      }
    }
    return bestId;
  }

  /// 训练并返回检查点；若有验证集则返回 **val 最优** 权重。
  ///
  /// [valSamples] 优先；否则按 [TrainConfig.valRatio] 从 [samples] 划出。
  Future<Checkpoint> fit(
    List<SqlSample> samples, {
    List<SqlSample>? valSamples,
  }) async {
    var trainSamples = samples;
    var evalSamples = valSamples;
    if (evalSamples == null && config.valRatio > 0 && samples.length >= 5) {
      final split = splitTrainVal(
        samples,
        valRatio: config.valRatio,
        seed: config.seed,
      );
      trainSamples = split.$1;
      evalSamples = split.$2;
      _log(
        'split train=${trainSamples.length} val=${evalSamples.length} '
        '(ratio=${config.valRatio})',
      );
    }

    final (vocab, examples) = prepare(trainSamples);
    if (examples.isEmpty) {
      throw StateError('No training examples produced from samples');
    }

    final model = SqlTokenModel(
      ModelConfig(
        vocabSize: vocab.size,
        embedDim: config.embedDim,
        hiddenDim: config.hiddenDim,
        numLayers: config.numLayers,
        seed: config.seed,
        maxPosLen: config.maxPrefixLen,
      ),
    );
    this.model = model;

    final opt = AdamOptimizer(lr: config.learningRate);
    final rng = math.Random(config.seed);
    final order = List<int>.generate(examples.length, (i) => i);

    Checkpoint? bestCkpt;
    var bestValAcc = -1.0;
    var bestEpoch = 0;

    for (var epoch = 1; epoch <= config.epochs; epoch++) {
      if (config.shuffle) order.shuffle(rng);
      var lossSum = 0.0;
      var correct = 0;
      var count = 0;

      for (var step = 0; step < order.length; step++) {
        final ex = examples[order[step]];

        model.zeroGrad();
        final fwd = model.forward(ex.prefixIds);
        final loss = model.backward(fwd, ex.targetId);
        model.backwardGraph();
        opt.step(model.parameters);

        lossSum += loss;
        count += 1;

        final bestId = _argmaxOverTargets(fwd.logits, targetIds);
        if (bestId == ex.targetId) correct += 1;

        if (config.logEvery > 0 && step > 0 && step % config.logEvery == 0) {
          _log(
            'epoch=$epoch step=$step/'
            '${examples.length} loss=${(lossSum / count).toStringAsFixed(4)} '
            'acc=${(correct / count * 100).toStringAsFixed(2)}%',
          );
        }
      }

      double? valAcc;
      int? valN;
      if (evalSamples != null && evalSamples.isNotEmpty) {
        final ev = evaluateDetailed(
          evalSamples,
          maxSamples: config.maxValSamples,
          prefixStride: config.evalPrefixStride ?? config.prefixStride,
        );
        valAcc = ev.$1;
        valN = ev.$2;
        if (valAcc > bestValAcc) {
          bestValAcc = valAcc;
          bestEpoch = epoch;
          bestCkpt = _snapshotCheckpoint(
            model: model,
            vocab: vocab,
            trainSamples: trainSamples.length,
            examples: examples.length,
            valAcc: valAcc,
            valExamples: valN,
            bestEpoch: epoch,
          );
          _log(
            '★ new best val_acc=${(bestValAcc * 100).toStringAsFixed(2)}% '
            'at epoch=$epoch',
          );
        }
      }

      final stats = TrainStats(
        epoch: epoch,
        loss: lossSum / count,
        accuracy: correct / count,
        examples: count,
        valAccuracy: valAcc,
        valExamples: valN,
      );
      _log(stats.toString());
    }

    if (bestCkpt != null) {
      this.model = bestCkpt.model;
      _log(
        'restore best checkpoint epoch=$bestEpoch '
        'val_acc=${(bestValAcc * 100).toStringAsFixed(2)}%',
      );
      return bestCkpt;
    }

    return _snapshotCheckpoint(
      model: model,
      vocab: vocab,
      trainSamples: trainSamples.length,
      examples: examples.length,
    );
  }

  Checkpoint _snapshotCheckpoint({
    required SqlTokenModel model,
    required Vocabulary vocab,
    required int trainSamples,
    required int examples,
    double? valAcc,
    int? valExamples,
    int? bestEpoch,
  }) {
    return Checkpoint(
      model: SqlTokenModel.fromJson(model.toJson()),
      vocab: vocab,
      targetIds: targetIds,
      tokenKinds: tokenKinds,
      meta: {
        'epochs': config.epochs,
        'embedDim': config.embedDim,
        'hiddenDim': config.hiddenDim,
        'numLayers': config.numLayers,
        'dialect': config.dialect.name,
        'samples': trainSamples,
        'examples': examples,
        'onlySuggestTargets': config.onlySuggestTargets,
        'valRatio': config.valRatio,
        if (valAcc != null) 'bestValAcc': valAcc,
        if (valExamples != null) 'valExamples': valExamples,
        if (bestEpoch != null) 'bestEpoch': bestEpoch,
      },
    );
  }

  /// 按比例划分 train / val（可复现）。
  static (List<SqlSample>, List<SqlSample>) splitTrainVal(
    List<SqlSample> samples, {
    double valRatio = 0.1,
    int seed = 42,
  }) {
    if (samples.isEmpty) return (const [], const []);
    final ratio = valRatio.clamp(0.0, 0.5);
    if (ratio <= 0) return (List<SqlSample>.from(samples), const []);

    final rng = math.Random(seed);
    final order = List<int>.generate(samples.length, (i) => i)..shuffle(rng);
    var nVal = (samples.length * ratio).round();
    if (nVal < 1) nVal = 1;
    if (nVal >= samples.length) nVal = samples.length - 1;

    final val = <SqlSample>[];
    final train = <SqlSample>[];
    for (var i = 0; i < order.length; i++) {
      final s = samples[order[i]];
      if (i < nVal) {
        val.add(s);
      } else {
        train.add(s);
      }
    }
    return (train, val);
  }

  /// 返回 `(accuracy, evaluatedTargetCount)`。
  (double, int) evaluateDetailed(
    List<SqlSample> samples, {
    int? maxSamples,
    int? prefixStride,
  }) {
    final model = this.model;
    final vocab = this.vocab;
    if (model == null || vocab == null) {
      throw StateError('Call fit() before evaluate()');
    }

    var list = samples;
    final cap = maxSamples;
    if (cap != null && list.length > cap) {
      final rng = math.Random(config.seed ^ 0x9e3779b9);
      final order = List<int>.generate(list.length, (i) => i)..shuffle(rng);
      list = [for (var i = 0; i < cap; i++) samples[order[i]]];
    }

    final rawExtractor = TokenExtractor(
      dialect: config.dialect,
      collapseObjects: false,
    );
    final stride = math.max(1, prefixStride ?? config.prefixStride);
    final bosId = vocab.encodeToken(Vocabulary.bos);
    var correct = 0;
    var total = 0;
    for (final s in list) {
      final raw = rawExtractor.extract(s.sql);
      if (raw.length < 2) continue;
      final collapsed = [
        for (final t in raw) TokenExtractor.collapseObjectForInput(t),
      ];
      final ids = vocab.encode(collapsed);
      final kindByIndex = _objectKindByTokenIndex(raw, s);
      final limit = math.min(collapsed.length, config.maxPrefixLen + 1);
      for (var i = 0; i < limit; i++) {
        final rawTarget = raw[i];
        if (!_keepSuggestPosition(
          rawTarget,
          index: i,
          stride: stride,
          onlySuggestTargets: config.onlySuggestTargets,
        )) {
          continue;
        }
        if (rawTarget.kind == null) continue;
        final resolved = _resolveSuggestTarget(
          rawTarget: rawTarget,
          collapsedToken: collapsed[i],
          objectKind: kindByIndex[i],
        );
        final targetId = vocab.encodeToken(resolved.token);
        if (targetId == vocab.unkId) continue;
        final fwd = model.forward(i == 0 ? [bosId] : ids.sublist(0, i));
        final bestId = _argmaxOverTargets(fwd.logits, targetIds);
        if (bestId == targetId) correct += 1;
        total += 1;
      }
    }
    return (total == 0 ? 0.0 : correct / total, total);
  }

  /// stride 只抽稀 object；关键字一律保留。
  static bool _keepSuggestPosition(
    ModelToken target, {
    required int index,
    required int stride,
    required bool onlySuggestTargets,
  }) {
    if (onlySuggestTargets && !target.isPredictTarget) return false;
    switch (target.kind) {
      case SqlCompleteKind.keyword:
        return true;
      case SqlCompleteKind.object:
      case SqlCompleteKind.database:
      case SqlCompleteKind.table:
      case SqlCompleteKind.column:
      case SqlCompleteKind.alias:
      case null:
        return index % stride == 0;
    }
  }
}
