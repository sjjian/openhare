import 'dart:math' as math;

import 'package:sql_complete/training.dart';
import 'package:test/test.dart';

/// 有限差分校验反向传播（数值梯度 vs 解析梯度）。
void main() {
  const eps = 1e-5;
  const tol = 2e-3;

  test('Linear.backward 对 weight 的数值梯度', () {
    final lin = Linear(4, 3, random: math.Random(3));
    final x = Tensor.randn(2, 4, random: math.Random(1), scale: 0.5);
    final dy = Tensor.randn(2, 3, random: math.Random(2), scale: 0.5);

    lin.weight.grad.data.fillRange(0, lin.weight.grad.data.length, 0);
    lin.bias.grad.data.fillRange(0, lin.bias.grad.data.length, 0);
    lin.backward(x, dy);

    for (var i = 0; i < lin.weight.value.data.length; i++) {
      final w = lin.weight.value.data;
      final analytic = lin.weight.grad.data[i];
      final orig = w[i];
      w[i] = orig + eps;
      final up = _sumSq(lin.forward(x), dy);
      w[i] = orig - eps;
      final down = _sumSq(lin.forward(x), dy);
      w[i] = orig;
      final numeric = (up - down) / (2 * eps);
      expect(
        (analytic - numeric).abs(),
        lessThan(tol),
        reason: 'weight[$i] analytic=$analytic numeric=$numeric',
      );
    }
  });

  test('TransformerBlock.backward 对 wq.weight 的数值梯度', () {
    final block = TransformerBlock(8, ffDim: 16, seed: 5);
    final x = Tensor.randn(3, 8, random: math.Random(4), scale: 0.3);
    final dOut = Tensor.randn(3, 8, random: math.Random(6), scale: 0.3);

    for (final p in block.parameters) {
      p.zeroGrad();
    }
    final cache = block.forward(x);
    block.backward(cache, dOut);

    final w = block.wq.weight.value.data;
    final g = block.wq.weight.grad.data;
    // 抽查若干坐标，完整扫一遍太慢。
    for (final i in [0, 3, 7, 15, w.length - 1]) {
      final analytic = g[i];
      final orig = w[i];
      w[i] = orig + eps;
      final up = _sumSq(block.forward(x).output, dOut);
      w[i] = orig - eps;
      final down = _sumSq(block.forward(x).output, dOut);
      w[i] = orig;
      final numeric = (up - down) / (2 * eps);
      expect(
        (analytic - numeric).abs(),
        lessThan(tol),
        reason: 'wq.weight[$i] analytic=$analytic numeric=$numeric',
      );
    }
  });

  test('SqlTokenModel 对 embedding 的 loss 数值梯度', () {
    final model = SqlTokenModel(
      const ModelConfig(
        vocabSize: 12,
        embedDim: 8,
        hiddenDim: 8,
        numLayers: 1,
        seed: 9,
        maxPosLen: 8,
      ),
    );
    const nodeIds = [2, 4, 5, 7];
    const targetId = 3;

    model.zeroGrad();
    final fwd = model.forward(nodeIds);
    model.backward(fwd, targetId);
    model.backwardGraph();

    final w = model.embedding.weight.value.data;
    final g = model.embedding.weight.grad.data;
    final dim = model.config.embedDim;
    // 扰动实际出现过的 token 行上的若干维。
    for (final id in nodeIds) {
      for (final j in [0, dim ~/ 2, dim - 1]) {
        final i = id * dim + j;
        final analytic = g[i];
        final orig = w[i];
        w[i] = orig + eps;
        final up = _modelLoss(model, nodeIds, targetId);
        w[i] = orig - eps;
        final down = _modelLoss(model, nodeIds, targetId);
        w[i] = orig;
        final numeric = (up - down) / (2 * eps);
        expect(
          (analytic - numeric).abs(),
          lessThan(tol),
          reason: 'emb[$id,$j] analytic=$analytic numeric=$numeric',
        );
      }
    }
  });
}

double _sumSq(Tensor y, Tensor dy) {
  var s = 0.0;
  for (var i = 0; i < y.data.length; i++) {
    s += y.data[i] * dy.data[i];
  }
  return s;
}

double _modelLoss(SqlTokenModel model, List<int> nodeIds, int targetId) {
  final fwd = model.forward(nodeIds);
  return softmaxCrossEntropy(fwd.logits, targetId).$1;
}
