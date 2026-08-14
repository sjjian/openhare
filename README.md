<p align="center">
  <img src="./logo_full.png" alt="logo"/>
</p>

openhare is an AI-powered, cross-platform desktop SQL client with multi-database support, built for everyday development, data analysis, and DBA management workflows.

<p align="center">
  <a href="https://github.com/sjjian/openhare/stargazers"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/sjjian/openhare?style=flat-square"/></a>
  <a href="./LICENSE"><img alt="License" src="https://img.shields.io/github/license/sjjian/openhare?style=flat-square"/></a>
  <a href="https://github.com/sjjian/openhare/releases"><img alt="GitHub all releases" src="https://img.shields.io/github/downloads/sjjian/openhare/total?style=flat-square"/></a>
  <a href="https://github.com/sjjian/openhare/releases"><img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/sjjian/openhare?style=flat-square"/></a>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-supported-000000?style=flat-square&logo=apple"/>
  <img alt="Windows" src="https://img.shields.io/badge/Windows-supported-0078D6?style=flat-square&logo=windows"/>
  <img alt="Linux" src="https://img.shields.io/badge/Linux-supported-FCC624?style=flat-square&logo=linux&logoColor=black"/>
</p>

<p align="center">
  <img src="./product.png" alt="openhare product screenshot" width="800"/>
</p>

<p align="center">
  <strong>English</strong> | <a href="./README.zh-CN.md">简体中文</a>
</p>

## Support
1. [How to Install and Update the Application](https://github.com/sjjian/openhare/discussions/76)

## Key Features
- **Lightweight & Native**: Download, install, and run in seconds — no WebView or bundled browser engine. Built with Flutter for a native desktop UI and a lean memory footprint.
- **AI-Powered Assistance**: Write, optimize, and understand SQL with built-in AI — high-risk statements are flagged and require your confirmation before execution.
- **Multi-Database Support**: Connect to MySQL, PostgreSQL, SQL Server, SQLite, DuckDB, Oracle, MongoDB, Redis, and more.
- **Cross-Platform**: Native experience on Windows, macOS, and Linux.
- **Fully Open Source**: Licensed under the [Apache License 2.0](./LICENSE) — transparent and community-driven.

## Database

Database drivers are implemented in [`pkg/db_driver/go_impl`](./pkg/db_driver/go_impl) and invoked from the Flutter client through Dart FFI.

| Icon | Database | Go driver |
| --- | --- | --- |
| <img src="./client/assets/icons/mysql_icon.png" width="28" alt="MySQL"> | MySQL | [go-sql-driver/mysql](https://github.com/go-sql-driver/mysql) |
| <img src="./client/assets/icons/pg_icon.png" width="28" alt="PostgreSQL"> | PostgreSQL | [jackc/pgx](https://github.com/jackc/pgx) |
| <img src="./client/assets/icons/mssql_icon.png" width="28" alt="SQL Server"> | SQL Server | [microsoft/go-mssqldb](https://github.com/microsoft/go-mssqldb) |
| <img src="./client/assets/icons/sqlite_icon.png" width="28" alt="SQLite"> | SQLite | [mattn/go-sqlite3](https://github.com/mattn/go-sqlite3) |
| <img src="./client/assets/icons/duckdb_icon.png" width="28" alt="DuckDB"> | DuckDB | [duckdb/duckdb-go](https://github.com/duckdb/duckdb-go) |
| <img src="./client/assets/icons/oracle_icon.png" width="28" alt="Oracle"> | Oracle | [sijms/go-ora](https://github.com/sijms/go-ora) |
| <img src="./client/assets/icons/mongodb_icon.png" width="28" alt="MongoDB"> | MongoDB | [bytebase/gomongo](https://github.com/bytebase/gomongo), [mongodb/mongo-go-driver](https://github.com/mongodb/mongo-go-driver) |
| <img src="./client/assets/icons/redis_icon.png" width="28" alt="Redis"> | Redis | [redis/go-redis](https://github.com/redis/go-redis) |

**Note:** MongoDB syntax is intended to be mongosh-compatible; for what is actually supported, refer to [gomongo](https://github.com/bytebase/gomongo).

## Framework
1. Application: [Flutter](https://flutter.dev/)
2. State Management: [Riverpod](https://riverpod.dev/), [GoRouter](https://pub.dev/packages/go_router)
3. UI: [SQL Editor](https://github.com/reqable/re-editor), [HugeIcons](https://github.com/hugeicons/hugeicons-flutter), [Window Manager](https://github.com/leanflutter/window_manager)
4. Storage: [ObjectBox](https://objectbox.io/)

## Star History
[![Star History Chart](https://star-history.dera.page/svg?repos=sjjian/openhare&type=date&legend=top-left)](https://star-history.dera.page/#sjjian/openhare&type=date&legend=top-left)