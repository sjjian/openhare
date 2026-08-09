import 'package:sql_complete/training.dart';

/// 测试用：按 Dart 词法对象顺序生成 [ObjectRoleSpan]（生产语料由 sqlglot 写 spans）。
///
/// span 为闭区间 `[start, end]`。
SqlSample sampleWithSpans(
  String sql,
  List<SqlCompleteKind> roles, {
  String? source,
}) {
  const extractor = TokenExtractor();
  final tokens = extractor.extract(sql);
  final spans = <ObjectRoleSpan>[];
  var oi = 0;
  for (final t in tokens) {
    if (t.kind == null || t.kind == SqlCompleteKind.keyword) continue;
    if (oi >= roles.length) break;
    final start = t.start;
    if (start == null) {
      oi++;
      continue;
    }
    spans.add(ObjectRoleSpan.fromStartLength(
      start: start,
      length: t.surface.length,
      role: roles[oi],
    ));
    oi++;
  }
  return SqlSample(sql: sql, source: source, objectSpans: spans);
}
