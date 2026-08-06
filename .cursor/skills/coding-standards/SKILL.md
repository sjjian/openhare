---
name: coding-standards
description: 基于当前仓库现状约束实现阶段的编码规范，覆盖 Dart/Flutter、Go FFI 和 macOS/Linux 平台集成。Use when adding or refactoring code in client, server, pkg, or pkg/db_driver/go_impl, or when the user mentions 编码规范、代码风格、项目约定、Riverpod、ObjectBox、FFI、Podspec、Go bridge.
---

# 编码规范

只保留项目特有的实现约束，不解释框架知识。

## 必须
- 先读当前模块已有实现，再写代码；优先局部一致，不顺手做无关重构。
- 新代码跟随所在目录现状；Dart 文件用 `snake_case`。
- `client` 继续按 `models`、`repositories`、`services` 分层：页面不直接承载持久化、连接、查询逻辑。
- 设计页面时优先复用 `client/lib/widgets/` 中已有封装，不先新增重复组件。
- `client` 的状态逻辑优先接入现有 provider 链路；ObjectBox 细节留在仓储层。
- go_impl 库里使用`./vendor-patch.sh`代替`go mod vendor`更新库；改了 `impl.go` 的 `//export` 或 C 头相关声明时先跑仓库根目录 `make go_impl_generate`，再 `flutter clean` 后构建客户端，避免仍链接 DerivedData 里旧的 `libgo_impl.a`。

## 不要
- 不要把别的模块的写法硬搬到当前目录。
- 不要在页面层、单个 provider 或单个 service 里塞完整业务闭环。
- 不要把 `client` 特有假设下沉到 `pkg/sql_parser`、`pkg/db_driver`、`server`。
- 不要手改 generated 文件、`go_impl` 绑定文件或 `src/vendor`，除非任务明确要求。
- **禁止**手改 `client/lib/repositories/objectbox-model.json`；ObjectBox schema 变更只改 `@Entity()` 实体后跑 `dart run build_runner build`，property id / uid 由生成器决定。
- 在对某个文件进行变更时，禁止未经注明将一个文件内的内容拆分到另一个新文件。
- 不要删除我已经加过的注释，他们都有非常重要的作用。

## 收尾检查
- 是否保持了当前目录既有职责边界。
- 是否误改 generated 或 vendor 文件。
