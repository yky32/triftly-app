#!/usr/bin/env python3
"""Write env/dart_defines.json from env/.env.local (or CI shell env)."""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCAL_ENV = ROOT / "env" / ".env.local"
OUT = ROOT / "env" / "dart_defines.json"
KEYS = (
    "SUPABASE_URL",
    "SUPABASE_PUBLISHABLE_KEY",
    "SUPABASE_ANON_KEY",
    "GOOGLE_MAPS_API_KEY",
)


def parse_env_file(path: Path) -> dict[str, str]:
    if not path.is_file():
        return {}
    values: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.split("#", 1)[0].strip()
        if not line or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if not val or "..." in val or "YOUR_PROJECT_REF" in val:
            continue
        values[key] = val
    return values


def main() -> int:
    env_name = sys.argv[1] if len(sys.argv) > 1 else "dev"
    values: dict[str, str] = {"ENV": env_name}
    values.update(parse_env_file(LOCAL_ENV))

    for key in KEYS:
        shell_val = os.environ.get(key, "").strip()
        if shell_val:
            values[key] = shell_val

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(values, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
