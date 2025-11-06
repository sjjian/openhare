/// A fuzzy string matching library for Dart/Flutter.
///
/// Provides various matching strategies including prefix matching, substring
/// matching, camelCase matching, and acronym matching.
library fuzzy_match;

/// The type of match found.
enum MatchType {
  /// Exact match (not considered a match in this library).
  exact,

  /// Prefix match - the input is a prefix of the target string.
  prefix,

  /// Substring match - the input appears anywhere in the target string.
  substring,

  /// CamelCase match - matches camelCase naming patterns.
  camelCase,

  /// Acronym match - matches acronym patterns like "getElementById".
  acronym,

  /// Fuzzy match - matches characters in sequence.
  fuzzy,

  /// No match found.
  none,
}

/// The result of a fuzzy match operation.
class FuzzyMatchResult {
  /// Whether a match was found.
  final bool matched;

  /// The type of match found.
  final MatchType matchType;

  /// The match score (0.0 to 1.0), higher is better.
  final double score;

  /// The positions where the input characters were matched in the target.
  final List<int>? matchPositions;

  const FuzzyMatchResult({
    required this.matched,
    required this.matchType,
    required this.score,
    this.matchPositions,
  });

  /// Creates a result for no match.
  const FuzzyMatchResult.noMatch()
      : matched = false,
        matchType = MatchType.none,
        score = 0.0,
        matchPositions = null;

  /// Creates a result for an exact match.
  const FuzzyMatchResult.exact()
      : matched = false,
        matchType = MatchType.exact,
        score = 1.0,
        matchPositions = null;

  @override
  String toString() =>
      'FuzzyMatchResult(matched: $matched, type: $matchType, score: $score)';
}

/// A utility class for fuzzy string matching.
///
/// This class provides various matching strategies to find strings that
/// approximately match a given input pattern.
///
/// Matching strategies (in order of priority):
/// 1. Prefix match - highest priority
/// 2. Substring match
/// 3. CamelCase match
/// 4. Acronym match
///
/// All matching is case-insensitive by default. Exact matches are not
/// considered valid matches.
///
/// Example usage:
/// ```dart
/// // Simple boolean match
/// bool result = FuzzyMatch.match('abc', 'abcdef');
///
/// // Get detailed result
/// FuzzyMatchResult result = FuzzyMatch.matchWithResult('abc', 'abcdef');
/// print(result.matchType); // MatchType.prefix
/// print(result.score); // 0.5
/// ```
class FuzzyMatch {
  FuzzyMatch._();

  /// Checks if the input matches the target string.
  ///
  /// Returns `true` if a match is found, `false` otherwise.
  ///
  /// This is an optimized version that only checks for matches without
  /// calculating scores or positions. Use [matchWithResult] if you need
  /// detailed match information.
  ///
  /// - [input] - The search pattern to match.
  /// - [target] - The target string to search in.
  ///
  /// Example:
  /// ```dart
  /// FuzzyMatch.match('abc', 'abcdef'); // true (prefix match)
  /// FuzzyMatch.match('def', 'abcdef'); // true (substring match)
  /// FuzzyMatch.match('gebi', 'getElementById'); // true (camelCase match)
  /// ```
  static bool match(String input, String target) {
    // Empty input doesn't match
    if (input.isEmpty) {
      return false;
    }

    // Check exact match (not considered a match)
    if (target == input) {
      return false;
    }

    final String normalizedInput = input.toLowerCase();
    final String normalizedTarget = target.toLowerCase();

    // 1. Prefix match (fastest check)
    if (normalizedTarget.startsWith(normalizedInput)) {
      return true;
    }

    // 2. Substring match (fast check)
    if (normalizedTarget.contains(normalizedInput)) {
      return true;
    }

    // 3. Quick check for camelCase/acronym - only if target has uppercase letters
    bool hasUppercase = false;
    for (int i = 0; i < target.length; i++) {
      final charCode = target.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) { // A-Z
        hasUppercase = true;
        break;
      }
    }

    // Only do expensive matching if target has uppercase letters or separators
    if (hasUppercase || normalizedTarget.contains('_') || 
        normalizedTarget.contains('-') || normalizedTarget.contains(' ')) {
      // Quick camelCase check - verify first character matches
      if (normalizedTarget[0] == normalizedInput[0]) {
        final positions = _findFuzzyMatchPositions(normalizedTarget, normalizedInput);
        if (positions != null) {
          return true;
        }
      }

      // Quick acronym check
      final segments = _extractSegments(target);
      if (segments.length > 1) {
        final positions = _matchSegments(segments, normalizedInput);
        if (positions != null) {
          return true;
        }
      } else if (segments.length == 1) {
        final positions = _findFuzzyMatchPositions(
            segments[0].toLowerCase(), normalizedInput);
        if (positions != null) {
          return true;
        }
      }
    }

    return false;
  }

  /// Performs fuzzy matching and returns detailed result information.
  ///
  /// - [input] - The search pattern to match.
  /// - [target] - The target string to search in.
  ///
  /// Returns a [FuzzyMatchResult] containing match information.
  ///
  /// Example:
  /// ```dart
  /// final result = FuzzyMatch.matchWithResult('abc', 'abcdef');
  /// print(result.matched); // true
  /// print(result.matchType); // MatchType.prefix
  /// print(result.score); // 0.5
  /// ```
  static FuzzyMatchResult matchWithResult(String input, String target) {
    // Empty input doesn't match
    if (input.isEmpty) {
      return const FuzzyMatchResult.noMatch();
    }

    // Check exact match (not considered a match)
    if (target == input) {
      return const FuzzyMatchResult.exact();
    }

    final String normalizedInput = input.toLowerCase();
    final String normalizedTarget = target.toLowerCase();

    // 1. Prefix match (highest priority)
    if (normalizedTarget.startsWith(normalizedInput)) {
      return FuzzyMatchResult(
        matched: true,
        matchType: MatchType.prefix,
        score: _calculatePrefixScore(input, target),
        matchPositions: List.generate(
          input.length,
          (i) => i,
        ),
      );
    }

    // 2. Substring match
    if (normalizedTarget.contains(normalizedInput)) {
      final index = normalizedTarget.indexOf(normalizedInput);
      return FuzzyMatchResult(
        matched: true,
        matchType: MatchType.substring,
        score: _calculateSubstringScore(input, target, index),
        matchPositions: List.generate(
          input.length,
          (i) => index + i,
        ),
      );
    }

    // 3. CamelCase match
    final camelCaseResult = _matchCamelCase(target, input);
    if (camelCaseResult.matched) {
      return camelCaseResult;
    }

    // 4. Acronym match
    final acronymResult = _matchAcronym(target, input);
    if (acronymResult.matched) {
      return acronymResult;
    }

    return const FuzzyMatchResult.noMatch();
  }

  /// Matches camelCase patterns.
  ///
  /// Example: input="gebi", target="getElementById" -> true (g-e-b-i)
  static FuzzyMatchResult _matchCamelCase(String target, String input) {
    final String normalizedInput = input.toLowerCase();
    final String normalizedTarget = target.toLowerCase();

    final positions = _findFuzzyMatchPositions(normalizedTarget, normalizedInput);
    if (positions != null) {
      return FuzzyMatchResult(
        matched: true,
        matchType: MatchType.camelCase,
        score: _calculateFuzzyScore(input, target, positions),
        matchPositions: positions,
      );
    }

    return const FuzzyMatchResult.noMatch();
  }

  /// Matches acronym patterns.
  ///
  /// Example: input="geid", target="getElementById" -> true (g-e-i-d)
  static FuzzyMatchResult _matchAcronym(String target, String input) {
    final String normalizedInput = input.toLowerCase();

    // Extract word segments (split by uppercase letters, underscores, hyphens, spaces)
    final segments = _extractSegments(target);

    // If only one segment, use fuzzy match
    if (segments.length == 1) {
      final normalizedTarget = target.toLowerCase();
      final positions =
          _findFuzzyMatchPositions(normalizedTarget, normalizedInput);
      if (positions != null) {
        return FuzzyMatchResult(
          matched: true,
          matchType: MatchType.acronym,
          score: _calculateFuzzyScore(input, target, positions),
          matchPositions: positions,
        );
      }
      return const FuzzyMatchResult.noMatch();
    }

    // Multi-segment match: check if input matches each segment's prefix
    // Example: "gebi" matches "getElementById" -> g-e-b-i
    final positions = _matchSegments(segments, normalizedInput);
    if (positions != null) {
      return FuzzyMatchResult(
        matched: true,
        matchType: MatchType.acronym,
        score: _calculateAcronymScore(input, target, positions),
        matchPositions: positions,
      );
    }

    return const FuzzyMatchResult.noMatch();
  }

  /// Extracts word segments from a string.
  ///
  /// Splits on uppercase letters, underscores, hyphens, and spaces.
  static List<String> _extractSegments(String word) {
    final List<String> segments = [];
    final StringBuffer currentSegment = StringBuffer();

    for (int i = 0; i < word.length; i++) {
      final int charCode = word.codeUnitAt(i);
      if (charCode == 32 || charCode == 95 || charCode == 45) {
        // space, _, -
        if (currentSegment.isNotEmpty) {
          segments.add(currentSegment.toString());
          currentSegment.clear();
        }
      } else if (i > 0 && charCode >= 65 && charCode <= 90) {
        // A-Z (camelCase boundary)
        if (currentSegment.isNotEmpty) {
          segments.add(currentSegment.toString());
          currentSegment.clear();
        }
        currentSegment.write(word[i]);
      } else {
        currentSegment.write(word[i]);
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment.toString());
    }

    return segments;
  }

  /// Matches input against segments.
  static List<int>? _matchSegments(
    List<String> segments,
    String input,
  ) {
    final List<int> positions = [];
    int inputIndex = 0;
    int absoluteIndex = 0;

    for (final String segment in segments) {
      if (inputIndex >= input.length) {
        break;
      }
      final String normalizedSegment = segment.toLowerCase();

      // Try to match current segment (from first character, can match consecutive chars)
      int segmentIndex = 0;
      final int segmentStartIndex = absoluteIndex;

      while (inputIndex < input.length &&
          segmentIndex < normalizedSegment.length &&
          input[inputIndex] == normalizedSegment[segmentIndex]) {
        positions.add(segmentStartIndex + segmentIndex);
        inputIndex++;
        segmentIndex++;
      }

      // If current segment didn't match any character, fail
      if (segmentIndex == 0) {
        return null;
      }

      absoluteIndex += segment.length;
    }

    if (inputIndex == input.length) {
      return positions;
    }

    return null;
  }

  /// Finds positions where input characters appear in sequence in target.
  ///
  /// Returns a list of positions if all characters are found in order,
  /// or `null` if not.
  static List<int>? _findFuzzyMatchPositions(
    String target,
    String input,
  ) {
    if (input.isEmpty) return [];
    if (target.length < input.length) return null;

    final List<int> positions = [];
    int inputIndex = 0;
    int targetIndex = 0;

    while (inputIndex < input.length && targetIndex < target.length) {
      if (input[inputIndex] == target[targetIndex]) {
        positions.add(targetIndex);
        inputIndex++;
      }
      targetIndex++;
    }

    if (inputIndex == input.length) {
      return positions;
    }

    return null;
  }

  /// Calculates a score for prefix matches (0.0 to 1.0).
  static double _calculatePrefixScore(String input, String target) {
    if (target.isEmpty) return 0.0;
    return input.length / target.length;
  }

  /// Calculates a score for substring matches (0.0 to 1.0).
  static double _calculateSubstringScore(
    String input,
    String target,
    int index,
  ) {
    if (target.isEmpty) return 0.0;
    // Prefer matches closer to the start
    final positionFactor = 1.0 - (index / target.length) * 0.3;
    final lengthFactor = input.length / target.length;
    return lengthFactor * positionFactor;
  }

  /// Calculates a score for fuzzy matches (0.0 to 1.0).
  static double _calculateFuzzyScore(
    String input,
    String target,
    List<int> positions,
  ) {
    if (target.isEmpty || positions.isEmpty) return 0.0;

    final lengthScore = input.length / target.length;
    final continuityScore = _calculateContinuityScore(positions);
    final positionScore = _calculatePositionScore(positions, target.length);

    return (lengthScore * 0.4 + continuityScore * 0.4 + positionScore * 0.2)
        .clamp(0.0, 1.0);
  }

  /// Calculates a score for acronym matches (0.0 to 1.0).
  static double _calculateAcronymScore(
    String input,
    String target,
    List<int> positions,
  ) {
    return _calculateFuzzyScore(input, target, positions) * 1.1;
  }

  /// Calculates continuity score based on position gaps.
  static double _calculateContinuityScore(List<int> positions) {
    if (positions.length <= 1) return 1.0;

    int gaps = 0;
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] != positions[i - 1] + 1) {
        gaps++;
      }
    }

    return 1.0 / (1.0 + gaps);
  }

  /// Calculates position score (prefer matches at the start).
  static double _calculatePositionScore(List<int> positions, int targetLength) {
    if (targetLength == 0 || positions.isEmpty) return 0.0;
    final avgPosition = positions.reduce((a, b) => a + b) / positions.length;
    return 1.0 - (avgPosition / targetLength) * 0.5;
  }
}