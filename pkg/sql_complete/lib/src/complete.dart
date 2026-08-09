import 'package:sql_parser/parser.dart';

import 'checkpoint.dart';
import 'fuzzy_match.dart';
import 'tokenize.dart';

/// 单条补全候选（纯数据，无 Flutter）。
class SqlCompleteItem {
  final String text;
  final SqlCompleteKind kind;
  final double score;
  final List<int>? matchPositions;

  const SqlCompleteItem({
    required this.text,
    required this.kind,
    required this.score,
    this.matchPositions,
  });

  @override
  String toString() => '$kind:$text(${score.toStringAsFixed(4)})';
}

/// 补全请求：光标上下文（方言由 [SqlCompletionEngine.dialect] 决定）。
class SqlCompletionRequest {
  /// 跨行光标前完整前缀。
  final String sqlPrefix;

  /// 当前行光标前文本。
  final String lineBefore;

  /// 当前行光标后文本；与 [lineBefore] 拼接后在光标位置判是否在字符串内。
  final String lineAfter;

  const SqlCompletionRequest({
    required this.sqlPrefix,
    required this.lineBefore,
    this.lineAfter = '',
  });
}

/// 补全结果；[items] 为空表示不弹窗。
class SqlCompletionResult {
  final String input;
  final List<SqlCompleteItem> items;

  const SqlCompletionResult({
    required this.input,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
}

/// catalog 中的一条可联想对象/关键字。
class SqlCompleteCatalogEntry {
  final String text;
  final SqlCompleteKind kind;

  const SqlCompleteCatalogEntry({
    required this.text,
    required this.kind,
  });
}

/// 由 client 从 metadata / 关键字表填好后传入引擎。
class SqlCompleteCatalog {
  final List<SqlCompleteCatalogEntry> keywords;
  final List<SqlCompleteCatalogEntry> objects;
  final Map<String, List<SqlCompleteCatalogEntry>> related;

  const SqlCompleteCatalog({
    this.keywords = const [],
    this.objects = const [],
    this.related = const {},
  });

  static const empty = SqlCompleteCatalog();

  /// 关键字 + 扁平对象，供半截词模糊。
  Iterable<SqlCompleteCatalogEntry> get allFlat sync* {
    yield* keywords;
    yield* objects;
  }
}

bool _isAllDigits(String s) {
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c < 48 || c > 57) return false;
  }
  return true;
}

/// 标识符字符：`[A-Za-z0-9_]`。
bool _isIdentChar(int c) =>
    (c >= 65 && c <= 90) ||
    (c >= 97 && c <= 122) ||
    (c >= 48 && c <= 57) ||
    c == 95;

/// SQL 补全决策入口。
///
/// 方言固定在引擎上（扫描与模型切词共用）；换方言请 [copyWith] 或新建引擎。
///
/// ```
/// 有半截词：
///   A = 模型 top-K（占位符展开）∩ fuzzy(input)
///   B = 全量 catalog（点号则 related）∩ fuzzy(input)
///   结果 = dedupe(A 在前 + B 在后)
/// 无半截词：
///   不进 fuzzy；仅模型展开 / 点号 related 全集
/// ```
///
/// 半截词从当前语句末尾取出，并从预测前缀中剥掉。
class SqlCompletionEngine {
  final SqlNextTokenPredictor? predictor;
  final SqlCompleteCatalog catalog;
  final int topK;
  final int maxItems;

  /// 单个占位符最多展开多少 catalog 条目（经半截词过滤后截断）。
  final int maxExpandPerPrediction;

  /// 方言：影响 `"…"` 是否为字符串、转义/注释，以及模型 [TokenExtractor]。
  final DialectType dialect;

  /// 预测抛错回调；补全回退到 catalog fuzzy。
  final void Function(Object error, StackTrace stackTrace)? onPredictError;

  /// [predictor] 显式注入（单测 / 自定义模型）。否则当 [enableModel] 为 true 时
  /// 加载包内预置权重；加载失败则无模型。
  SqlCompletionEngine({
    SqlNextTokenPredictor? predictor,
    this.catalog = SqlCompleteCatalog.empty,
    this.topK = 24,
    this.maxItems = 100,
    this.maxExpandPerPrediction = 64,
    this.dialect = DialectType.mysql,
    this.onPredictError,
    bool enableModel = true,
  }) : predictor = predictor ??
            (enableModel
                ? tryLoadBundledCheckpoint()?.toPredictor(dialect: dialect)
                : null);

  /// [catalog] 未换方言时复用 [predictor]；换 [dialect] 且当前有模型时按预置权重重建。
  SqlCompletionEngine copyWith({
    SqlCompleteCatalog? catalog,
    DialectType? dialect,
    int? topK,
    int? maxItems,
    int? maxExpandPerPrediction,
    void Function(Object error, StackTrace stackTrace)? onPredictError,
    SqlNextTokenPredictor? predictor,
  }) {
    final nextDialect = dialect ?? this.dialect;
    final dialectChanged = nextDialect != this.dialect;
    final SqlNextTokenPredictor? nextPredictor;
    if (predictor != null) {
      nextPredictor = predictor;
    } else if (!dialectChanged) {
      nextPredictor = this.predictor;
    } else if (this.predictor != null) {
      nextPredictor =
          tryLoadBundledCheckpoint()?.toPredictor(dialect: nextDialect);
    } else {
      nextPredictor = null;
    }
    return SqlCompletionEngine(
      predictor: nextPredictor,
      catalog: catalog ?? this.catalog,
      topK: topK ?? this.topK,
      maxItems: maxItems ?? this.maxItems,
      maxExpandPerPrediction:
          maxExpandPerPrediction ?? this.maxExpandPerPrediction,
      dialect: nextDialect,
      onPredictError: onPredictError ?? this.onPredictError,
      enableModel: false,
    );
  }

  SqlCompletionResult complete(SqlCompletionRequest request) {
    final lineBefore = request.lineBefore;
    final sqlPrefix = request.sqlPrefix;

    // 字符串判断：光标前当前语句 + lineAfter，在光标偏移处取样。
    final statement = currentStatementPrefix(sqlPrefix, dialect: dialect);
    final stringProbe = statement.isNotEmpty ? statement : lineBefore;
    if (isInsideString(stringProbe, after: request.lineAfter, dialect: dialect)) {
      return const SqlCompletionResult(input: '', items: []);
    }

    // 半截词从当前语句取，并从 predictPrefix 剥离。
    final input = extractInput(statement);
    final isDot = isDotContext(statement);
    final related = _relatedEntries(statement);

    // 纯数字半截词按数字字面量处理：`WHERE id = 12` 不该弹出名字里带 12 的对象。
    if (input.isNotEmpty && !isDot && _isAllDigits(input)) {
      return const SqlCompletionResult(input: '', items: []);
    }

    final predictPrefix =
        statement.substring(0, statement.length - input.length).trimRight();

    // 当前语句为空 ↔ 空输入，不弹窗。
    if (predictPrefix.isEmpty && input.isEmpty) {
      return const SqlCompletionResult(input: '', items: []);
    }

    final hasPartial = input.isNotEmpty;
    final modelItems = <SqlCompleteItem>[];
    final catalogItems = <SqlCompleteItem>[];
    final seen = <String>{};

    void addModel(SqlCompleteItem item) {
      final key = item.text.toLowerCase();
      if (!seen.add(key)) return;
      modelItems.add(item);
    }

    void addCatalog(SqlCompleteItem item) {
      final key = item.text.toLowerCase();
      if (!seen.add(key)) return;
      catalogItems.add(item);
    }

    // A：模型 top-K（有半截词则 fuzzy）
    final p = predictor;
    if (p != null) {
      try {
        for (final pred in p.predict(predictPrefix, topK: topK)) {
          final placeholderKind =
              TokenExtractor.kindOfObjectPlaceholder(pred.token);
          if (placeholderKind != null) {
            var expanded = 0;
            for (final e in _expandPool(placeholderKind)) {
              final match = hasPartial
                  ? _fuzzyMatch(input, e.text)
                  : (1.0, null);
              if (match == null) continue;
              addModel(SqlCompleteItem(
                text: e.text,
                kind: e.kind,
                score: pred.score,
                matchPositions: match.$2,
              ));
              if (++expanded >= maxExpandPerPrediction) break;
            }
            continue;
          }
          if (isModelPlaceholder(pred.token)) continue;
          final match = hasPartial
              ? _fuzzyMatch(input, pred.token)
              : (1.0, null);
          if (match == null) continue;
          addModel(SqlCompleteItem(
            text: pred.token,
            kind: pred.kind == SqlCompleteKind.keyword
                ? SqlCompleteKind.keyword
                : SqlCompleteKind.object,
            score: pred.score,
            matchPositions: match.$2,
          ));
        }
      } catch (e, st) {
        onPredictError?.call(e, st);
      }
    }

    // B：全量 catalog fuzzy（仅有半截词；点号空词给 related 全集）
    if (!hasPartial) {
      if (isDot) {
        for (final e in related) {
          addCatalog(SqlCompleteItem(text: e.text, kind: e.kind, score: 1.0));
        }
      }
    } else {
      final pool = isDot ? related : catalog.allFlat;
      for (final e in pool) {
        final match = _fuzzyMatch(input, e.text);
        if (match == null) continue;
        addCatalog(SqlCompleteItem(
          text: e.text,
          kind: e.kind,
          score: match.$1,
          matchPositions: match.$2,
        ));
      }
    }

    modelItems.sort(_byScoreThenLength);
    catalogItems.sort(_byScoreThenLength);
    // 模型在前，catalog fuzzy 在后；seen 已去重。
    var scored = [...modelItems, ...catalogItems];

    if (isDot) {
      if (related.isEmpty) {
        return SqlCompletionResult(input: input, items: const []);
      }
      final allow = {for (final e in related) e.text.toLowerCase()};
      scored = [
        for (final i in scored)
          if (allow.contains(i.text.toLowerCase())) i,
      ];
    }

    return SqlCompletionResult(
      input: input,
      items: scored.take(maxItems).toList(),
    );
  }

  /// 占位符展开池：按 kind 过滤；`<OBJ>` 优先表/库；alias → 表。
  Iterable<SqlCompleteCatalogEntry> _expandPool(SqlCompleteKind want) sync* {
    if (want == SqlCompleteKind.object) {
      final rest = <SqlCompleteCatalogEntry>[];
      for (final e in catalog.objects) {
        if (e.kind == SqlCompleteKind.table || e.kind == SqlCompleteKind.database) {
          yield e;
        } else {
          rest.add(e);
        }
      }
      yield* rest;
      return;
    }
    for (final e in catalog.objects) {
      if (_objectKindMatches(want, e.kind)) yield e;
    }
  }

  /// 半截词匹配：委托 [FuzzyMatch]。[input] 须非空。
  static (double, List<int>?)? _fuzzyMatch(String input, String candidate) {
    final fuzzy = FuzzyMatch.matchWithResult(input, candidate);
    if (!fuzzy.matched) return null;
    return (fuzzy.score, fuzzy.matchPositions);
  }

  static int _byScoreThenLength(SqlCompleteItem a, SqlCompleteItem b) {
    final c = b.score.compareTo(a.score);
    if (c != 0) return c;
    return a.text.length.compareTo(b.text.length);
  }

  /// related 键为小写；qualifier 做 exact 查找（避免 t1 吃掉 t1_1）。
  List<SqlCompleteCatalogEntry> _relatedEntries(String beforeCursor) {
    final parent = qualifierBeforeDot(beforeCursor);
    if (parent == null || parent.isEmpty) return const [];
    return catalog.related[parent.toLowerCase()] ?? const [];
  }

  /// 当前语句 = 最后一个「裸」`;` 之后的文本（忽略字符串/注释/标识符引号内的分号）；
  /// 只去左侧空白，保留尾部半截词/空格。
  static String currentStatementPrefix(
    String sqlPrefix, {
    DialectType dialect = DialectType.mysql,
  }) {
    final i = lastBareSemicolon(sqlPrefix, dialect: dialect);
    final raw = i < 0 ? sqlPrefix : sqlPrefix.substring(i + 1);
    return raw.replaceFirst(RegExp(r'^\s+'), '');
  }

  /// 光标是否在字符串字面量内。
  ///
  /// 扫描 [before] + [after]，在 `before.length` 处取样
  ///（例如 `SELECT '|` + `x'` 判为串内）。
  static bool isInsideString(
    String before, {
    String after = '',
    DialectType dialect = DialectType.mysql,
  }) {
    return _sqlScan(before + after, dialect: dialect, stopAt: before.length)
        .inString;
  }

  /// 最后一个不在字符串/注释/标识符引号内的 `;` 下标；没有则 -1。
  static int lastBareSemicolon(
    String sql, {
    DialectType dialect = DialectType.mysql,
  }) {
    return _sqlScan(sql, dialect: dialect).lastBareSemicolon;
  }

  static bool _objectKindMatches(SqlCompleteKind want, SqlCompleteKind got) {
    if (want == SqlCompleteKind.object) return true;
    // catalog 通常不收录 alias；别名按表展开。
    if (want == SqlCompleteKind.alias) {
      return got == SqlCompleteKind.alias || got == SqlCompleteKind.table;
    }
    return want == got;
  }

  static bool isModelPlaceholder(String token) =>
      token.startsWith('<') && token.endsWith('>');

  static bool isDotContext(String beforeCursor) {
    if (beforeCursor.isEmpty) return false;
    if (beforeCursor.endsWith('.')) return true;
    if (beforeCursor.length < 2) return false;
    final i = beforeCursor.lastIndexOf('.');
    if (i < 0) return false;
    for (var j = i + 1; j < beforeCursor.length; j++) {
      if (!_isIdentChar(beforeCursor.codeUnitAt(j))) return false;
    }
    return true;
  }

  static String? qualifierBeforeDot(String beforeCursor) {
    final i = beforeCursor.lastIndexOf('.');
    if (i <= 0) return null;
    return extractWordBefore(beforeCursor, i);
  }

  static String extractInput(String beforeCursor) {
    if (beforeCursor.isEmpty || beforeCursor.endsWith('.')) return '';
    return extractWordBefore(beforeCursor, beforeCursor.length);
  }

  static String extractWordBefore(String s, int endOffset) {
    var start = endOffset - 1;
    for (; start >= 0; start--) {
      if (!_isIdentChar(s.codeUnitAt(start))) break;
    }
    return s.substring(start + 1, endOffset);
  }

  /// MySQL/SQLite：`"` 是字符串；PG/Oracle/MSSQL：`"` 是标识符。
  static bool _doubleQuoteIsString(DialectType dialect) =>
      dialect == DialectType.mysql ||
      dialect == DialectType.sqlite ||
      dialect == DialectType.redis ||
      dialect == DialectType.mongodb;

  static bool _backslashEscapes(DialectType dialect) =>
      dialect == DialectType.mysql || dialect == DialectType.sqlite;

  static bool _hashLineComment(DialectType dialect) =>
      dialect == DialectType.mysql || dialect == DialectType.sqlite;

  static _SqlScanSnapshot _sqlScan(
    String sql, {
    required DialectType dialect,
    int? stopAt,
  }) {
    final doubleIsString = _doubleQuoteIsString(dialect);
    final backslashEscapes = _backslashEscapes(dialect);
    final hashComment = _hashLineComment(dialect);
    final end = stopAt ?? sql.length;

    var inSingle = false;
    var inDoubleString = false;
    var inIdentDouble = false;
    var inBacktick = false;
    var inBracket = false;
    var inLineComment = false;
    var inBlockComment = false;
    var lastBareSemicolon = -1;

    bool inString() => inSingle || inDoubleString;
    bool inCode() =>
        !inString() &&
        !inIdentDouble &&
        !inBacktick &&
        !inBracket &&
        !inLineComment &&
        !inBlockComment;

    for (var i = 0; i < sql.length && i < end; i++) {
      final c = sql[i];
      final next = i + 1 < sql.length ? sql[i + 1] : '';

      if (inLineComment) {
        if (c == '\n') inLineComment = false;
        continue;
      }
      if (inBlockComment) {
        if (c == '*' && next == '/') {
          inBlockComment = false;
          i++;
        }
        continue;
      }

      if (inSingle) {
        if (backslashEscapes && c == r'\' && i + 1 < sql.length) {
          i++;
          continue;
        }
        if (c == "'") {
          // 标准 SQL：'' 转义
          if (next == "'") {
            i++;
          } else {
            inSingle = false;
          }
        }
        continue;
      }

      if (inDoubleString) {
        if (backslashEscapes && c == r'\' && i + 1 < sql.length) {
          i++;
          continue;
        }
        if (c == '"') {
          if (next == '"') {
            i++;
          } else {
            inDoubleString = false;
          }
        }
        continue;
      }

      if (inIdentDouble) {
        if (c == '"') {
          if (next == '"') {
            i++;
          } else {
            inIdentDouble = false;
          }
        }
        continue;
      }

      if (inBacktick) {
        if (c == '`') {
          if (next == '`') {
            i++;
          } else {
            inBacktick = false;
          }
        }
        continue;
      }

      if (inBracket) {
        if (c == ']') inBracket = false;
        continue;
      }

      // --- 代码态 ---
      if (c == '-' && next == '-') {
        inLineComment = true;
        i++;
        continue;
      }
      if (hashComment && c == '#') {
        inLineComment = true;
        continue;
      }
      if (c == '/' && next == '*') {
        inBlockComment = true;
        i++;
        continue;
      }
      if (c == "'") {
        inSingle = true;
        continue;
      }
      if (c == '"') {
        if (doubleIsString) {
          inDoubleString = true;
        } else {
          inIdentDouble = true;
        }
        continue;
      }
      if (c == '`') {
        inBacktick = true;
        continue;
      }
      if (c == '[' && dialect == DialectType.mssql) {
        inBracket = true;
        continue;
      }
      if (c == ';' && inCode()) {
        lastBareSemicolon = i;
      }
    }

    // stopAt 处的状态即光标处状态。
    return _SqlScanSnapshot(
      inString: inString(),
      lastBareSemicolon: lastBareSemicolon,
    );
  }
}

class _SqlScanSnapshot {
  final bool inString;
  final int lastBareSemicolon;

  const _SqlScanSnapshot({
    required this.inString,
    required this.lastBareSemicolon,
  });
}
