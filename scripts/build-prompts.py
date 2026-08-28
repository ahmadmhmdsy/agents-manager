#!/usr/bin/env python3
"""build-prompts.py — regenerate agents_manager specialist prompts in opencode.jsonc.

Reads:
  - agents_manager/_GLOBAL_PROMPT.md          (global preamble)
  - agents_manager/<role>/_PROMPT_ADDENDUM.md (role-specific addendum)

Writes:
  - opencode.jsonc                            (regenerates each agent.prompt)

Idempotent. Run before any release. CI runs this in dry-run mode to detect drift.

Usage:
    python3 scripts/build-prompts.py            # regenerate opencode.jsonc
    python3 scripts/build-prompts.py --check    # exit 1 if opencode.jsonc is out of date
    python3 scripts/build-prompts.py --help

v0.25.0+: the global operating contract is in _GLOBAL_PROMPT.md; per-role
content lives in <role>/_PROMPT_ADDENDUM.md. This script composes them into
each agent.prompt field in opencode.jsonc.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GLOBAL_PROMPT = REPO_ROOT / "agents_manager" / "_GLOBAL_PROMPT.md"
OPENCODE_JSONC = REPO_ROOT / "opencode.jsonc"

# Roles registered in opencode.jsonc. Order matters for stable diffs.
ROLES = [
    "master",
    "am-research",
    "am-planning",
    "am-design",
    "am-assets",
    "am-coder",
    "am-review",
    "am-investigate",
    "am-ship",
    "am-health",
]

# Map role name -> role folder under agents_manager/
ROLE_FOLDERS = {
    "master":        "master",
    "am-research":   "research",
    "am-planning":   "planning",
    "am-design":     "design",
    "am-assets":     "assets",
    "am-coder":      "coder",
    "am-review":     "review",
    "am-investigate": "investigate",
    "am-ship":       "ship",
    "am-health":     "health",
}

# Separator between global preamble and role-specific addendum.
# Embedded in opencode.jsonc so consumers can identify the boundary.
SEPARATOR_HEADER = (
    "---\n\n"
    "## Role-Specific (v0.25.0+ — appended by `scripts/build-prompts.py`)\n\n"
)


def read_global_prompt_body() -> str:
    """Return the global prompt body (frontmatter stripped)."""
    text = GLOBAL_PROMPT.read_text(encoding="utf-8")
    # Strip YAML frontmatter (lines between first and second `---`)
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end >= 0:
            return text[end + 5:].rstrip() + "\n"
    return text


def read_addendum(role: str) -> str:
    """Return the role-specific addendum for a given role."""
    folder = ROLE_FOLDERS[role]
    path = REPO_ROOT / "agents_manager" / folder / "_PROMPT_ADDENDUM.md"
    if not path.exists():
        sys.exit(f"ERROR: missing {path}")
    return path.read_text(encoding="utf-8").rstrip() + "\n"


def compose_prompt(role: str) -> str:
    """Compose the full prompt for a role: global + separator + addendum."""
    global_body = read_global_prompt_body()
    addendum = read_addendum(role)
    return global_body + "\n" + SEPARATOR_HEADER + addendum


def strip_jsonc_comments(text: str) -> str:
    """Remove // line comments. Block comments /* ... */ are not used."""
    return re.sub(r"(?m)^\s*//.*$", "", text)


def load_opencode() -> dict:
    """Parse opencode.jsonc (JSON with // line comments)."""
    raw = OPENCODE_JSONC.read_text(encoding="utf-8")
    return json.loads(strip_jsonc_comments(raw))


def save_opencode(data: dict) -> None:
    """Write opencode.jsonc with LF line endings and UTF-8 no BOM."""
    raw = json.dumps(data, indent=2, ensure_ascii=False)
    OPENCODE_JSONC.write_text(raw + "\n", encoding="utf-8", newline="\n")


def check_drift() -> int:
    """Exit 1 if any specialist prompt in opencode.jsonc would change."""
    data = load_opencode()
    drift: list[str] = []
    for role in ROLES:
        composed = compose_prompt(role)
        current = data.get("agent", {}).get(role, {}).get("prompt", "")
        if current != composed:
            drift.append(role)
    if drift:
        print("DRIFT detected in:", ", ".join(drift), file=sys.stderr)
        print("Run `python3 scripts/build-prompts.py` to regenerate.", file=sys.stderr)
        return 1
    print("OK: all 10 specialist prompts match build-prompts.py output.")
    return 0


def regenerate() -> None:
    """Regenerate opencode.jsonc with fresh prompts from sources."""
    data = load_opencode()
    for role in ROLES:
        composed = compose_prompt(role)
        data["agent"][role]["prompt"] = composed
        print(f"  {role}: {len(composed)} chars")
    # Ensure instructions field references the global prompt
    if "instructions" not in data:
        data["instructions"] = ["agents_manager/_GLOBAL_PROMPT.md"]
    save_opencode(data)
    print(f"Wrote {OPENCODE_JSONC.relative_to(REPO_ROOT)}")


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--check", action="store_true",
                   help="Exit 1 if opencode.jsonc is out of date; do not write.")
    args = p.parse_args()
    if args.check:
        return check_drift()
    regenerate()
    return 0


if __name__ == "__main__":
    sys.exit(main())
