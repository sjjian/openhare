/// 模糊字符串匹配（大小写不敏感）。

/// 匹配类型。
enum MatchType {
  /// 完全匹配（score=1.0）。
  exact,

  /// 子序列模糊匹配。
  fuzzy,

  /// 未命中。
  none,
}

/// 模糊匹配结果。
class FuzzyMatchResult {
  final bool matched;
  final MatchType matchType;

  /// 0.0～1.0，越高越好。
  final double score;

  /// 输入字符在目标中的匹配下标。
  final List<int>? matchPositions;

  const FuzzyMatchResult({
    required this.matched,
    required this.matchType,
    required this.score,
    this.matchPositions,
  });

  const FuzzyMatchResult.noMatch()
      : matched = false,
        matchType = MatchType.none,
        score = 0.0,
        matchPositions = null;

  /// 完全匹配（无 positions；需高亮时用 [FuzzyMatch.matchWithResult]）。
  const FuzzyMatchResult.exact()
      : matched = true,
        matchType = MatchType.exact,
        score = 1.0,
        matchPositions = null;

  @override
  String toString() =>
      'FuzzyMatchResult(matched: $matched, type: $matchType, score: $score)';
}

/// 按序子序列匹配，并按前缀 / 位置 / 连续性 / 覆盖率加权打分。
///
/// ```dart
/// FuzzyMatch.match('abc', 'abcdef'); // true
/// final r = FuzzyMatch.matchWithResult('abc', 'abcdef');
/// ```
class FuzzyMatch {
  FuzzyMatch._();

  static const double _prefixMatchWeight = 0.5;
  static const double _positionPreferenceWeight = 0.3;
  static const double _continuityWeight = 0.15;
  static const double _lengthCoverageWeight = 0.05;

  static const double _startPositionDecayFactor = 0.3;
  static const double _averagePositionDecayFactor = 0.2;
  static const double _startPositionWeight = 0.7;
  static const double _averagePositionWeight = 0.3;

  static const double _gapDecayFactor = 0.1;

  /// 是否匹配（含 exact）；详情用 [matchWithResult]。
  static bool match(String input, String target) =>
      matchWithResult(input, target).matched;

  /// 返回匹配类型、分数与位置。
  static FuzzyMatchResult matchWithResult(String input, String target) {
    if (input.isEmpty) {
      return const FuzzyMatchResult.noMatch();
    }

    final normalizedInput = input.toLowerCase();
    final normalizedTarget = target.toLowerCase();

    if (normalizedInput == normalizedTarget) {
      return FuzzyMatchResult(
        matched: true,
        matchType: MatchType.exact,
        score: 1.0,
        matchPositions: List<int>.generate(normalizedTarget.length, (i) => i),
      );
    }

    final matchResult = _findFuzzyMatch(normalizedTarget, normalizedInput);
    if (matchResult != null) {
      final score = _calculateUnifiedScore(input, target, matchResult);
      return FuzzyMatchResult(
        matched: true,
        matchType: MatchType.fuzzy,
        score: score,
        matchPositions: matchResult,
      );
    }

    return const FuzzyMatchResult.noMatch();
  }

  /// 输入字符按序出现在目标中的位置；无法全覆盖则 null。
  static List<int>? _findFuzzyMatch(String target, String input) {
    if (input.isEmpty) return [];
    if (target.length < input.length) return null;

    final List<int> matchPositions = [];
    int inputCharIndex = 0;
    int targetCharIndex = 0;

    while (inputCharIndex < input.length && targetCharIndex < target.length) {
      if (input[inputCharIndex] == target[targetCharIndex]) {
        matchPositions.add(targetCharIndex);
        inputCharIndex++;
      }
      targetCharIndex++;
    }

    if (inputCharIndex == input.length) {
      return matchPositions;
    }

    return null;
  }

  /// score = 前缀×0.5 + 位置×0.3 + 连续性×0.15 + 覆盖率×0.05。
  static double _calculateUnifiedScore(
    String input,
    String target,
    List<int> positions,
  ) {
    if (target.isEmpty || positions.isEmpty) return 0.0;

    final double prefixBonus = _calculatePrefixBonus(input, target, positions);
    final double positionScore =
        _calculatePositionPreference(positions, target.length);
    final double continuityScore = _calculateContinuityScore(positions);
    final double lengthCoverage = input.length / target.length;

    final double finalScore = prefixBonus * _prefixMatchWeight +
        positionScore * _positionPreferenceWeight +
        continuityScore * _continuityWeight +
        lengthCoverage * _lengthCoverageWeight;

    return finalScore.clamp(0.0, 1.0);
  }

  static bool _isConsecutive(List<int> positions) {
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] != positions[i - 1] + 1) return false;
    }
    return true;
  }

  /// 完美前缀 1.0；从开头连续的部分前缀 0.8；否则 0。
  static double _calculatePrefixBonus(
      String input, String target, List<int> positions) {
    if (positions.length == input.length &&
        positions.isNotEmpty &&
        positions[0] == 0 &&
        _isConsecutive(positions)) {
      return 1.0;
    }

    final isPrefixMatch = positions.isNotEmpty &&
        positions[0] == 0 &&
        _isConsecutive(positions);

    return isPrefixMatch ? 0.8 : 0.0;
  }

  /// 间隙越小越高：`1 / (1 + gaps × 0.1)`。
  static double _calculateContinuityScore(List<int> positions) {
    if (positions.length <= 1) return 1.0;

    int totalCharacterGaps = 0;
    for (int i = 1; i < positions.length; i++) {
      totalCharacterGaps += positions[i] - positions[i - 1] - 1;
    }

    final double continuityScore =
        1.0 / (1.0 + totalCharacterGaps * _gapDecayFactor);

    return continuityScore.clamp(0.0, 1.0);
  }

  /// 越靠前越高：起始位置权重 0.7，平均位置 0.3。
  static double _calculatePositionPreference(
      List<int> positions, int targetLength) {
    if (targetLength == 0 || positions.isEmpty) return 0.0;

    final int startPosition = positions[0];

    int sumOfPositions = 0;
    for (final position in positions) {
      sumOfPositions += position;
    }
    final double averageMatchPosition = sumOfPositions / positions.length;

    final double startScore =
        1.0 / (1.0 + startPosition * _startPositionDecayFactor);
    final double averageScore =
        1.0 / (1.0 + averageMatchPosition * _averagePositionDecayFactor);

    final double combinedScore =
        startScore * _startPositionWeight + averageScore * _averagePositionWeight;

    return combinedScore.clamp(0.0, 1.0);
  }
}
