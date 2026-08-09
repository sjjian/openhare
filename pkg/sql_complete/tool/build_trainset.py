#!/usr/bin/env python3
"""下载原始语料 → 解析 → 去重 → sqlglot 标注 → data/trainset/。

Dart 只读成品 trainset（sqls.jsonl）。

用法:
  python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
  .venv/bin/python tool/build_trainset.py --download
  .venv/bin/python tool/build_trainset.py              # 仅从已有 raw 构建
  .venv/bin/python tool/build_trainset.py --no-annotate
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.request
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

_ROOT = Path(__file__).resolve().parents[1]
_RAW = _ROOT / "data" / "raw"
_OUT = _ROOT / "data" / "trainset"

# 复用同目录 annotate 逻辑
sys.path.insert(0, str(Path(__file__).resolve().parent))
try:
    from annotate_object_roles import annotate_jsonl
except ImportError:
    annotate_jsonl = None  # type: ignore


def _log(msg: str) -> None:
    print(msg, flush=True)


# ── download ──────────────────────────────────────────────────────────────


def download_bird() -> None:
    out = _RAW / "bird"
    out.mkdir(parents=True, exist_ok=True)
    target = out / "train.jsonl"
    if target.is_file():
        _log(f"[skip] bird already present: {target} ({_count_lines(target)} lines)")
        return
    try:
        from huggingface_hub import hf_hub_download
    except ImportError:
        _log("huggingface_hub missing; pip install -r requirements.txt")
        raise SystemExit(1)
    _log("==> download birdsql/bird23-train-filtered")
    path = hf_hub_download(
        repo_id="birdsql/bird23-train-filtered",
        repo_type="dataset",
        filename="data/train-00000-of-00001.jsonl",
        local_dir=str(out / "hf"),
    )
    target.write_bytes(Path(path).read_bytes())
    _log(f"[ok] bird -> {target} lines={_count_lines(target)}")


def download_spider2() -> None:
    out = _RAW / "spider2"
    repo = out / "repo"
    out.mkdir(parents=True, exist_ok=True)
    if (repo / ".git").is_dir():
        _log(f"[skip] spider2 repo already present: {repo}")
    else:
        _log("==> sparse clone xlang-ai/Spider2 (gold SQL)")
        if repo.exists():
            shutil.rmtree(repo)
        subprocess.run(
            [
                "git",
                "clone",
                "--depth",
                "1",
                "--filter=blob:none",
                "--sparse",
                "https://github.com/xlang-ai/Spider2.git",
                str(repo),
            ],
            check=True,
        )
        subprocess.run(
            [
                "git",
                "-C",
                str(repo),
                "sparse-checkout",
                "set",
                "spider2-lite/evaluation_suite/gold/sql",
                "spider2-snow/evaluation_suite/gold/sql",
            ],
            check=True,
        )
    lite = list(
        (repo / "spider2-lite/evaluation_suite/gold/sql").rglob("*.sql")
    )
    snow = list(
        (repo / "spider2-snow/evaluation_suite/gold/sql").rglob("*.sql")
    )
    _log(f"[ok] spider2 gold SQL: lite={len(lite)} snow={len(snow)}")


def download_multisql() -> None:
    out = _RAW / "multisql"
    out.mkdir(parents=True, exist_ok=True)
    target = out / "total.json"
    if target.is_file():
        _log(f"[skip] multisql already present: {target}")
        return
    url = (
        "https://raw.githubusercontent.com/grandchicken/MultiSQL/"
        "main/Data/total.json"
    )
    _log(f"==> download MultiSQL {url}")
    urllib.request.urlretrieve(url, target)
    _log(f"[ok] multisql -> {target}")


def download_dbasql() -> None:
    out = _RAW / "dbasql"
    out.mkdir(parents=True, exist_ok=True)
    full = out / "DBASQL.json"
    if full.is_file():
        _log(f"[skip] DBASQL.json already present")
        return
    if shutil.which("kaggle"):
        _log("==> kaggle download pradnyasawant/dbasql")
        subprocess.run(
            [
                "kaggle",
                "datasets",
                "download",
                "-d",
                "pradnyasawant/dbasql",
                "-p",
                str(out),
                "--unzip",
            ],
            check=False,
        )
    else:
        _log(
            "[skip] kaggle CLI not found; place DBASQL.json under data/raw/dbasql/ "
            "or install kaggle CLI. See package README (data layout / dbasql)."
        )


def download_all() -> None:
    download_bird()
    download_spider2()
    download_multisql()
    download_dbasql()
    _log("Spider 1.0: place under data/raw/spider/ if needed")


# ── loaders (raw → samples) ───────────────────────────────────────────────


def _sql_of(m: dict) -> str | None:
    for k in (
        "sql",
        "SQL",
        "query",
        "Query",
        "statement",
        "target_text",
        "target",
    ):
        v = m.get(k)
        if isinstance(v, str) and v.strip():
            return v.strip()
    return None


def _norm_key(sql: str) -> str:
    return re.sub(r"\s+", " ", sql.strip()).lower()


def load_bird(path: Path) -> list[dict]:
    files: list[Path] = []
    if path.is_file():
        files = [path]
    elif path.is_dir():
        for name in (
            "train.jsonl",
            "train.json",
            "dev.json",
            "dev.jsonl",
            "bird23-train-filtered.jsonl",
        ):
            f = path / name
            if f.is_file():
                files.append(f)
        if not files:
            for f in path.rglob("*"):
                if not f.is_file():
                    continue
                low = f.name.lower()
                if low.endswith((".json", ".jsonl")) and "table" not in low:
                    files.append(f)
    out: list[dict] = []
    for f in files:
        out.extend(_load_json_or_jsonl(f, source="bird"))
    return out


def load_spider(path: Path) -> list[dict]:
    files: list[Path] = []
    if path.is_file():
        files = [path]
    elif path.is_dir():
        for name in (
            "train_spider.json",
            "train_others.json",
            "dev.json",
            "train.json",
        ):
            f = path / name
            if f.is_file():
                files.append(f)
    out: list[dict] = []
    for f in files:
        raw = json.loads(f.read_text(encoding="utf-8"))
        if not isinstance(raw, list):
            continue
        for item in raw:
            if not isinstance(item, dict):
                continue
            sql = item.get("query") or item.get("sql") or item.get("SQL")
            if not isinstance(sql, str) or not sql.strip():
                continue
            meta = {"file": str(f)}
            if item.get("db_id") is not None:
                meta["db_id"] = item["db_id"]
            if item.get("question") is not None:
                meta["question"] = item["question"]
            out.append({"sql": sql.strip(), "source": "spider", "meta": meta})
    return out


def _split_statements(sql: str) -> list[str]:
    out: list[str] = []
    buf: list[str] = []
    in_single = in_double = in_back = False
    for ch in sql:
        if ch == "'" and not in_double and not in_back:
            in_single = not in_single
            buf.append(ch)
            continue
        if ch == '"' and not in_single and not in_back:
            in_double = not in_double
            buf.append(ch)
            continue
        if ch == "`" and not in_single and not in_double:
            in_back = not in_back
            buf.append(ch)
            continue
        if ch == ";" and not in_single and not in_double and not in_back:
            s = "".join(buf).strip()
            buf.clear()
            if s:
                out.append(s)
            continue
        buf.append(ch)
    tail = "".join(buf).strip()
    if tail:
        out.append(tail)
    return out or [sql]


def load_spider2(path: Path, max_sql_chars: int = 8000) -> list[dict]:
    candidates = [
        path,
        path / "gold" / "sql",
        path / "sql",
        path / "spider2-lite" / "evaluation_suite" / "gold" / "sql",
        path / "spider2-snow" / "evaluation_suite" / "gold" / "sql",
        path / "repo" / "spider2-lite" / "evaluation_suite" / "gold" / "sql",
        path / "repo" / "spider2-snow" / "evaluation_suite" / "gold" / "sql",
    ]
    dirs: list[Path] = []
    seen: set[str] = set()
    for c in candidates:
        if not c.is_dir():
            continue
        has_sql = any(p.suffix.lower() == ".sql" for p in c.iterdir() if p.is_file())
        if not has_sql:
            continue
        key = str(c.resolve())
        if key in seen:
            continue
        seen.add(key)
        dirs.append(c)

    out: list[dict] = []
    for d in dirs:
        low = str(d).replace("\\", "/").lower()
        variant = (
            "snow"
            if "spider2-snow" in low
            else "lite"
            if "spider2-lite" in low
            else "gold"
        )
        for f in d.rglob("*.sql"):
            sql = f.read_text(encoding="utf-8", errors="ignore").strip()
            if not sql:
                continue
            if len(sql) > max_sql_chars:
                sql = sql[:max_sql_chars]
            parts = _split_statements(sql)
            for i, part in enumerate(parts):
                meta: dict = {"variant": variant, "file": f.name}
                if len(parts) > 1:
                    meta["stmt_index"] = i
                out.append({"sql": part, "source": "spider2", "meta": meta})
    return out


def load_multisql(path: Path) -> list[dict]:
    if path.is_file():
        file = path
    else:
        file = None
        for c in (path / "total.json", path / "Data" / "total.json", path / "data" / "total.json"):
            if c.is_file():
                file = c
                break
        if file is None:
            raise FileNotFoundError(f"MultiSQL total.json not found under {path}")
    raw = json.loads(file.read_text(encoding="utf-8"))
    if not isinstance(raw, list):
        raise ValueError(f"MultiSQL must be JSON array: {file}")

    def strip_fence(s: str) -> str:
        t = s.strip()
        if t.startswith("```"):
            t = re.sub(r"^```(?:sql)?\s*", "", t, flags=re.I)
            t = re.sub(r"\s*```$", "", t)
        return t.strip()

    def answers(ans) -> list[str]:
        if ans is None:
            return []
        if isinstance(ans, str):
            s = strip_fence(ans)
            return [s] if s else []
        if isinstance(ans, list):
            out: list[str] = []
            for a in ans:
                out.extend(answers(a))
            return out
        return []

    out: list[dict] = []
    for item in raw:
        if not isinstance(item, dict):
            continue
        db = item.get("db")
        idx = item.get("idx")
        turns = item.get("interaction")
        if not isinstance(turns, list):
            continue
        for ti, turn in enumerate(turns):
            if not isinstance(turn, dict):
                continue
            for sql in answers(turn.get("Answer") or turn.get("answer")):
                meta: dict = {"file": str(file), "turn": ti}
                if db is not None:
                    meta["db"] = db
                if idx is not None:
                    meta["idx"] = idx
                if turn.get("User") is not None:
                    meta["question"] = turn["User"]
                out.append({"sql": sql, "source": "multisql", "meta": meta})
    return out


def load_dbasql(path: Path) -> list[dict]:
    files: list[Path] = []
    if path.is_file():
        files = [path]
    elif path.is_dir():
        for f in path.rglob("*"):
            if f.is_file() and f.suffix.lower() in (".json", ".jsonl", ".csv"):
                files.append(f)

    out: list[dict] = []
    for f in files:
        low = f.suffix.lower()
        if low == ".jsonl":
            out.extend(_load_json_or_jsonl(f, source="dbasql"))
        elif low == ".json":
            decoded = json.loads(f.read_text(encoding="utf-8"))
            rows: list[dict] = []
            if isinstance(decoded, list):
                rows = [x for x in decoded if isinstance(x, dict)]
            elif isinstance(decoded, dict):
                data = decoded.get("data") or decoded.get("rows") or decoded.get("samples")
                if isinstance(data, list):
                    rows = [x for x in data if isinstance(x, dict)]
                else:
                    rows = [decoded]
            for m in rows:
                sql = _sql_of(m)
                if not sql:
                    continue
                meta: dict = {"file": str(f)}
                if m.get("category") is not None:
                    meta["category"] = m["category"]
                out.append({"sql": sql, "source": "dbasql", "meta": meta})
        elif low == ".csv":
            with f.open(encoding="utf-8", newline="") as fp:
                reader = csv.reader(fp)
                rows = list(reader)
            if not rows:
                continue
            header = [c.lower() for c in rows[0]]
            sql_idx = next(
                (i for i, h in enumerate(header) if h in ("sql", "query")),
                -1,
            )
            if sql_idx < 0:
                for line in rows:
                    if line and line[0].strip():
                        out.append(
                            {
                                "sql": line[0].strip(),
                                "source": "dbasql",
                                "meta": {"file": str(f)},
                            }
                        )
            else:
                for row in rows[1:]:
                    if sql_idx >= len(row):
                        continue
                    sql = row[sql_idx].strip()
                    if sql:
                        out.append(
                            {
                                "sql": sql,
                                "source": "dbasql",
                                "meta": {"file": str(f)},
                            }
                        )
    return out


def _load_json_or_jsonl(f: Path, source: str) -> list[dict]:
    out: list[dict] = []
    if f.suffix.lower() == ".jsonl":
        for line in f.read_text(encoding="utf-8").splitlines():
            t = line.strip()
            if not t:
                continue
            m = json.loads(t)
            if not isinstance(m, dict):
                continue
            sql = _sql_of(m)
            if not sql:
                continue
            meta = {"file": str(f)}
            for k in ("db_id", "question", "evidence", "category"):
                if m.get(k) is not None:
                    meta[k] = m[k]
            out.append({"sql": sql, "source": source, "meta": meta})
        return out

    decoded = json.loads(f.read_text(encoding="utf-8"))
    if not isinstance(decoded, list):
        return out
    for item in decoded:
        if not isinstance(item, dict):
            continue
        sql = _sql_of(item)
        if not sql:
            continue
        meta = {"file": str(f)}
        for k in ("db_id", "question", "evidence", "category"):
            if item.get(k) is not None:
                meta[k] = item[k]
        out.append({"sql": sql, "source": source, "meta": meta})
    return out


def _count_lines(p: Path) -> int:
    return sum(1 for _ in p.open(encoding="utf-8", errors="ignore"))


# ── build ─────────────────────────────────────────────────────────────────


LOADERS = {
    "spider2": (_RAW / "spider2", load_spider2),
    "bird": (_RAW / "bird", load_bird),
    "spider": (_RAW / "spider", load_spider),
    "multisql": (_RAW / "multisql", load_multisql),
    "dbasql": (_RAW / "dbasql", load_dbasql),
}


def build(*, annotate: bool = True) -> None:
    _OUT.mkdir(parents=True, exist_ok=True)
    all_samples: list[dict] = []
    stats: dict[str, int] = {}

    for name, (path, loader) in LOADERS.items():
        if not path.exists():
            stats[name] = 0
            _log(f"[skip] {name}: not found ({path})")
            continue
        try:
            samples = loader(path)
            all_samples.extend(samples)
            stats[name] = len(samples)
            _log(f"[ok] {name}: {len(samples)}")
        except Exception as e:
            stats[name] = 0
            _log(f"[skip] {name}: {e}")

    seen: set[str] = set()
    unique: list[dict] = []
    for s in all_samples:
        key = _norm_key(s["sql"])
        if not key or key in seen:
            continue
        seen.add(key)
        unique.append(s)

    jsonl = _OUT / "sqls.jsonl"
    txt = _OUT / "sqls.txt"
    with jsonl.open("w", encoding="utf-8") as jf, txt.open("w", encoding="utf-8") as tf:
        for s in unique:
            row = {
                "sql": s["sql"],
                "source": s.get("source"),
            }
            if s.get("meta"):
                row["meta"] = s["meta"]
            jf.write(json.dumps(row, ensure_ascii=False) + "\n")
            tf.write(s["sql"].replace("\n", " ").strip() + "\n")

    by_source = Counter(s.get("source") or "unknown" for s in unique)
    by_op: Counter[str] = Counter()
    for s in unique:
        op = s["sql"].strip().split(None, 1)[0].upper() if s["sql"].strip() else ""
        if op:
            by_op[op] += 1

    annotate_stats = None
    if annotate:
        if annotate_jsonl is None:
            _log("[warn] annotate_object_roles unavailable")
        else:
            _log("annotating object_spans via sqlglot ...")
            annotate_stats = annotate_jsonl(jsonl)
            _log(json.dumps(annotate_stats, ensure_ascii=False))
    else:
        _log("[skip] annotate (--no-annotate)")

    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "total_raw": len(all_samples),
        "total_unique": len(unique),
        "loaded": stats,
        "by_source": dict(by_source),
        "by_op": dict(by_op.most_common(12)),
        "files": {
            "jsonl": "data/trainset/sqls.jsonl",
            "txt": "data/trainset/sqls.txt",
        },
    }
    if annotate_stats is not None:
        manifest["object_spans"] = annotate_stats
    (_OUT / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    _log(f"\ntrainset ready: {len(unique)} unique SQL")
    _log(f"by_source: {dict(by_source)}")
    _log(f"-> {jsonl}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--download",
        action="store_true",
        help="download raw datasets before build",
    )
    ap.add_argument(
        "--download-only",
        action="store_true",
        help="only download, do not build trainset",
    )
    ap.add_argument(
        "--no-annotate",
        action="store_true",
        help="skip sqlglot object_spans annotation",
    )
    args = ap.parse_args()

    os.chdir(_ROOT)
    if args.download or args.download_only:
        download_all()
    if args.download_only:
        return
    build(annotate=not args.no_annotate)


if __name__ == "__main__":
    main()
