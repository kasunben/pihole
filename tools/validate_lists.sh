#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail=0

while IFS= read -r -d '' f; do
  # Ignore empty lines and comments
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue

    # Reject IP-prefixed hosts format
    if [[ "$line" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}[[:space:]]+ ]]; then
      echo "❌ $f: hosts-format line not allowed: $line"
      fail=1
    fi

    # Reject protocols
    if [[ "$line" =~ ^https?:// ]]; then
      echo "❌ $f: protocol not allowed: $line"
      fail=1
    fi

    # Very basic domain sanity check
    if ! [[ "$line" =~ ^[A-Za-z0-9._-]+\.[A-Za-z]{2,}$ ]]; then
      echo "⚠️  $f: suspicious domain: $line"
    fi
  done < "$f"
done < <(find "$ROOT" -type f -name "*.txt" -print0)

if [[ "$fail" -eq 1 ]]; then
  echo "Validation failed."
  exit 1
fi

echo "✅ Validation passed."
