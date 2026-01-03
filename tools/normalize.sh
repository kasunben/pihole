#!/usr/bin/env bash
set -euo pipefail

# Normalize lists while preserving section comment positions.
# Rules:
# - A block starts with one or more comment lines (# ...).
# - Domain lines belong to the current block and are sorted+deduped (case-insensitive sort).
# - Blank lines AFTER domain lines are treated as trailing separators of the current block,
#   so they remain BETWEEN blocks (and do not become "blank lines after header" in the next block).
# - Comments and blank lines are preserved in-place, only domain lines are normalized.

python3 - <<'PY'
from __future__ import annotations
import subprocess
from pathlib import Path

def git_txt_files() -> list[str]:
    out = subprocess.check_output(["git", "ls-files", "*.txt"], text=True)
    return [line.strip() for line in out.splitlines() if line.strip()]

def is_comment(line: str) -> bool:
    return line.lstrip().startswith("#")

def is_blank(line: str) -> bool:
    return line.strip() == ""

def flush_block(out: list[str], header: list[str], items: list[str], trailing_blanks: list[str]) -> None:
    if not header and not items and not trailing_blanks:
        return

    # Emit header exactly as-is
    out.extend(header)

    # Sort + dedupe items (trim whitespace, keep stable content)
    seen = set()
    cleaned = []
    for it in items:
        v = it.strip()
        if not v:
            continue
        if v not in seen:
            seen.add(v)
            cleaned.append(v)

    cleaned.sort(key=str.lower)
    out.extend(cleaned)

    # Emit trailing blank lines (these are separators between blocks)
    out.extend(trailing_blanks)

def normalize_file(path: Path) -> None:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()

    out: list[str] = []

    header: list[str] = []
    items: list[str] = []
    trailing_blanks: list[str] = []

    mode = "start"  # start | header | items

    for line in lines:
        if is_comment(line):
            # New comment begins a (possibly new) block.
            # If we already have items, flush current block first (including trailing blanks).
            if items or trailing_blanks:
                flush_block(out, header, items, trailing_blanks)
                header, items, trailing_blanks = [], [], []

            header.append(line)
            mode = "header"
            continue

        if is_blank(line):
            if mode == "items":
                # Blank line after items => separator between blocks, keep as trailing blanks
                trailing_blanks.append(line)
            else:
                # Blank line before first block or between comment header lines => keep in header area
                header.append(line)
            continue

        # Non-comment, non-blank
        # If we previously accumulated trailing blanks, and now see another item,
        # that means the blank lines were inside a block (rare), so treat them as header continuation.
        if trailing_blanks:
            header.extend(trailing_blanks)
            trailing_blanks = []

        items.append(line)
        mode = "items"

    # Flush last block
    flush_block(out, header, items, trailing_blanks)

    # Ensure file ends with exactly one newline
    path.write_text("\n".join(out).rstrip("\n") + "\n", encoding="utf-8")

for f in git_txt_files():
    normalize_file(Path(f))
PY