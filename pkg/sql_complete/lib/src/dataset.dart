import 'dart:convert';
import 'dart:io';

import 'tokenize.dart';

/// 一条 SQL 训练样本（由 Python `tool/build_trainset.py` 写入 trainset）。
class SqlSample {
  final String sql;
  final String? source;
  final Map<String, dynamic> meta;

  /// sqlglot 按源码位置给出的对象角色（闭区间，见 [ObjectRoleSpan]）。
  ///
  /// 训练时按 [ModelToken.start] 附着：命中用类型，未命中目标为 `<OBJ>`。
  final List<ObjectRoleSpan> objectSpans;

  const SqlSample({
    required this.sql,
    this.source,
    this.meta = const {},
    this.objectSpans = const [],
  });

  factory SqlSample.fromJson(Map<String, dynamic> map) {
    final sql = map['sql']?.toString();
    if (sql == null || sql.trim().isEmpty) {
      throw FormatException('SqlSample missing sql: $map');
    }
    return SqlSample(
      sql: sql.trim(),
      source: map['source']?.toString(),
      meta: (map['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
      objectSpans: [
        for (final sp in (map['object_spans'] as List?) ?? const [])
          if (sp is Map) ObjectRoleSpan.fromJson(Map<String, dynamic>.from(sp)),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'sql': sql,
        if (source != null) 'source': source,
        if (meta.isNotEmpty) 'meta': meta,
        if (objectSpans.isNotEmpty)
          'object_spans': [for (final sp in objectSpans) sp.toJson()],
      };
}

/// 原 SQL 某一标识符上的对象角色（源码偏移闭区间）。
///
/// [start] / [end] 均为含尾字符的下标，区间为 `[start, end]`（`0 <= start <= end`）。
/// 附着时用 [contains] 判断 [ModelToken.start] 是否落在区间内。
class ObjectRoleSpan {
  final int start;
  final int end;
  final SqlCompleteKind role;

  ObjectRoleSpan({
    required this.start,
    required this.end,
    required this.role,
  }) : assert(start <= end, 'ObjectRoleSpan: start ($start) > end ($end)');

  /// 由起点与长度构造闭区间：`end = start + length - 1`。
  factory ObjectRoleSpan.fromStartLength({
    required int start,
    required int length,
    required SqlCompleteKind role,
  }) {
    assert(length >= 1, 'ObjectRoleSpan.fromStartLength: length must be >= 1');
    return ObjectRoleSpan(
      start: start,
      end: start + length - 1,
      role: role,
    );
  }

  /// 偏移是否落在闭区间 `[start, end]` 内。
  bool contains(int offset) => offset >= start && offset <= end;

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'role': completeKindToName(role),
      };

  factory ObjectRoleSpan.fromJson(Map<String, dynamic> json) {
    return ObjectRoleSpan(
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
      role: completeKindFromName(json['role']?.toString() ?? 'object'),
    );
  }
}

/// 下一词元监督样本。
class NextTokenExample {
  final List<int> prefixIds;
  final List<ModelToken> prefixTokens;
  final int targetId;
  final SqlCompleteKind targetKind;
  final String sql;

  NextTokenExample({
    required this.prefixIds,
    required this.prefixTokens,
    required this.targetId,
    required this.targetKind,
    required this.sql,
  });
}

/// [SqlCompleteKind] ↔ json 字符串。
String completeKindToName(SqlCompleteKind k) => k.name;

SqlCompleteKind completeKindFromName(String name) {
  return SqlCompleteKind.values.firstWhere(
    (k) => k.name == name,
    orElse: () => SqlCompleteKind.object,
  );
}

/// 加载 trainset / fixture（`sqls.jsonl` / `sqls.txt`）。
///
/// 语料下载与构建见 `tool/build_trainset.py`。
class TrainsetLoader {
  const TrainsetLoader();

  /// JSONL：每行一条 [SqlSample.toJson]。
  Future<List<SqlSample>> loadJsonl(String path, {int? maxSamples}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('trainset jsonl not found: $path');
    }
    final out = <SqlSample>[];
    await for (final line in file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      out.add(SqlSample.fromJson(
        jsonDecode(trimmed) as Map<String, dynamic>,
      ));
      if (maxSamples != null && out.length >= maxSamples) break;
    }
    return out;
  }

  /// 纯文本：每行一条 SQL（无 spans）。
  Future<List<SqlSample>> loadTxt(String path, {int? maxSamples}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('trainset txt not found: $path');
    }
    final out = <SqlSample>[];
    for (final line in await file.readAsLines()) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('--')) continue;
      out.add(SqlSample(sql: t, source: 'plain', meta: {'file': path}));
      if (maxSamples != null && out.length >= maxSamples) break;
    }
    return out;
  }
}
