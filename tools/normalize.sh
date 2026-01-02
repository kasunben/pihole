#!/usr/bin/env bash
set -euo pipefail

# Sort unique non-comment lines, keep comments/header at top.
# Use carefully; it will rewrite files.

for f in $(git ls-files "*.txt"); do
  header=$(awk 'BEGIN{s=""} /^#/ {s=s $0 "\n"} !/^#/ {exit} END{printf "%s", s}' "$f")
  body=$(grep -vE '^\s*$|^#' "$f" | tr -d '\r' | awk '{$1=$1;print}' | sort -fu)
  {
    printf "%s" "$header"
    printf "\n"
    printf "%s\n" "$body"
  } > "$f.tmp"
  mv "$f.tmp" "$f"
done
