/// 训练 / 评测 / 数据集 API（tool 与 test 使用）。
///
/// 含 `dart:io`、Trainer、数据集与 Checkpoint 读写。应用运行时请用 [sql_complete.dart]。
library;

export 'package:sql_parser/parser.dart' show DialectType;

export 'src/tokenize.dart';
export 'src/nn.dart';
export 'src/fuzzy_match.dart';
export 'src/complete.dart';
export 'src/dataset.dart';
export 'src/train.dart';
export 'src/checkpoint.dart';
