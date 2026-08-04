# sql_complete

基于 [`sql_parser`](../sql_parser) 的 SQL 下一词元补全：词法切词 → 对象折叠 → 纯 Dart Causal Attn 模型。

## 流水线

```
语料 SQL（Python tool/build_trainset.py）
  → 下载 raw → 解析 → 去重
  → sqlglot 产出 object_spans（闭区间，见 ObjectRoleSpan）
  → data/trainset/sqls.jsonl
Dart：
  → TokenExtractor：切词；输入折叠为 <OBJ>
  → 训练目标：span 附着 → <TABLE>/<COLUMN>/…（未附着 → <OBJ>；alias → <TABLE>）
  → Embedding → Causal Attn → Softmax
  → 补全：有半截词时模型 top ∪ catalog 均 fuzzy（模型在前）；无半截词不进 fuzzy
```

## 数据与训练

`data/`、`out/` 不入 git。Dart 只读 `data/trainset/`；单测不依赖 `data/`。

| 路径 | 含义 |
|------|------|
| `data/raw/` | 各数据集原始下载（Python 构建） |
| `data/trainset/` | 混合训练集（`sqls.jsonl` / `sqls.txt` / `manifest.json`） |
| `out/` | checkpoint 与训练日志 |

| `data/raw/` 子目录 | 数据集 |
|--------------------|--------|
| `bird/` | BIRD（建议 `HF_ENDPOINT=https://hf-mirror.com`） |
| `spider2/` | Spider 2.0 gold SQL |
| `spider/` | Spider 1.0（可选，手动放置） |
| `multisql/` | MultiSQL |
| `dbasql/` | DBASQL（Kaggle：`pradnyasawant/dbasql` → `DBASQL.json`） |

上游授权不适合打包分发（MultiSQL 无 LICENSE、BIRD CC BY-SA 4.0、DBASQL 许可不明；Spider 2.0 为 MIT）。

```bash
cd pkg/sql_complete
dart pub get && dart test
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
HF_ENDPOINT=https://hf-mirror.com .venv/bin/python tool/build_trainset.py --download
dart run tool/train.dart --full --epochs=3   # 默认 --export，写入库内权重
dart run tool/train.dart --full --no-export  # 只写 out/，不改库内 data
dart run tool/export.dart                    # 已有 checkpoint 时重嵌
```

`--full` 成功后：写全精度 `out/trainset_model.checkpoint.json`，并截断嵌入
`lib/src/bundled_checkpoint_data.dart`（生成文件，勿手改）。导出经
`tool/export.dart`：无缩进、权重 6 位小数。截断稳定性与预置模型场景抽检由
`dart test`（`bundled_checkpoint_test`）覆盖。磁盘 checkpoint 用
`training.dart` 的 `loadCheckpoint` / `Checkpoint.save`。

语料标注 helper：`tool/annotate_object_roles.py`（由 `build_trainset.py` 调用，也可单独补标）。

## 运行时用法

引擎加载包内预置权重；应用只组 catalog，方言挂在引擎上。

```dart
final engine = SqlCompletionEngine(catalog: catalog, dialect: DialectType.mysql);
final result = engine.complete(SqlCompletionRequest(
  sqlPrefix: 'SELECT ',
  lineBefore: 'SELECT ',
));
```

换库 / 换方言时新建引擎或 `copyWith`。

## 模块（`lib/src/`）

| 文件 | 职责 |
|------|------|
| `tokenize.dart` | 切词、角色、词表 |
| `checkpoint.dart` | Checkpoint / Predictor / bundled loader（无 `dart:io`） |
| `bundled_checkpoint_data.dart` | 生成：嵌入的截断 JSON 常量 |
| `fuzzy_match.dart` | 模糊匹配（半截词 / UI 高亮） |
| `nn.dart` | Tensor、Causal Attn、Adam、模型 |
| `complete.dart` | 补全引擎、catalog |
| `dataset.dart` | `SqlSample` / `TrainsetLoader` |
| `train.dart` | `SqlTokenTrainer`、磁盘 load/save |

## 公开 API

| 入口 | 用途 |
|------|------|
| `package:sql_complete/sql_complete.dart` | 运行时：`SqlCompletionEngine`、Request/Result/Item、Catalog、`SqlCompleteKind`、`DialectType`、`FuzzyMatch` |
| `package:sql_complete/training.dart` | 训练 / 评测 / nn / 数据集 / Checkpoint / bundled loader |

方言只挂在 `SqlCompletionEngine` 上；`SqlCompletionRequest` 仅承载光标上下文。
