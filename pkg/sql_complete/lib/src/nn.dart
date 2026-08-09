import 'dart:math' as math;
import 'dart:typed_data';

/// 简单行列矩阵，供纯 Dart Causal Attn 下一词模型 使用。
class Tensor {
  final int rows;
  final int cols;
  final Float64List data;

  Tensor(this.rows, this.cols, [Float64List? data])
      : data = data ?? Float64List(rows * cols) {
    assert(this.data.length == rows * cols);
  }

  factory Tensor.zeros(int rows, int cols) => Tensor(rows, cols);

  factory Tensor.randn(int rows, int cols, {math.Random? random, double scale = 1.0}) {
    final rng = random ?? math.Random();
    final t = Tensor(rows, cols);
    for (var i = 0; i < t.data.length; i++) {
      // Box-Muller
      final u1 = math.max(1e-12, rng.nextDouble());
      final u2 = rng.nextDouble();
      final z = math.sqrt(-2.0 * math.log(u1)) * math.cos(2 * math.pi * u2);
      t.data[i] = z * scale;
    }
    return t;
  }

  double get(int r, int c) => data[r * cols + c];

  void set(int r, int c, double v) => data[r * cols + c] = v;

  Tensor copy() => Tensor(rows, cols, Float64List.fromList(data));

  void fill(double v) => data.fillRange(0, data.length, v);

  void addInPlace(Tensor other, {double scale = 1.0}) {
    assert(rows == other.rows && cols == other.cols);
    for (var i = 0; i < data.length; i++) {
      data[i] += other.data[i] * scale;
    }
  }

  void scaleInPlace(double s) {
    for (var i = 0; i < data.length; i++) {
      data[i] *= s;
    }
  }

  Tensor transpose() {
    final out = Tensor(cols, rows);
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        out.set(j, i, get(i, j));
      }
    }
    return out;
  }

  /// this(rows,k) @ other(k,cols)
  Tensor matmul(Tensor other) {
    assert(cols == other.rows);
    final out = Tensor(rows, other.cols);
    for (var i = 0; i < rows; i++) {
      for (var k = 0; k < cols; k++) {
        final aik = get(i, k);
        if (aik == 0) continue;
        final base = k * other.cols;
        final outBase = i * other.cols;
        for (var j = 0; j < other.cols; j++) {
          out.data[outBase + j] += aik * other.data[base + j];
        }
      }
    }
    return out;
  }

  Tensor addBias(Tensor bias) {
    assert(bias.rows == 1 && bias.cols == cols);
    final out = copy();
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        out.data[i * cols + j] += bias.data[j];
      }
    }
    return out;
  }

  Tensor relu() {
    final out = copy();
    for (var i = 0; i < out.data.length; i++) {
      if (out.data[i] < 0) out.data[i] = 0;
    }
    return out;
  }

  /// ReLU 反向：上游梯度 * (x>0)
  Tensor reluBackward(Tensor upstream) {
    assert(rows == upstream.rows && cols == upstream.cols);
    final out = Tensor(rows, cols);
    for (var i = 0; i < data.length; i++) {
      out.data[i] = data[i] > 0 ? upstream.data[i] : 0;
    }
    return out;
  }

  Tensor row(int r) {
    final out = Tensor(1, cols);
    for (var j = 0; j < cols; j++) {
      out.data[j] = get(r, j);
    }
    return out;
  }

  double sum() {
    var s = 0.0;
    for (final v in data) {
      s += v;
    }
    return s;
  }

  double normL2() {
    var s = 0.0;
    for (final v in data) {
      s += v * v;
    }
    return math.sqrt(s);
  }

  Map<String, dynamic> toJson() => {
        'rows': rows,
        'cols': cols,
        'data': data.toList(),
      };

  factory Tensor.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as int;
    final cols = json['cols'] as int;
    final list = (json['data'] as List).cast<num>().map((e) => e.toDouble()).toList();
    return Tensor(rows, cols, Float64List.fromList(list));
  }
}

/// Softmax + cross-entropy，返回 (loss, dLogits)。
(double, Tensor) softmaxCrossEntropy(Tensor logits, int target) {
  assert(logits.rows == 1);
  final n = logits.cols;
  assert(target >= 0 && target < n);

  var maxV = logits.data[0];
  for (var i = 1; i < n; i++) {
    if (logits.data[i] > maxV) maxV = logits.data[i];
  }

  final exps = Float64List(n);
  var sum = 0.0;
  for (var i = 0; i < n; i++) {
    exps[i] = math.exp(logits.data[i] - maxV);
    sum += exps[i];
  }

  final probs = Float64List(n);
  for (var i = 0; i < n; i++) {
    probs[i] = exps[i] / sum;
  }

  final loss = -math.log(math.max(probs[target], 1e-12));
  final grad = Tensor(1, n);
  for (var i = 0; i < n; i++) {
    grad.data[i] = probs[i];
  }
  grad.data[target] -= 1.0;
  return (loss, grad);
}

List<double> softmax(Tensor logits) {
  assert(logits.rows == 1);
  final n = logits.cols;
  var maxV = logits.data[0];
  for (var i = 1; i < n; i++) {
    if (logits.data[i] > maxV) maxV = logits.data[i];
  }
  final exps = List<double>.filled(n, 0);
  var sum = 0.0;
  for (var i = 0; i < n; i++) {
    exps[i] = math.exp(logits.data[i] - maxV);
    sum += exps[i];
  }
  for (var i = 0; i < n; i++) {
    exps[i] /= sum;
  }
  return exps;
}

class Parameter {
  final Tensor value;
  final Tensor grad;

  Parameter(this.value) : grad = Tensor.zeros(value.rows, value.cols);

  void zeroGrad() => grad.fill(0);
}

/// 词嵌入表：[vocabSize, dim]
class Embedding {
  final Parameter weight;

  Embedding(int vocabSize, int dim, {math.Random? random})
      : weight = Parameter(
          Tensor.randn(vocabSize, dim, random: random ?? math.Random(0), scale: 0.1),
        );

  Tensor forward(List<int> ids) {
    final out = Tensor(ids.length, weight.value.cols);
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i].clamp(0, weight.value.rows - 1);
      for (var j = 0; j < weight.value.cols; j++) {
        out.set(i, j, weight.value.get(id, j));
      }
    }
    return out;
  }

  void backward(List<int> ids, Tensor gradOut) {
    assert(gradOut.rows == ids.length && gradOut.cols == weight.value.cols);
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i].clamp(0, weight.value.rows - 1);
      for (var j = 0; j < weight.value.cols; j++) {
        weight.grad.data[id * weight.value.cols + j] += gradOut.get(i, j);
      }
    }
  }

  Iterable<Parameter> get parameters sync* {
    yield weight;
  }
}

/// 线性层 y = xW + b
class Linear {
  final Parameter weight; // [in, out]
  final Parameter bias; // [1, out]

  Linear(int inDim, int outDim, {math.Random? random})
      : weight = Parameter(
          Tensor.randn(
            inDim,
            outDim,
            random: random ?? math.Random(1),
            scale: math.sqrt(2.0 / (inDim + outDim)),
          ),
        ),
        bias = Parameter(Tensor.zeros(1, outDim));

  Tensor forward(Tensor x) => x.matmul(weight.value).addBias(bias.value);

  /// 返回 dx
  Tensor backward(Tensor x, Tensor dy) {
    // dW = x^T @ dy
    final xt = x.transpose();
    final dW = xt.matmul(dy);
    weight.grad.addInPlace(dW);

    // db = sum rows of dy
    for (var i = 0; i < dy.rows; i++) {
      for (var j = 0; j < dy.cols; j++) {
        bias.grad.data[j] += dy.get(i, j);
      }
    }

    // dx = dy @ W^T
    return dy.matmul(weight.value.transpose());
  }

  Iterable<Parameter> get parameters sync* {
    yield weight;
    yield bias;
  }
}

/// 位置嵌入：[maxLen, dim]，加到 token embedding 上。
class PositionEmbedding {
  final Parameter weight;

  PositionEmbedding(int maxLen, int dim, {math.Random? random})
      : weight = Parameter(
          Tensor.randn(maxLen, dim, random: random ?? math.Random(2), scale: 0.02),
        );

  Tensor forward(int seqLen) {
    final n = math.min(seqLen, weight.value.rows);
    final out = Tensor(seqLen, weight.value.cols);
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < weight.value.cols; j++) {
        out.set(i, j, weight.value.get(i, j));
      }
    }
    // 超长序列复用末位
    for (var i = n; i < seqLen; i++) {
      for (var j = 0; j < weight.value.cols; j++) {
        out.set(i, j, weight.value.get(n - 1, j));
      }
    }
    return out;
  }

  void backward(Tensor gradOut) {
    final n = math.min(gradOut.rows, weight.value.rows);
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < weight.value.cols; j++) {
        weight.grad.data[i * weight.value.cols + j] += gradOut.get(i, j);
      }
    }
    for (var i = n; i < gradOut.rows; i++) {
      for (var j = 0; j < weight.value.cols; j++) {
        weight.grad.data[(n - 1) * weight.value.cols + j] += gradOut.get(i, j);
      }
    }
  }

  Iterable<Parameter> get parameters sync* {
    yield weight;
  }
}

/// 单头因果自注意力 + 残差 FFN。
class TransformerBlock {
  final Linear wq;
  final Linear wk;
  final Linear wv;
  final Linear wo;
  final Linear ff1;
  final Linear ff2;
  final double scale;

  TransformerBlock(int dim, {int? ffDim, int seed = 0})
      : wq = Linear(dim, dim, random: math.Random(seed)),
        wk = Linear(dim, dim, random: math.Random(seed + 1)),
        wv = Linear(dim, dim, random: math.Random(seed + 2)),
        wo = Linear(dim, dim, random: math.Random(seed + 3)),
        ff1 = Linear(dim, ffDim ?? dim * 2, random: math.Random(seed + 4)),
        ff2 = Linear(ffDim ?? dim * 2, dim, random: math.Random(seed + 5)),
        scale = 1.0 / math.sqrt(dim.toDouble());

  TransformerCache forward(Tensor x) {
    final q = wq.forward(x);
    final k = wk.forward(x);
    final v = wv.forward(x);

    final n = x.rows;
    final scores = Tensor(n, n);
    for (var i = 0; i < n; i++) {
      for (var j = 0; j <= i; j++) {
        var dot = 0.0;
        for (var d = 0; d < x.cols; d++) {
          dot += q.get(i, d) * k.get(j, d);
        }
        scores.set(i, j, dot * scale);
      }
      for (var j = i + 1; j < n; j++) {
        scores.set(i, j, -1e9);
      }
    }

    final attn = _rowSoftmax(scores);
    final ctx = attn.matmul(v);
    final attnOut = wo.forward(ctx);
    final mid = x.copy()..addInPlace(attnOut);

    final ffPre = ff1.forward(mid);
    final ffAct = ffPre.relu();
    final ffOut = ff2.forward(ffAct);
    final output = mid.copy()..addInPlace(ffOut);

    return TransformerCache(
      input: x,
      q: q,
      k: k,
      v: v,
      scores: scores,
      attn: attn,
      ctx: ctx,
      attnOut: attnOut,
      mid: mid,
      ffPre: ffPre,
      ffAct: ffAct,
      ffOut: ffOut,
      output: output,
    );
  }

  Tensor backward(TransformerCache cache, Tensor dOut) {
    // output = mid + ffOut
    var dMid = dOut.copy();
    final dFfOut = dOut.copy();
    final dFfAct = ff2.backward(cache.ffAct, dFfOut);
    final dFfPre = cache.ffPre.reluBackward(dFfAct);
    dMid.addInPlace(ff1.backward(cache.mid, dFfPre));

    // mid = x + attnOut
    final dAttnOut = dMid.copy();
    final dX = dMid.copy();
    final dCtx = wo.backward(cache.ctx, dAttnOut);

    // ctx = attn @ v
    final dAttn = dCtx.matmul(cache.v.transpose());
    final dV = cache.attn.transpose().matmul(dCtx);

    final dScores = _rowSoftmaxBackward(cache.attn, dAttn);
    // 因果掩码外梯度清零
    final n = cache.input.rows;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        dScores.set(i, j, 0);
      }
    }

    final dQ = Tensor(n, cache.input.cols);
    final dK = Tensor(n, cache.input.cols);
    for (var i = 0; i < n; i++) {
      for (var j = 0; j <= i; j++) {
        final ds = dScores.get(i, j) * scale;
        for (var d = 0; d < cache.input.cols; d++) {
          dQ.data[i * cache.input.cols + d] += ds * cache.k.get(j, d);
          dK.data[j * cache.input.cols + d] += ds * cache.q.get(i, d);
        }
      }
    }

    dX.addInPlace(wq.backward(cache.input, dQ));
    dX.addInPlace(wk.backward(cache.input, dK));
    dX.addInPlace(wv.backward(cache.input, dV));
    return dX;
  }

  Iterable<Parameter> get parameters sync* {
    yield* wq.parameters;
    yield* wk.parameters;
    yield* wv.parameters;
    yield* wo.parameters;
    yield* ff1.parameters;
    yield* ff2.parameters;
  }
}

class TransformerCache {
  final Tensor input;
  final Tensor q;
  final Tensor k;
  final Tensor v;
  final Tensor scores;
  final Tensor attn;
  final Tensor ctx;
  final Tensor attnOut;
  final Tensor mid;
  final Tensor ffPre;
  final Tensor ffAct;
  final Tensor ffOut;
  final Tensor output;

  TransformerCache({
    required this.input,
    required this.q,
    required this.k,
    required this.v,
    required this.scores,
    required this.attn,
    required this.ctx,
    required this.attnOut,
    required this.mid,
    required this.ffPre,
    required this.ffAct,
    required this.ffOut,
    required this.output,
  });
}

Tensor _rowSoftmax(Tensor scores) {
  final out = Tensor(scores.rows, scores.cols);
  for (var i = 0; i < scores.rows; i++) {
    var maxV = scores.get(i, 0);
    for (var j = 1; j < scores.cols; j++) {
      final v = scores.get(i, j);
      if (v > maxV) maxV = v;
    }
    var sum = 0.0;
    for (var j = 0; j < scores.cols; j++) {
      final e = math.exp(scores.get(i, j) - maxV);
      out.set(i, j, e);
      sum += e;
    }
    final inv = 1.0 / math.max(sum, 1e-12);
    for (var j = 0; j < scores.cols; j++) {
      out.data[i * out.cols + j] *= inv;
    }
  }
  return out;
}

Tensor _rowSoftmaxBackward(Tensor attn, Tensor dAttn) {
  final out = Tensor(attn.rows, attn.cols);
  for (var i = 0; i < attn.rows; i++) {
    var dot = 0.0;
    for (var j = 0; j < attn.cols; j++) {
      dot += attn.get(i, j) * dAttn.get(i, j);
    }
    for (var j = 0; j < attn.cols; j++) {
      out.set(i, j, attn.get(i, j) * (dAttn.get(i, j) - dot));
    }
  }
  return out;
}

class ModelConfig {
  final int vocabSize;
  final int embedDim;
  final int hiddenDim;
  final int numLayers;
  final int seed;

  /// 位置嵌入最大长度。
  final int maxPosLen;

  const ModelConfig({
    required this.vocabSize,
    this.embedDim = 64,
    this.hiddenDim = 64,
    this.numLayers = 2,
    this.seed = 42,
    this.maxPosLen = 64,
  });

  Map<String, dynamic> toJson() => {
        'vocabSize': vocabSize,
        'embedDim': embedDim,
        'hiddenDim': hiddenDim,
        'numLayers': numLayers,
        'seed': seed,
        'maxPosLen': maxPosLen,
      };

  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      vocabSize: json['vocabSize'] as int,
      embedDim: json['embedDim'] as int? ?? 64,
      hiddenDim: json['hiddenDim'] as int? ?? 64,
      numLayers: json['numLayers'] as int? ?? 2,
      seed: json['seed'] as int? ?? 42,
      maxPosLen: json['maxPosLen'] as int? ?? 64,
    );
  }
}

class ForwardResult {
  final Tensor logits;
  final List<int> nodeIds;
  final Tensor embedded;
  final List<TransformerCache> attnCaches;
  final Tensor positions;
  final Tensor pooled;

  ForwardResult({
    required this.logits,
    required this.nodeIds,
    required this.embedded,
    required this.attnCaches,
    required this.pooled,
    required this.positions,
  });
}

/// SQL 下一词元模型：Embedding → Causal Attn → 末节点池化 → Linear
class SqlTokenModel {
  final ModelConfig config;
  final Embedding embedding;
  final PositionEmbedding position;
  final List<TransformerBlock> attnLayers;
  final Linear classifier;

  SqlTokenModel(this.config, {math.Random? random})
      : embedding = Embedding(
          config.vocabSize,
          config.embedDim,
          random: random ?? math.Random(config.seed),
        ),
        position = PositionEmbedding(
          config.maxPosLen,
          config.embedDim,
          random: math.Random(config.seed + 5),
        ),
        attnLayers = List.generate(
          config.numLayers,
          (i) => TransformerBlock(
            config.embedDim,
            ffDim: config.hiddenDim * 2,
            seed: config.seed + 20 + i * 10,
          ),
        ),
        classifier = Linear(
          config.embedDim,
          config.vocabSize,
          random: math.Random(config.seed + 100),
        );

  Iterable<Parameter> get parameters sync* {
    yield* embedding.parameters;
    yield* position.parameters;
    for (final layer in attnLayers) {
      yield* layer.parameters;
    }
    yield* classifier.parameters;
  }

  void zeroGrad() {
    for (final p in parameters) {
      p.zeroGrad();
    }
  }

  /// 用前缀末词元表示做分类。
  ForwardResult forward(List<int> nodeIds) {
    assert(nodeIds.isNotEmpty);
    final tokenEmb = embedding.forward(nodeIds);
    final positions = position.forward(tokenEmb.rows);
    var h = tokenEmb.copy()..addInPlace(positions);

    final attnCaches = <TransformerCache>[];
    for (final layer in attnLayers) {
      final cache = layer.forward(h);
      attnCaches.add(cache);
      h = cache.output;
    }

    final pooled = h.row(h.rows - 1);
    final logits = classifier.forward(pooled);
    return ForwardResult(
      logits: logits,
      nodeIds: nodeIds,
      embedded: tokenEmb,
      attnCaches: attnCaches,
      positions: positions,
      pooled: pooled,
    );
  }

  /// 反向传播，返回 loss。
  double backward(ForwardResult fwd, int targetId) {
    final (loss, dLogits) = softmaxCrossEntropy(fwd.logits, targetId);
    final dPooled = classifier.backward(fwd.pooled, dLogits);

    final lastH = fwd.attnCaches.isEmpty
        ? _embeddedWithPos(fwd)
        : fwd.attnCaches.last.output;
    final dH = Tensor.zeros(lastH.rows, lastH.cols);
    final last = lastH.rows - 1;
    for (var j = 0; j < lastH.cols; j++) {
      dH.set(last, j, dPooled.data[j]);
    }

    _pendingDH = dH;
    _pendingFwd = fwd;
    return loss;
  }

  Tensor _embeddedWithPos(ForwardResult fwd) {
    return fwd.embedded.copy()..addInPlace(fwd.positions);
  }

  ForwardResult? _pendingFwd;
  Tensor? _pendingDH;

  void backwardGraph() {
    final fwd = _pendingFwd;
    final pending = _pendingDH;
    if (fwd == null || pending == null) {
      throw StateError('Call backward() before backwardGraph()');
    }

    var dH = pending;
    for (var i = attnLayers.length - 1; i >= 0; i--) {
      dH = attnLayers[i].backward(fwd.attnCaches[i], dH);
    }
    position.backward(dH);
    embedding.backward(fwd.nodeIds, dH);
    _pendingFwd = null;
    _pendingDH = null;
  }

  List<(int id, double score)> topK(List<int> nodeIds, {int k = 5}) {
    final fwd = forward(nodeIds);
    final probs = softmax(fwd.logits);
    final indexed = <(int, double)>[];
    for (var i = 0; i < probs.length; i++) {
      indexed.add((i, probs[i]));
    }
    indexed.sort((a, b) => b.$2.compareTo(a.$2));
    return indexed.take(k).toList();
  }

  Map<String, dynamic> toJson() => {
        'config': config.toJson(),
        'embedding': embedding.weight.value.toJson(),
        'position': position.weight.value.toJson(),
        'attn': [
          for (final layer in attnLayers)
            {
              'wq': {
                'weight': layer.wq.weight.value.toJson(),
                'bias': layer.wq.bias.value.toJson(),
              },
              'wk': {
                'weight': layer.wk.weight.value.toJson(),
                'bias': layer.wk.bias.value.toJson(),
              },
              'wv': {
                'weight': layer.wv.weight.value.toJson(),
                'bias': layer.wv.bias.value.toJson(),
              },
              'wo': {
                'weight': layer.wo.weight.value.toJson(),
                'bias': layer.wo.bias.value.toJson(),
              },
              'ff1': {
                'weight': layer.ff1.weight.value.toJson(),
                'bias': layer.ff1.bias.value.toJson(),
              },
              'ff2': {
                'weight': layer.ff2.weight.value.toJson(),
                'bias': layer.ff2.bias.value.toJson(),
              },
            }
        ],
        'classifier': {
          'weight': classifier.weight.value.toJson(),
          'bias': classifier.bias.value.toJson(),
        },
      };

  factory SqlTokenModel.fromJson(Map<String, dynamic> json) {
    final rawConfig = Map<String, dynamic>.from(json['config'] as Map);
    final config = ModelConfig.fromJson(rawConfig);
    final model = SqlTokenModel(config);
    final emb = Tensor.fromJson(json['embedding'] as Map<String, dynamic>);
    _copyTensor(emb, model.embedding.weight.value);

    _copyTensor(
      Tensor.fromJson(json['position'] as Map<String, dynamic>),
      model.position.weight.value,
    );

    final attn = json['attn'] as List? ?? const [];
    for (var i = 0; i < model.attnLayers.length; i++) {
      final layerJson = attn[i] as Map<String, dynamic>;
      _loadLinear(layerJson['wq'] as Map<String, dynamic>, model.attnLayers[i].wq);
      _loadLinear(layerJson['wk'] as Map<String, dynamic>, model.attnLayers[i].wk);
      _loadLinear(layerJson['wv'] as Map<String, dynamic>, model.attnLayers[i].wv);
      _loadLinear(layerJson['wo'] as Map<String, dynamic>, model.attnLayers[i].wo);
      _loadLinear(layerJson['ff1'] as Map<String, dynamic>, model.attnLayers[i].ff1);
      _loadLinear(layerJson['ff2'] as Map<String, dynamic>, model.attnLayers[i].ff2);
    }

    final clf = json['classifier'] as Map<String, dynamic>;
    _copyTensor(
      Tensor.fromJson(clf['weight'] as Map<String, dynamic>),
      model.classifier.weight.value,
    );
    _copyTensor(
      Tensor.fromJson(clf['bias'] as Map<String, dynamic>),
      model.classifier.bias.value,
    );
    return model;
  }
}

void _loadLinear(Map<String, dynamic> json, Linear layer) {
  _copyTensor(Tensor.fromJson(json['weight'] as Map<String, dynamic>), layer.weight.value);
  _copyTensor(Tensor.fromJson(json['bias'] as Map<String, dynamic>), layer.bias.value);
}

void _copyTensor(Tensor src, Tensor dst) {
  assert(src.rows == dst.rows && src.cols == dst.cols);
  for (var i = 0; i < src.data.length; i++) {
    dst.data[i] = src.data[i];
  }
}

/// Adam 优化器（纯 Dart）。
class AdamOptimizer {
  final double lr;
  final double beta1;
  final double beta2;
  final double eps;
  final double weightDecay;

  final Map<Parameter, _AdamState> _states = {};
  int _step = 0;

  AdamOptimizer({
    this.lr = 1e-3,
    this.beta1 = 0.9,
    this.beta2 = 0.999,
    this.eps = 1e-8,
    this.weightDecay = 0.0,
  });

  void step(Iterable<Parameter> parameters) {
    _step += 1;
    final bc1 = 1 - math.pow(beta1, _step).toDouble();
    final bc2 = 1 - math.pow(beta2, _step).toDouble();

    for (final p in parameters) {
      final state = _states.putIfAbsent(
        p,
        () => _AdamState(
          m: List<double>.filled(p.value.data.length, 0),
          v: List<double>.filled(p.value.data.length, 0),
        ),
      );

      for (var i = 0; i < p.value.data.length; i++) {
        var g = p.grad.data[i];
        if (weightDecay != 0) {
          g += weightDecay * p.value.data[i];
        }
        state.m[i] = beta1 * state.m[i] + (1 - beta1) * g;
        state.v[i] = beta2 * state.v[i] + (1 - beta2) * g * g;
        final mHat = state.m[i] / bc1;
        final vHat = state.v[i] / bc2;
        p.value.data[i] -= lr * mHat / (math.sqrt(vHat) + eps);
      }
    }
  }
}

class _AdamState {
  final List<double> m;
  final List<double> v;

  _AdamState({required this.m, required this.v});
}
