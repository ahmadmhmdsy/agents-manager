#!/usr/bin/env python3
"""Append one row to a context-externalization manifest (atomic O_APPEND).

Caller must read the manifest first, check for path uniqueness, then call
this with the new row content (single line, no embedded newlines).

Usage:
    python append_row.py <manifest_path> <row_content>

v0.23.0+ — see agents_manager/SKILL.md § Context externalization protocol.
"""
import sys
from pathlib import Path

if len(sys.argv) != 3:
    print("Usage: append_row.py <manifest_path> <row>", file=sys.stderr)
    sys.exit(2)

p = Path(sys.argv[1])
row = sys.argv[2]
if not row.endswith("\n"):
    row += "\n"
p.parent.mkdir(parents=True, exist_ok=True)
with p.open("a", encoding="utf-8") as f:
    f.write(row)
