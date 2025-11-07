/// Dart/Flutter 模糊字符串匹配库。
///
/// 提供受 fuzzywuzzy 启发的统一模糊匹配算法。
library fuzzy_match;

/// 找到的匹配类型。
enum MatchType {
  /// 完全匹配（在此库中不视为匹配）。
  exact,

  /// 模糊匹配 - 统一匹配算法。
  fuzzy,

  /// 未找到匹配。
  none,
}

/// 模糊匹配操作的结果。
class FuzzyMatchResult {
  /// 是否找到了匹配。
  final bool matched;

  /// 找到的匹配类型。
  final MatchType matchType;

  /// 匹配分数（0.0 到 1.0），越高越好。
  final double score;

  /// 输入字符在目标字符串中匹配的位置。
  final List<int>? matchPositions;

  const FuzzyMatchResult({
    required this.matched,
    required this.matchType,
    required this.score,
    this.matchPositions,
  });

  /// 创建无匹配的结果。
  const FuzzyMatchResult.noMatch()
      : matched = false,
        matchType = MatchType.none,
        score = 0.0,
        matchPositions = null;

  /// 创建完全匹配的结果。
  const FuzzyMatchResult.exact()
      : matched = false,
        matchType = MatchType.exact,
        score = 1.0,
        matchPositions = null;

  @override
  String toString() =>
      'FuzzyMatchResult(matched: $matched, type: $matchType, score: $score)';
}

/// 模糊字符串匹配的工具类。将多种匹配策略组合成单个高效实现。
///
/// 该算法按顺序查找字符序列，根据以下因素计算分数：
/// - 长度覆盖率（输入有多少匹配）
/// - 连续性（匹配字符的接近程度）
/// - 位置偏好（越接近开头的匹配分数越高）
///
/// 所有匹配都不区分大小写。完全匹配不视为有效匹配。
///
/// 使用示例：
/// ```dart
/// // 简单的布尔匹配
/// bool result = FuzzyMatch.match('abc', 'abcdef');
///
/// // 获取详细结果
/// FuzzyMatchResult result = FuzzyMatch.matchWithResult('abc', 'abcdef');
/// print(result.matched); // true
/// print(result.matchType); // MatchType.fuzzy
/// print(result.score); // 0.5
/// ```
class FuzzyMatch {
  FuzzyMatch._();

  // 评分权重常量 - 用于统一分数的加权计算
  static const double _prefixMatchWeight = 0.5; // 前缀匹配权重
  static const double _positionPreferenceWeight = 0.3; // 位置偏好权重
  static const double _continuityWeight = 0.15; // 连续性权重
  static const double _lengthCoverageWeight = 0.05; // 长度覆盖率权重

  // 位置偏好算法常量
  static const double _startPositionDecayFactor = 0.3; // 起始位置衰减因子
  static const double _averagePositionDecayFactor = 0.2; // 平均位置衰减因子
  static const double _startPositionWeight = 0.7; // 起始位置在最终得分中的权重
  static const double _averagePositionWeight = 0.3; // 平均位置在最终得分中的权重

  // 连续性算法常量
  static const double _gapDecayFactor = 0.1; // 间隙衰减因子

  // ==================== 公共 API 方法 ====================

  /// 检查输入是否与目标字符串匹配。
  ///
  /// 如果找到匹配则返回 `true`，否则返回 `false`。
  ///
  /// 这是一个优化的版本，只检查匹配而不计算分数或位置。
  /// 如果需要详细的匹配信息，请使用 [matchWithResult]。
  ///
  /// - [input] - 要匹配的搜索模式。
  /// - [target] - 要搜索的目标字符串。
  static bool match(String input, String target) {
    // 空输入不匹配
    if (input.isEmpty) return false;

    // 检查完全匹配（不视为匹配）
    if (target == input) return false;

    final String normalizedInput = input.toLowerCase();
    final String normalizedTarget = target.toLowerCase();

    // 使用统一的模糊匹配算法
    final result = _findFuzzyMatch(normalizedTarget, normalizedInput);
    return result != null;
  }

  /// 执行模糊匹配并返回详细的结果信息。
  ///
  /// - [input] - 要匹配的搜索模式。
  /// - [target] - 要搜索的目标字符串。
  ///
  /// 返回包含匹配信息的 [FuzzyMatchResult]。
  static FuzzyMatchResult matchWithResult(String input, String target) {
    // 快速路径：空输入永远不匹配任何目标
    if (input.isEmpty) {
      return const FuzzyMatchResult.noMatch();
    }

    // 检查完全匹配（不视为匹配）
    if (target == input) {
      return const FuzzyMatchResult.exact();
    }

    final String normalizedInput = input.toLowerCase();
    final String normalizedTarget = target.toLowerCase();

    // 使用统一的模糊匹配算法
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

  // ==================== 核心匹配算法 ====================

  /// 统一的模糊匹配算法。
  ///
  /// 查找输入字符按顺序出现在目标字符串中的最佳位置序列。
  /// 如果所有字符都能匹配则返回位置，否则返回 null。
  static List<int>? _findFuzzyMatch(String target, String input) {
    // 边界情况：空输入匹配空位置
    if (input.isEmpty) return [];

    // 边界情况：目标字符串长度不足以包含输入
    if (target.length < input.length) return null;

    final List<int> matchPositions = [];
    int inputCharIndex = 0;
    int targetCharIndex = 0;

    // 按顺序查找每个输入字符在目标字符串中的匹配位置
    while (inputCharIndex < input.length && targetCharIndex < target.length) {
      if (input[inputCharIndex] == target[targetCharIndex]) {
        matchPositions.add(targetCharIndex);
        inputCharIndex++;
      }
      targetCharIndex++;
    }

    // 如果匹配了所有输入字符，返回匹配位置
    if (inputCharIndex == input.length) {
      return matchPositions;
    }

    return null;
  }

  // ==================== 评分算法 ====================

  /// 计算模糊匹配的统一分数（0.0 到 1.0）。
  ///
  /// 算法通过加权组合四个关键因素来评估匹配质量：
  ///
  /// 1. 前缀匹配奖励 (权重 0.5)
  ///    - 完美前缀匹配：输入完全是目标的前缀，得分 1.0
  ///    - 部分前缀匹配：匹配从开头连续开始，得分 0.8
  ///    - 普通匹配：无奖励
  ///
  /// 2. 位置偏好分数 (权重 0.3)
  ///    - 越接近目标开头位置的匹配，得分越高
  ///    - 使用指数衰减函数，避免长文本的绝对位置劣势
  ///
  /// 3. 连续性分数 (权重 0.15)
  ///    - 匹配字符间间隙越小（越连续），得分越高
  ///    - 完美连续匹配得 1.0，随间隙增加呈指数下降
  ///
  /// 4. 长度覆盖率 (权重 0.05)
  ///    - 输入长度占目标长度的比例
  ///    - 防止过短输入获得不合理高分
  ///
  /// 最终得分 = (前缀奖励 × 0.5 + 位置分数 × 0.3 + 连续性分数 × 0.15 + 覆盖率 × 0.05)
  static double _calculateUnifiedScore(
    String input,
    String target,
    List<int> positions,
  ) {
    // 边界情况：空目标或空位置列表，返回最低分
    if (target.isEmpty || positions.isEmpty) return 0.0;

    // 计算四个评分因子的得分
    final double prefixBonus = _calculatePrefixBonus(input, target, positions);
    final double positionScore =
        _calculatePositionPreference(positions, target.length);
    final double continuityScore = _calculateContinuityScore(positions);
    final double lengthCoverage = input.length / target.length;

    // 加权组合所有因子，确保结果在有效范围内
    final double finalScore = prefixBonus * _prefixMatchWeight +
        positionScore * _positionPreferenceWeight +
        continuityScore * _continuityWeight +
        lengthCoverage * _lengthCoverageWeight;

    return finalScore.clamp(0.0, 1.0);
  }

  // ==================== 辅助方法 ====================

  /// 检查位置列表是否连续（每个位置比前一个大1）。
  static bool _isConsecutive(List<int> positions) {
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] != positions[i - 1] + 1) return false;
    }
    return true;
  }

  /// 计算前缀匹配奖励。
  ///
  /// 如果输入是目标字符串的前缀，返回高分。
  /// 前缀匹配比普通匹配更重要。
  static double _calculatePrefixBonus(
      String input, String target, List<int> positions) {
    // 检查是否是完美前缀匹配：匹配位置连续从开头开始且匹配全部输入
    if (positions.length == input.length &&
        positions.isNotEmpty &&
        positions[0] == 0 &&
        _isConsecutive(positions)) {
      return 1.0; // 完美前缀匹配
    }

    // 检查部分前缀匹配：匹配位置连续且从开头开始
    final isPrefixMatch = positions.isNotEmpty &&
        positions[0] == 0 && // 从开头开始
        _isConsecutive(positions); // 连续

    return isPrefixMatch ? 0.8 : 0.0;
  }

  /// 根据位置间隙计算连续性分数。
  ///
  /// 该算法衡量匹配字符的连续程度：
  ///
  /// 1. 计算总间隙：遍历所有相邻匹配位置间的字符数
  ///    间隙 = 后一个位置 - 前一个位置 - 1
  ///    例如：[1,2,4]的间隙为 (2-1-1) + (4-2-1) = 0 + 1 = 1
  ///
  /// 2. 应用指数衰减：间隙为0时得分为1.0，随间隙增加呈指数下降
  ///    得分 = 1.0 / (1.0 + 总间隙 × 衰减因子)
  ///
  /// 这种设计使得连续匹配获得最高分，分散匹配得分较低。
  static double _calculateContinuityScore(List<int> positions) {
    // 边界情况：单个字符或空列表，认为是完美连续
    if (positions.length <= 1) return 1.0;

    // 计算所有相邻匹配位置间的间隙总和
    int totalCharacterGaps = 0;
    for (int i = 1; i < positions.length; i++) {
      final int charactersBetweenMatches =
          positions[i] - positions[i - 1] - 1; // -1是因为连续位置间应相差1
      totalCharacterGaps += charactersBetweenMatches;
    }

    // 间隙越小得分越高，使用指数衰减函数
    final double continuityScore =
        1.0 / (1.0 + totalCharacterGaps * _gapDecayFactor);

    return continuityScore.clamp(0.0, 1.0);
  }

  /// 计算位置偏好分数。
  ///
  /// 该算法偏好在目标字符串中出现较早的匹配，通过以下步骤计算：
  ///
  /// 1. 计算起始位置得分：匹配序列第一个字符的位置
  ///    得分 = 1.0 / (1.0 + 起始位置 × 衰减因子)
  ///    起始位置为0时得分为1.0，随位置增加呈指数下降
  ///
  /// 2. 计算平均位置得分：所有匹配位置的平均值
  ///    得分 = 1.0 / (1.0 + 平均位置 × 衰减因子)
  ///    衰减速度比起始位置稍慢
  ///
  /// 3. 组合两个得分：起始位置权重更高，因为它更重要
  ///    最终得分 = 起始得分 × 0.7 + 平均得分 × 0.3
  ///
  /// 这种设计确保了匹配越早开始且位置越集中，得分越高。
  static double _calculatePositionPreference(
      List<int> positions, int targetLength) {
    // 边界情况：目标为空或无匹配位置
    if (targetLength == 0 || positions.isEmpty) return 0.0;

    // 提取关键位置指标
    final int startPosition = positions[0]; // 匹配序列的起始位置

    // 计算所有匹配位置的平均值
    int sumOfPositions = 0;
    for (final position in positions) {
      sumOfPositions += position;
    }
    final double averageMatchPosition = sumOfPositions / positions.length;

    // 计算起始位置得分：越靠前得分越高
    final double startScore =
        1.0 / (1.0 + startPosition * _startPositionDecayFactor);

    // 计算平均位置得分：衰减速度稍慢
    final double averageScore =
        1.0 / (1.0 + averageMatchPosition * _averagePositionDecayFactor);

    // 组合两个得分，起始位置权重更高
    final double combinedScore = startScore * _startPositionWeight +
        averageScore * _averagePositionWeight;

    return combinedScore.clamp(0.0, 1.0);
  }
}
