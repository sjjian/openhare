import 'dart:convert';

import 'package:sql_parser/parser.dart';

import 'bundled_checkpoint_data.dart';
import 'nn.dart';
import 'tokenize.dart';

/// 模型 + 词表检查点（无 `dart:io`）。
///
/// 磁盘读写见 `train.dart` 的 [loadCheckpoint] / [CheckpointFileIo.save]。
/// 包内预置权重见 [loadBundledCheckpoint] / [tryLoadBundledCheckpoint]。
class Checkpoint {
  final SqlTokenModel model;
  final Vocabulary vocab;
  final Map<String, dynamic> meta;

  /// 可预测目标 token id（关键字/对象）。
  final Set<int> targetIds;

  /// token -> 建议类型。
  final Map<String, SqlCompleteKind> tokenKinds;

  Checkpoint({
    required this.model,
    required this.vocab,
    this.meta = const {},
    Set<int>? targetIds,
    Map<String, SqlCompleteKind>? tokenKinds,
  })  : targetIds = targetIds ?? const {},
        tokenKinds = tokenKinds ?? const {};

  SqlTokenPredictor toPredictor({DialectType? dialect}) {
    if (targetIds.isEmpty) {
      throw StateError('checkpoint targetIds must not be empty');
    }
    final dialectName = meta['dialect']?.toString();
    final resolved = dialect ??
        DialectType.values.firstWhere(
          (d) => d.name == dialectName,
          orElse: () => DialectType.mysql,
        );
    return SqlTokenPredictor(
      model: model,
      vocab: vocab,
      extractor: TokenExtractor(dialect: resolved, collapseObjects: true),
      targetIds: targetIds,
      tokenKinds: tokenKinds,
    );
  }

  Map<String, dynamic> toJson() => {
        'model': model.toJson(),
        'vocab': vocab.toJson(),
        'meta': meta,
        'targetIds': targetIds.toList(),
        'tokenKinds': {
          for (final e in tokenKinds.entries) e.key: e.value.name,
        },
      };

  /// 无缩进 + 截断小数，供嵌入 `bundled_checkpoint_data.dart`。
  String toCompactJson({int fractionDigits = 6}) {
    return const JsonEncoder().convert(
      _roundDoubles(toJson(), fractionDigits),
    );
  }

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    final kindsRaw = (json['tokenKinds'] as Map?)?.cast<String, dynamic>() ?? {};
    final kinds = <String, SqlCompleteKind>{};
    for (final e in kindsRaw.entries) {
      kinds[e.key] = SqlCompleteKind.values.firstWhere(
        (k) => k.name == e.value,
        orElse: () => SqlCompleteKind.object,
      );
    }
    final targetIds = ((json['targetIds'] as List?) ?? const [])
        .map((e) => e as int)
        .toSet();
    final vocab = Vocabulary.fromJson(json['vocab'] as Map<String, dynamic>);
    if (!vocab.tokenToId.containsKey(Vocabulary.unk)) {
      throw StateError('checkpoint vocab missing <UNK>');
    }
    final modelJson = json['model'] as Map<String, dynamic>;
    final configJson = modelJson['config'] as Map<String, dynamic>?;
    if (configJson != null) {
      final config = ModelConfig.fromJson(configJson);
      if (config.vocabSize != vocab.size) {
        throw StateError(
          'checkpoint vocabSize mismatch: '
          'model=${config.vocabSize} vocab=${vocab.size}',
        );
      }
    }
    return Checkpoint(
      model: SqlTokenModel.fromJson(modelJson),
      vocab: vocab,
      meta: (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
      targetIds: targetIds,
      tokenKinds: kinds,
    );
  }

  static Checkpoint fromJsonString(String raw) =>
      Checkpoint.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// JSON 树中 double 截到 [fractionDigits] 位。
Object? _roundDoubles(Object? node, int fractionDigits) {
  if (node is double) {
    return double.parse(node.toStringAsFixed(fractionDigits));
  }
  if (node is List) {
    return [for (final e in node) _roundDoubles(e, fractionDigits)];
  }
  if (node is Map) {
    return node.map((k, v) => MapEntry(k, _roundDoubles(v, fractionDigits)));
  }
  return node;
}

class Prediction {
  final String token;
  final int id;
  final double score;
  final SqlCompleteKind kind;

  const Prediction({
    required this.token,
    required this.id,
    required this.score,
    required this.kind,
  });

  @override
  String toString() => '$kind:$token(${score.toStringAsFixed(4)})';
}

/// 下一词预测接口（生产用 [SqlTokenPredictor]，测试可注入固定候选）。
abstract class SqlNextTokenPredictor {
  List<Prediction> predict(String sqlPrefix, {int topK = 8});
}

/// 下一词预测：前缀折叠为关键字/`<OBJ>`，取 softmax top-K。
class SqlTokenPredictor implements SqlNextTokenPredictor {
  final SqlTokenModel model;
  final Vocabulary vocab;
  final TokenExtractor extractor;
  final Set<int> targetIds;
  final Map<String, SqlCompleteKind> tokenKinds;

  SqlTokenPredictor({
    required this.model,
    required this.vocab,
    required this.targetIds,
    required this.tokenKinds,
    TokenExtractor? extractor,
  }) : extractor = extractor ??
            const TokenExtractor(collapseObjects: true) {
    if (targetIds.isEmpty) {
      throw ArgumentError('SqlTokenPredictor.targetIds must not be empty');
    }
  }

  /// [sqlPrefix]：光标前完整 token 前缀（对象折叠为 `<OBJ>`）。
  ///
  /// 超过 [ModelConfig.maxPosLen] 时只保留末尾窗口，避免 O(n²) 注意力。
  @override
  List<Prediction> predict(
    String sqlPrefix, {
    int topK = 8,
  }) {
    final tokens = extractor.extract(sqlPrefix);
    final ids = tokens.isEmpty
        ? [vocab.encodeToken(Vocabulary.bos)]
        : vocab.encode(_tailWindow(tokens, model.config.maxPosLen));
    final probs = softmax(model.forward(ids).logits);

    final scored = <Prediction>[];
    for (var id = 0; id < probs.length; id++) {
      if (!targetIds.contains(id)) continue;
      final token = vocab.decodeId(id);
      if (_isNonPredictToken(token)) continue;
      scored.add(Prediction(
        token: token,
        id: id,
        score: probs[id],
        kind: _kindOf(token),
      ));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList();
  }

  static List<ModelToken> _tailWindow(List<ModelToken> tokens, int maxLen) {
    if (maxLen <= 0 || tokens.length <= maxLen) return tokens;
    return tokens.sublist(tokens.length - maxLen);
  }

  SqlCompleteKind _kindOf(String token) {
    final fromMap = tokenKinds[token];
    if (fromMap != null) return fromMap;
    final placeholder = TokenExtractor.kindOfObjectPlaceholder(token);
    if (placeholder != null) return placeholder;
    return SqlCompleteKind.object;
  }

  /// 不作为预测目标的特殊符（`<OBJ>` 保留）。
  bool _isNonPredictToken(String token) =>
      token == '<NUM>' ||
      token == '<STR>' ||
      token == Vocabulary.pad ||
      token == Vocabulary.unk ||
      token == Vocabulary.bos ||
      token == Vocabulary.eos ||
      (token.length == 1 && !_predictorIdentChar(token.codeUnitAt(0)));
}

/// 标识符字符：`[A-Za-z0-9_]`（Predictor 私用，与 complete 侧扫描 helper 分开）。
bool _predictorIdentChar(int c) =>
    (c >= 65 && c <= 90) ||
    (c >= 97 && c <= 122) ||
    (c >= 48 && c <= 57) ||
    c == 95;

/// 包内预置补全模型（同步，无 asset 加载）。
///
/// 由 [SqlCompletionEngine] 调用；权重见 [bundledCheckpointJson]。
Checkpoint loadBundledCheckpoint() =>
    Checkpoint.fromJsonString(bundledCheckpointJson);

Checkpoint? _cachedBundled;
bool _bundledLoadAttempted = false;

/// 解析失败返回 null（仅首次尝试）。
Checkpoint? tryLoadBundledCheckpoint() {
  if (_bundledLoadAttempted) return _cachedBundled;
  _bundledLoadAttempted = true;
  try {
    _cachedBundled = loadBundledCheckpoint();
  } catch (_) {
    _cachedBundled = null;
  }
  return _cachedBundled;
}
