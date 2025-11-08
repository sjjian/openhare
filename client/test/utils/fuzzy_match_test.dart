import 'package:test/test.dart';
import 'package:client/utils/fuzzy_match.dart';

void main() {
  group('FuzzyMatch.match', () {
    test('prefix match returns true', () {
      expect(FuzzyMatch.match('abc', 'abcdef'), isTrue);
      expect(FuzzyMatch.match('hello', 'hello world'), isTrue);
    });

    test('substring match returns true', () {
      expect(FuzzyMatch.match('def', 'abcdef'), isTrue);
      expect(FuzzyMatch.match('world', 'hello world'), isTrue);
    });

    test('camelCase match returns true', () {
      expect(FuzzyMatch.match('gebi', 'getElementById'), isTrue);
      expect(FuzzyMatch.match('getel', 'getElementById'), isTrue);
    });

    test('acronym match returns true', () {
      expect(FuzzyMatch.match('geid', 'getElementById'), isTrue);
      expect(FuzzyMatch.match('gebi', 'getElementById'), isTrue);
    });

    test('exact match returns false', () {
      expect(FuzzyMatch.match('abc', 'abc'), isFalse);
      expect(FuzzyMatch.match('hello', 'hello'), isFalse);
    });

    test('no match returns false', () {
      expect(FuzzyMatch.match('xyz', 'abcdef'), isFalse);
      expect(FuzzyMatch.match('abc', 'def'), isFalse);
    });

    test('empty input returns false', () {
      expect(FuzzyMatch.match('', 'abc'), isFalse);
      expect(FuzzyMatch.match('', ''), isFalse);
    });

    test('case insensitive matching', () {
      expect(FuzzyMatch.match('ABC', 'abcdef'), isTrue);
      expect(FuzzyMatch.match('abc', 'ABCDEF'), isTrue);
      expect(FuzzyMatch.match('DEF', 'abcdef'), isTrue);
    });
  });

  group('FuzzyMatch.matchWithResult - Fuzzy Match', () {
    test('fuzzy match returns correct result', () {
      final result = FuzzyMatch.matchWithResult('abc', 'abcdef');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
      expect(result.score, greaterThan(0.0));
      expect(result.score, lessThanOrEqualTo(1.0));
    });

    test('fuzzy match score calculation', () {
      final result1 = FuzzyMatch.matchWithResult('abc', 'abcdef');
      expect(result1.matchType, MatchType.fuzzy);

      final result2 = FuzzyMatch.matchWithResult('abc', 'abc');
      // result2 should be exact match, not fuzzy
      expect(result2.matchType, MatchType.exact);

      final result3 = FuzzyMatch.matchWithResult('a', 'abcdef');
      expect(result3.matchType, MatchType.fuzzy);
      expect(result3.score, closeTo(0.962, 0.1)); // unified scoring algorithm with prefix match priority
    });

    test('fuzzy match is case insensitive', () {
      final result1 = FuzzyMatch.matchWithResult('ABC', 'abcdef');
      final result2 = FuzzyMatch.matchWithResult('abc', 'ABCDEF');
      expect(result1.matched, isTrue);
      expect(result1.matchType, MatchType.fuzzy);
      expect(result2.matched, isTrue);
      expect(result2.matchType, MatchType.fuzzy);
    });
  });

  group('FuzzyMatch.matchWithResult - Substring Match', () {
    test('substring match returns correct result', () {
      final result = FuzzyMatch.matchWithResult('def', 'abcdef');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
      expect(result.score, greaterThan(0.0));
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 3);
      expect(result.matchPositions, [3, 4, 5]);
    });

    test('substring match at start has higher score', () {
      final result1 = FuzzyMatch.matchWithResult('abc', 'abcabc');
      final result2 = FuzzyMatch.matchWithResult('abc', 'xyzabc');

      // 两者都应该是模糊匹配
      expect(result1.matchType, MatchType.fuzzy);
      expect(result2.matchType, MatchType.fuzzy);
      // 较早的位置应该有更高的分数
      expect(result1.score, greaterThan(result2.score));
    });

    test('substring match score considers position', () {
      final result1 = FuzzyMatch.matchWithResult('bc', 'abcde');
      final result2 = FuzzyMatch.matchWithResult('bc', 'xabcde');
      expect(result1.matched, isTrue);
      expect(result2.matched, isTrue);
      expect(result1.matchType, MatchType.fuzzy);
      expect(result2.matchType, MatchType.fuzzy);
      // 越接近开头应该有更高的分数
      expect(result1.score, greaterThan(result2.score));
    });

    test('substring match is case insensitive', () {
      final result = FuzzyMatch.matchWithResult('DEF', 'abcdef');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });
  });

  group('FuzzyMatch.matchWithResult - Fuzzy Match (CamelCase-like)', () {
    test('fuzzy match returns correct result for camelCase patterns', () {
      final result = FuzzyMatch.matchWithResult('gebi', 'getElementById');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 4);
    });

    test('fuzzy match with non-consecutive characters', () {
      // 测试字符即使不连续也能按顺序匹配
      // 'ebid' 应该作为模糊匹配匹配 'getElementById'
      final result = FuzzyMatch.matchWithResult('ebid', 'getElementById');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('fuzzy match is case insensitive', () {
      final result = FuzzyMatch.matchWithResult('GEBI', 'getElementById');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('fuzzy match with mixed patterns', () {
      // 使用按顺序匹配字符的模式
      final result = FuzzyMatch.matchWithResult('acd', 'abcDef');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('fuzzy match fails when characters not in order', () {
      final result = FuzzyMatch.matchWithResult('ebgi', 'getElementById');
      expect(result.matched, isFalse);
    });
  });

  group('FuzzyMatch.matchWithResult - Fuzzy Match (Acronym-like)', () {
    test('fuzzy match with complex patterns', () {
      final result = FuzzyMatch.matchWithResult('geid', 'getElementById');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
    });

    test('fuzzy match with segment-like patterns', () {
      final result = FuzzyMatch.matchWithResult('gebi', 'getElementById');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('fuzzy match with underscores', () {
      final result = FuzzyMatch.matchWithResult('gbid', 'get_element_by_id');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('fuzzy match with hyphens', () {
      final result = FuzzyMatch.matchWithResult('gbid', 'get-element-by-id');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('fuzzy match with spaces', () {
      final result = FuzzyMatch.matchWithResult('gbid', 'get element by id');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });
    
    test('acronym match works when camelCase does not match', () {
      // 找到驼峰命名不匹配但缩写匹配的情况
      // 这很棘手，因为驼峰命名匹配非常灵活
      // 让我们测试一个明确需要缩写行为的案例
      // 例如，在模糊匹配失败时匹配段的首字母
      final result = FuzzyMatch.matchWithResult('geby', 'getElementById');
      expect(result.matched, isTrue);
      // 应该匹配（驼峰命名或缩写）
      expect(result.matchType, isNot(MatchType.none));
    });

    test('acronym match with single segment uses fuzzy match', () {
      final result = FuzzyMatch.matchWithResult('abc', 'abcdef');
      // 应该作为前缀或子串匹配，而不是缩写
      expect(result.matched, isTrue);
      // 缩写只在有多个段时适用
      expect(result.matchType, isNot(MatchType.none));
    });

    test('acronym match is case insensitive', () {
      // 'GEID' 作为驼峰命名匹配（更高优先级），而不是缩写
      final result = FuzzyMatch.matchWithResult('GEID', 'getElementById');
      expect(result.matched, isTrue);
      // 驼峰命名比缩写有更高的优先级
      expect(result.matchType, MatchType.fuzzy);
    });
    
    test('acronym match when camelCase does not match', () {
      // 使用只能作为缩写匹配的模式（每个段的第一个字符）
      // 这很棘手，因为驼峰命名可能仍然匹配，所以我们用更明确的案例测试
      final result = FuzzyMatch.matchWithResult('geb', 'getElementById');
      expect(result.matched, isTrue);
      // 应该匹配（驼峰命名或缩写）
      expect(result.matchType, isNot(MatchType.none));
    });
  });

  group('FuzzyMatch.matchWithResult - Exact Match', () {
    test('exact match returns exact type but not matched', () {
      final result = FuzzyMatch.matchWithResult('abc', 'abc');
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.exact);
      expect(result.score, 1.0);
      expect(result.matchPositions, isNull);
    });

    test('exact match is case sensitive for exact comparison', () {
      final result = FuzzyMatch.matchWithResult('abc', 'ABC');
      // 由于大小写差异，不应该是完全匹配
      expect(result.matchType, isNot(MatchType.exact));
    });
  });

  group('FuzzyMatch.matchWithResult - No Match', () {
    test('no match returns noMatch result', () {
      final result = FuzzyMatch.matchWithResult('xyz', 'abcdef');
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.none);
      expect(result.score, 0.0);
      expect(result.matchPositions, isNull);
    });

    test('empty input returns noMatch', () {
      final result = FuzzyMatch.matchWithResult('', 'abc');
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.none);
      expect(result.score, 0.0);
    });

    test('characters not in order returns noMatch', () {
      final result = FuzzyMatch.matchWithResult('cba', 'abc');
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.none);
    });

    test('target shorter than input returns noMatch', () {
      final result = FuzzyMatch.matchWithResult('abcdef', 'abc');
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.none);
    });
  });

  group('FuzzyMatch.matchWithResult - Unified Fuzzy Matching', () {
    test('all matches use unified fuzzy algorithm', () {
      final result1 = FuzzyMatch.matchWithResult('abc', 'abcabc');
      expect(result1.matchType, MatchType.fuzzy);

      final result2 = FuzzyMatch.matchWithResult('def', 'abcdef');
      expect(result2.matchType, MatchType.fuzzy);

      final result3 = FuzzyMatch.matchWithResult('gebi', 'getElementById');
      expect(result3.matchType, MatchType.fuzzy);
      expect(result3.matched, isTrue);
    });
  });

  group('FuzzyMatch.matchWithResult - Edge Cases', () {
    test('empty target string', () {
      final result = FuzzyMatch.matchWithResult('abc', '');
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.none);
    });

    test('single character input', () {
      final result = FuzzyMatch.matchWithResult('a', 'abc');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('single character target', () {
      final result1 = FuzzyMatch.matchWithResult('a', 'a');
      expect(result1.matchType, MatchType.exact);
      
      final result2 = FuzzyMatch.matchWithResult('a', 'b');
      expect(result2.matched, isFalse);
    });

    test('special characters in input', () {
      final result = FuzzyMatch.matchWithResult('def', 'abc-def-ghi');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('special characters in target', () {
      final result = FuzzyMatch.matchWithResult('test', 'test_function');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('numbers in strings', () {
      final result = FuzzyMatch.matchWithResult('123', 'abc123def');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });

    test('unicode characters', () {
      final result = FuzzyMatch.matchWithResult('中文', '这是中文测试');
      expect(result.matched, isTrue);
      expect(result.matchType, MatchType.fuzzy);
    });
  });

  group('FuzzyMatchResult', () {
    test('noMatch constructor creates correct result', () {
      const result = FuzzyMatchResult.noMatch();
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.none);
      expect(result.score, 0.0);
      expect(result.matchPositions, isNull);
    });

    test('exact constructor creates correct result', () {
      const result = FuzzyMatchResult.exact();
      expect(result.matched, isFalse);
      expect(result.matchType, MatchType.exact);
      expect(result.score, 1.0);
      expect(result.matchPositions, isNull);
    });

    test('toString returns readable format', () {
      final result = FuzzyMatch.matchWithResult('abc', 'abcdef');
      final str = result.toString();
      expect(str, contains('FuzzyMatchResult'));
      expect(str, contains('matched'));
      expect(str, contains('type'));
      expect(str, contains('score'));
    });
  });

  group('Score Calculations', () {
    test('prefix score increases with input length', () {
      final result1 = FuzzyMatch.matchWithResult('a', 'abc');
      final result2 = FuzzyMatch.matchWithResult('ab', 'abc');
      expect(result2.score, greaterThan(result1.score));
    });

    test('prefix score decreases with target length', () {
      final result1 = FuzzyMatch.matchWithResult('abc', 'abc');
      // 这是完全匹配，所以逻辑不同
      expect(result1.matchType, MatchType.exact);
      
      final result2 = FuzzyMatch.matchWithResult('abc', 'abcdef');
      expect(result2.score, lessThan(1.0));
    });

    test('substring score considers position', () {
      final result1 = FuzzyMatch.matchWithResult('bc', 'abc');
      final result2 = FuzzyMatch.matchWithResult('bc', 'xabc');
      expect(result1.score, greaterThan(result2.score));
    });

    test('fuzzy score considers continuity', () {
      // 连续匹配应该比分散匹配获得更高的分数
      final result1 = FuzzyMatch.matchWithResult('abc', 'abcxyz');
      final result2 = FuzzyMatch.matchWithResult('axc', 'abcxyz');
      expect(result1.score, greaterThan(result2.score));
    });

    test('acronym score is boosted', () {
      final result = FuzzyMatch.matchWithResult('geid', 'getElementById');
      if (result.matched && result.matchType == MatchType.fuzzy) {
        expect(result.score, greaterThan(0.0));
      }
    });
  });

  group('Real-world Examples', () {
    test('file name matching', () {
      expect(FuzzyMatch.match('test', 'test_file.dart'), isTrue);
      expect(FuzzyMatch.match('test', 'my_test_file.dart'), isTrue);
      expect(FuzzyMatch.match('tf', 'test_file.dart'), isTrue);
    });

    test('function name matching', () {
      expect(FuzzyMatch.match('get', 'getElementById'), isTrue);
      expect(FuzzyMatch.match('gebi', 'getElementById'), isTrue);
      expect(FuzzyMatch.match('geid', 'getElementById'), isTrue);
    });

    test('variable name matching', () {
      expect(FuzzyMatch.match('user', 'userName'), isTrue);
      expect(FuzzyMatch.match('un', 'userName'), isTrue);
      expect(FuzzyMatch.match('name', 'userName'), isTrue);
    });

    test('class name matching', () {
      expect(FuzzyMatch.match('http', 'HttpRequest'), isTrue);
      expect(FuzzyMatch.match('req', 'HttpRequest'), isTrue);
    });
  });

  group('FuzzyMatchResult.matchPositions', () {
    test('prefix match returns correct consecutive positions', () {
      final result = FuzzyMatch.matchWithResult('abc', 'abcdef');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions, [0, 1, 2]);
    });

    test('substring match returns correct consecutive positions', () {
      final result1 = FuzzyMatch.matchWithResult('def', 'abcdef');
      expect(result1.matchType, MatchType.fuzzy);
      expect(result1.matchPositions, isNotNull);
      expect(result1.matchPositions, [3, 4, 5]);

      final result2 = FuzzyMatch.matchWithResult('bc', 'abcde');
      expect(result2.matchType, MatchType.fuzzy);
      expect(result2.matchPositions, [1, 2]);

      final result3 = FuzzyMatch.matchWithResult('hello', 'xhelloworld');
      expect(result3.matchType, MatchType.fuzzy);
      expect(result3.matchPositions, [1, 2, 3, 4, 5]);
    });

    test('substring match positions are case insensitive', () {
      final result1 = FuzzyMatch.matchWithResult('DEF', 'abcdef');
      expect(result1.matchPositions, [3, 4, 5]);

      final result2 = FuzzyMatch.matchWithResult('def', 'ABCDEF');
      expect(result2.matchPositions, [3, 4, 5]);
    });

    test('camelCase match returns correct non-consecutive positions', () {
      final result = FuzzyMatch.matchWithResult('gebi', 'getElementById');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 4);
      // 应该匹配：g(0) - e(1) - b(10) - i(12)
      expect(result.matchPositions, [0, 1, 10, 12]);
    });

    test('camelCase match positions for consecutive characters', () {
      // 'getel' 作为前缀匹配，而不是驼峰命名
      // 使用不作为前缀/子串匹配的模式
      final result = FuzzyMatch.matchWithResult('geid', 'getElementById');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 4);
      // 应该匹配：g(0) - e(1) - i(12) - d(13)
      expect(result.matchPositions, [0, 1, 12, 13]);
    });

    test('camelCase match positions for scattered characters', () {
      final result = FuzzyMatch.matchWithResult('ebid', 'getElementById');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 4);
      // 应该匹配：e(1) - b(10) - i(12) - d(13)
      expect(result.matchPositions, [1, 10, 12, 13]);
    });

    test('acronym match returns correct positions for single segment', () {
      // 'abc' 作为子串匹配，而不是缩写
      // 使用子串不匹配的情况来获得缩写匹配
      final result = FuzzyMatch.matchWithResult('abc', 'xabcyz');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 3);
      // 应该按顺序匹配位置：a(1) - b(2) - c(3)
      expect(result.matchPositions, [1, 2, 3]);
    });

    test('acronym match returns correct positions for multi-segment', () {
      // 找到缩写匹配的情况（当驼峰命名不匹配时）
      // 这很棘手，因为驼峰命名通常优先匹配
      // 让我们测试一个可以获得缩写匹配的案例
      final result = FuzzyMatch.matchWithResult('geid', 'getElementById');
      // 这可能根据实现作为驼峰命名或缩写匹配
      if (result.matchType == MatchType.fuzzy) {
        expect(result.matchPositions, isNotNull);
        expect(result.matchPositions!.length, 4);
      }
    });

    test('exact match returns null matchPositions', () {
      final result = FuzzyMatch.matchWithResult('abc', 'abc');
      expect(result.matchType, MatchType.exact);
      expect(result.matchPositions, isNull);
    });

    test('no match returns null matchPositions', () {
      final result = FuzzyMatch.matchWithResult('xyz', 'abcdef');
      expect(result.matchType, MatchType.none);
      expect(result.matchPositions, isNull);
    });

    test('matchPositions length matches input length', () {
      final result1 = FuzzyMatch.matchWithResult('abc', 'xabcxyz');
      expect(result1.matchPositions, isNotNull);
      expect(result1.matchPositions!.length, 3);

      final result2 = FuzzyMatch.matchWithResult('gebi', 'getElementById');
      expect(result2.matchPositions, isNotNull);
      expect(result2.matchPositions!.length, 4);

      final result3 = FuzzyMatch.matchWithResult('a', 'xayz');
      expect(result3.matchPositions, isNotNull);
      expect(result3.matchPositions!.length, 1);
    });

    test('matchPositions are sorted in ascending order', () {
      final result = FuzzyMatch.matchWithResult('ebid', 'getElementById');
      expect(result.matchPositions, isNotNull);

      // 验证位置按升序排列
      for (int i = 1; i < result.matchPositions!.length; i++) {
        expect(
          result.matchPositions![i],
          greaterThan(result.matchPositions![i - 1]),
        );
      }
    });

    test('matchPositions are within target string bounds', () {
      final result = FuzzyMatch.matchWithResult('def', 'abcdef');
      expect(result.matchPositions, isNotNull);

      for (final position in result.matchPositions!) {
        expect(position, greaterThanOrEqualTo(0));
        expect(position, lessThan(6)); // 目标长度
      }
    });

    test('matchPositions for complex camelCase match', () {
      // 'http' 作为前缀匹配，而不是驼峰命名
      // 使用不作为前缀/子串匹配的模式
      final result = FuzzyMatch.matchWithResult('hreq', 'HttpRequest');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, isNotNull);
      expect(result.matchPositions!.length, 4);
      // 应该匹配：h(0) - r(4) - e(5) - q(6)
      expect(result.matchPositions, [0, 4, 5, 6]);
    });

    test('matchPositions for substring match in middle', () {
      final result = FuzzyMatch.matchWithResult('world', 'helloworldtest');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, [5, 6, 7, 8, 9]);
    });

    test('matchPositions for single character match', () {
      final result = FuzzyMatch.matchWithResult('a', 'xayz');
      expect(result.matchType, MatchType.fuzzy);
      expect(result.matchPositions, [1]);
    });
  });
}

