import 'dart:math';

import 'package:sql_parser/parser.dart';

/// 补全建议类型。
///
/// 词法标注仅产出 [keyword] / [object]；
/// [database] / [table] / [column] / [alias] 供 catalog / UI 细分类。
enum SqlCompleteKind {
  keyword,
  object,
  database,
  table,
  column,
  alias,
}

/// 用于建模的规范化词元（已去掉空白/注释）。
class ModelToken {
  final TokenType type;
  final String surface;
  final String normalized;

  /// 补全目标类型；运算符/字面量等为 null（不作为预测目标）。
  final SqlCompleteKind? kind;

  /// 在原 SQL 中的起始下标（[Pos.cursor]）；无位置信息时为 null。
  final int? start;

  const ModelToken({
    required this.type,
    required this.surface,
    required this.normalized,
    this.kind,
    this.start,
  });

  ModelToken copyWith({
    TokenType? type,
    String? surface,
    String? normalized,
    SqlCompleteKind? kind,
    int? start,
    bool clearKind = false,
  }) {
    return ModelToken(
      type: type ?? this.type,
      surface: surface ?? this.surface,
      normalized: normalized ?? this.normalized,
      kind: clearKind ? null : (kind ?? this.kind),
      start: start ?? this.start,
    );
  }

  /// 标识符 / 引号包裹名（词法层面的对象名）。
  bool get isObjectName {
    if (type == TokenType.ident) return true;
    if (type == TokenType.backQValue || type == TokenType.bracketValue) {
      return true;
    }
    if (type == TokenType.doubleQValue && !normalized.startsWith('<')) {
      return true;
    }
    return false;
  }

  /// 有补全类型的词元才作为预测目标。
  bool get isPredictTarget => kind != null;

  @override
  String toString() => '${kind ?? type}:$normalized';
}

/// 使用 [sql_parser] 将 SQL 切分为建模词元，并标注补全类型。
class TokenExtractor {
  final DialectType dialect;

  /// 将对象折叠为 `<OBJ>`（训练与推理输入共用）。
  final bool collapseObjects;

  const TokenExtractor({
    this.dialect = DialectType.mysql,
    this.collapseObjects = false,
  });

  static const objectToken = '<OBJ>';
  static const tableToken = '<TABLE>';
  static const columnToken = '<COLUMN>';
  static const databaseToken = '<DATABASE>';

  /// 训练输出用的对象类占位符（输入前缀折叠为 [objectToken]）。
  static const objectPlaceholders = <String>{
    objectToken,
    tableToken,
    columnToken,
    databaseToken,
  };

  /// [SqlCompleteKind] → 输出占位符。
  ///
  /// alias → `<TABLE>`（catalog 不收录别名，按表展开）。
  static String outputPlaceholderFor(SqlCompleteKind kind) {
    switch (kind) {
      case SqlCompleteKind.table:
      case SqlCompleteKind.alias:
        return tableToken;
      case SqlCompleteKind.column:
        return columnToken;
      case SqlCompleteKind.database:
        return databaseToken;
      case SqlCompleteKind.object:
      case SqlCompleteKind.keyword:
        return objectToken;
    }
  }

  /// 占位符 → 细分类；非对象占位返回 null。
  static SqlCompleteKind? kindOfObjectPlaceholder(String token) {
    switch (token) {
      case tableToken:
        return SqlCompleteKind.table;
      case columnToken:
        return SqlCompleteKind.column;
      case databaseToken:
        return SqlCompleteKind.database;
      case objectToken:
        return SqlCompleteKind.object;
      default:
        return null;
    }
  }

  /// 仅按词法类型打标：关键字 / 对象名。
  static List<ModelToken> tagCompleteKinds(List<ModelToken> tokens) {
    return [
      for (final t in tokens)
        if (t.type == TokenType.keyword)
          t.copyWith(kind: SqlCompleteKind.keyword)
        else if (t.isObjectName)
          t.copyWith(kind: SqlCompleteKind.object)
        else
          t.copyWith(clearKind: true),
    ];
  }

  /// 输入侧对象折叠为 `<OBJ>`。
  static ModelToken collapseObjectForInput(ModelToken t) {
    switch (t.kind) {
      case SqlCompleteKind.object:
      case SqlCompleteKind.table:
      case SqlCompleteKind.column:
      case SqlCompleteKind.database:
      case SqlCompleteKind.alias:
        return t.copyWith(
          normalized: objectToken,
          kind: SqlCompleteKind.object,
        );
      case SqlCompleteKind.keyword:
      case null:
        return t;
    }
  }

  List<ModelToken> extract(String sql) {
    final lexer = createLexer(dialect, sql);
    var out = <ModelToken>[];
    for (final tok in lexer.tokens()) {
      if (tok.id == TokenType.eof) continue;
      if (tok.id == TokenType.whitespace) continue;
      if (tok.id == TokenType.comment) continue;
      if (tok.id == TokenType.invalid) continue;

      final surface = tok.content;
      final normalized = _normalize(tok);
      out.add(ModelToken(
        type: tok.id,
        surface: surface,
        normalized: normalized,
        start: tok.startPos.cursor,
      ));
    }
    out = tagCompleteKinds(out);
    if (collapseObjects) {
      out = [for (final t in out) collapseObjectForInput(t)];
    }
    return out;
  }

  String _normalize(Token tok) {
    switch (tok.id) {
      case TokenType.keyword:
        return tok.content.toLowerCase();
      case TokenType.ident:
        return tok.content.toLowerCase();
      case TokenType.backQValue:
      case TokenType.bracketValue:
        return _stripQuotes(tok.content).toLowerCase();
      case TokenType.doubleQValue:
        return _stripQuotes(tok.content).toLowerCase();
      case TokenType.number:
        return '<NUM>';
      case TokenType.singleQValue:
        return '<STR>';
      default:
        return tok.content;
    }
  }

  String _stripQuotes(String s) {
    if (s.length >= 2) {
      final a = s.codeUnitAt(0);
      final b = s.codeUnitAt(s.length - 1);
      if ((a == 96 && b == 96) ||
          (a == 39 && b == 39) ||
          (a == 34 && b == 34) ||
          (a == 91 && b == 93)) {
        return s.substring(1, s.length - 1);
      }
    }
    return s;
  }
}

/// 词元词表，含特殊符号与频次截断。
class Vocabulary {
  static const String pad = '<PAD>';
  static const String unk = '<UNK>';
  static const String bos = '<BOS>';
  static const String eos = '<EOS>';

  final Map<String, int> tokenToId;
  final List<String> idToToken;

  Vocabulary._(this.tokenToId, this.idToToken);

  factory Vocabulary.empty() {
    final tokenToId = <String, int>{
      pad: 0,
      unk: 1,
      bos: 2,
      eos: 3,
    };
    final idToToken = [pad, unk, bos, eos];
    return Vocabulary._(tokenToId, idToToken);
  }

  factory Vocabulary.fromTokenSequences(
    Iterable<List<ModelToken>> sequences, {
    int minFreq = 1,
    int? maxSize,
  }) {
    final counts = <String, int>{};
    for (final seq in sequences) {
      for (final t in seq) {
        counts.update(t.normalized, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    final sorted = counts.entries.where((e) => e.value >= minFreq).toList()
      ..sort((a, b) {
        final byFreq = b.value.compareTo(a.value);
        if (byFreq != 0) return byFreq;
        return a.key.compareTo(b.key);
      });

    final vocab = Vocabulary.empty();
    final limit = maxSize == null ? sorted.length : max(0, maxSize - vocab.size);
    for (final e in sorted.take(limit)) {
      vocab._add(e.key);
    }
    return vocab;
  }

  int get size => idToToken.length;

  int get unkId => tokenToId[unk]!;

  void _add(String token) {
    if (tokenToId.containsKey(token)) return;
    tokenToId[token] = idToToken.length;
    idToToken.add(token);
  }

  /// 强制加入 token（不受 maxSize / 频次限制）。
  void ensureToken(String token) => _add(token);

  int encodeToken(String token) => tokenToId[token] ?? unkId;

  List<int> encode(List<ModelToken> tokens) {
    return [for (final t in tokens) encodeToken(t.normalized)];
  }

  String decodeId(int id) {
    if (id < 0 || id >= idToToken.length) return unk;
    return idToToken[id];
  }

  Map<String, dynamic> toJson() => {
        'tokens': idToToken,
      };

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    final tokens = (json['tokens'] as List).cast<String>();
    final tokenToId = <String, int>{};
    for (var i = 0; i < tokens.length; i++) {
      tokenToId[tokens[i]] = i;
    }
    return Vocabulary._(tokenToId, List<String>.from(tokens));
  }
}