#!/usr/bin/env python3
"""用 sqlglot AST 为 trainset JSONL 标注 object_spans。

按 AST 角色与源码位置写 span；Dart 用 ModelToken.start 附着
（命中用类型，未命中用 <OBJ>）。

start / end 均为含尾字符的下标（闭区间 [start, end]）。
例如 "id" 在 "SELECT id" 中为 start=7, end=8。
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import sqlglot
    from sqlglot import exp
except ImportError:
    print("sqlglot missing; pip install -r requirements.txt", file=sys.stderr)
    sys.exit(1)

_ROOT = Path(__file__).resolve().parents[1]
_DIALECTS = ("mysql", "postgres", "tsql", "sqlite", "bigquery")


def role_for_identifier(node: exp.Expression) -> str:
    p = node.parent
    while p is not None:
        if isinstance(p, exp.TableAlias):
            return "alias"
        if isinstance(p, exp.Alias) and p.args.get("alias") is node:
            return "alias"
        if isinstance(p, exp.CTE):
            alias = p.args.get("alias")
            if alias is node or (
                isinstance(alias, exp.TableAlias) and alias.this is node
            ):
                return "alias"
        if isinstance(p, exp.ColumnDef) and p.this is node:
            return "column"
        if isinstance(p, exp.Column):
            if p.this is node:
                return "column"
            if p.args.get("table") is node:
                return "table"
            if p.args.get("db") is node or p.args.get("catalog") is node:
                return "database"
            return "column"
        if isinstance(p, exp.Table):
            if p.this is node:
                return "table"
            if p.args.get("db") is node or p.args.get("catalog") is node:
                return "database"
            return "table"
        if isinstance(p, exp.Schema):
            gp = p.parent
            if isinstance(gp, (exp.Insert, exp.Replace)):
                return "column"
            if p.this is node:
                return "table"
            return "column"
        if isinstance(p, exp.Create) and p.this is node:
            return "table"
        if isinstance(p, (exp.Dot, exp.Identifier)):
            p = p.parent
            continue
        break
    return "object"


def annotate_sql(sql: str) -> list[dict] | None:
    tree = None
    for dialect in _DIALECTS:
        try:
            tree = sqlglot.parse_one(sql, read=dialect)
            break
        except Exception:
            continue
    if tree is None:
        return None

    hits: list[tuple[int, int, str]] = []
    for node in tree.walk():
        if not isinstance(node, exp.Identifier):
            continue
        meta = node.meta or {}
        start = meta.get("start")
        end = meta.get("end")
        if start is None or end is None:
            continue
        hits.append((int(start), int(end), role_for_identifier(node)))

    hits.sort(key=lambda x: x[0])
    out: list[dict] = []
    seen: set[int] = set()
    for start, end, role in hits:
        if start in seen:
            continue
        seen.add(start)
        out.append({"start": start, "end": end, "role": role})
    return out


def annotate_jsonl(path: Path) -> dict:
    lines = path.read_text(encoding="utf-8").splitlines()
    out_lines: list[str] = []
    ok = 0
    empty = 0
    failed = 0
    role_counts: dict[str, int] = {}

    for line in lines:
        raw = line.strip()
        if not raw:
            continue
        row = json.loads(raw)
        sql = (row.get("sql") or "").strip()
        if not sql:
            out_lines.append(json.dumps(row, ensure_ascii=False))
            continue
        spans = annotate_sql(sql)
        if spans is None:
            failed += 1
            row.pop("object_roles", None)
            row.pop("object_spans", None)
        elif not spans:
            empty += 1
            row.pop("object_roles", None)
            row.pop("object_spans", None)
        else:
            ok += 1
            row["object_spans"] = spans
            row.pop("object_roles", None)
            for s in spans:
                r = s["role"]
                role_counts[r] = role_counts.get(r, 0) + 1
        out_lines.append(json.dumps(row, ensure_ascii=False))

    path.write_text("\n".join(out_lines) + ("\n" if out_lines else ""), encoding="utf-8")
    return {
        "annotated": ok,
        "empty_roles": empty,
        "parse_failed": failed,
        "role_counts": dict(sorted(role_counts.items(), key=lambda kv: -kv[1])),
    }


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "jsonl",
        nargs="?",
        default=str(_ROOT / "data/trainset/sqls.jsonl"),
        help="trainset sqls.jsonl path",
    )
    args = ap.parse_args()
    jsonl = Path(args.jsonl)
    if not jsonl.is_file():
        print(f"jsonl not found: {jsonl}", file=sys.stderr)
        sys.exit(1)

    stats = annotate_jsonl(jsonl)
    # 相对包根输出，避免把本机绝对路径带进日志或 manifest。
    try:
        shown = jsonl.resolve().relative_to(_ROOT)
    except ValueError:
        shown = jsonl
    print(json.dumps({"file": str(shown), **stats}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
