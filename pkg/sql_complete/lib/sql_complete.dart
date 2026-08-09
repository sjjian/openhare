/// SQL 补全库：基于 [sql_parser] 词法分析 + 纯 Dart Causal Attn 下一词模型。
///
/// 运行时入口。训练 / 评测请用 [training.dart]。
/// 预置模型由 [SqlCompletionEngine] 加载；方言挂在引擎上，与 [SqlCompletionRequest] 无关。
library;

export 'package:sql_parser/parser.dart' show DialectType;

export 'src/tokenize.dart' show SqlCompleteKind;
export 'src/fuzzy_match.dart' show FuzzyMatch, FuzzyMatchResult, MatchType;
export 'src/complete.dart'
    show
        SqlCompleteItem,
        SqlCompletionRequest,
        SqlCompletionResult,
        SqlCompleteCatalogEntry,
        SqlCompleteCatalog,
        SqlCompletionEngine;
