#!/usr/bin/env bash
# Compares the changed files against the scope the active task declared in
# .work.flutter/touch-scope.
#
# Out-of-scope edits are reported, never silently accepted. Widening the scope
# is a decision recorded in the iteration block — not an edit made to quiet this
# check.
#
# Usage: touch-scope-verify.sh [--staged|--head]
# Exit: 0 in scope (or no active task) · 1 out of scope · 2 usage

set -uo pipefail

MODE="staged"
case "${1:-}" in
  --staged|"") MODE="staged" ;;
  --head)      MODE="head" ;;
  -h|--help)   sed -n '2,11p' "$0"; exit 0 ;;
  *) echo "unknown argument: $1" >&2; exit 2 ;;
esac

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 2; }
REPO="$(git rev-parse --show-toplevel)"
SCOPE="${REPO}/.work.flutter/touch-scope"

if [ ! -f "$SCOPE" ]; then
  echo "touch-scope: no scope file — skipping (run @flutter-bootstrap init)"
  exit 0
fi

if [ "$MODE" = "staged" ]; then
  FILES="$(git diff --cached --name-only)"
else
  FILES="$(git diff --name-only HEAD~1 HEAD)"
fi
[ -z "$FILES" ] && { echo "touch-scope: no changes"; exit 0; }

# ------------------------------------------------------------- read the scope
# Extracts a JSON string array by key. Handles both the inline empty form
# ("allow": []) and the multi-line form. Without the inline case an empty allow
# list swallows the following key's array, which silently inverts the check.
readarr() {
  awk -v key="\"$1\"" '
    !inarr && index($0, key) {
      rest = substr($0, index($0, key) + length(key))
      sub(/^[ \t]*:[ \t]*/, "", rest)
      if (rest !~ /^\[/) next
      rest = substr(rest, 2)
      if (index(rest, "]")) { rest = substr(rest, 1, index(rest, "]") - 1) }
      else { inarr = 1 }
      emit(rest)
      next
    }
    inarr {
      if (index($0, "]")) { emit(substr($0, 1, index($0, "]") - 1)); inarr = 0; next }
      emit($0)
    }
    function emit(s,   n, i, parts) {
      n = split(s, parts, ",")
      for (i = 1; i <= n; i++) {
        gsub(/^[ \t]+|[ \t]+$/, "", parts[i])
        gsub(/^"|"$/, "", parts[i])
        if (length(parts[i])) print parts[i]
      }
    }
  ' "$SCOPE"
}

TASK="$(grep -oE '"task" *: *"[^"]*"' "$SCOPE" | sed 's/.*: *"//; s/"$//')"
ALLOW="$(readarr allow)"
DENY="$(readarr deny)"

# Shell case globbing has no `**`. A `**/` prefix must therefore also match at
# the repository root, or `**/*.jks` misses `key.jks` — exactly the file the
# pattern exists to catch.
match() {
  local f="$1" pat="$2"
  case "$f" in $pat) return 0 ;; esac
  case "$pat" in
    '**/'*) case "$f" in ${pat#'**/'}) return 0 ;; esac ;;
  esac
  return 1
}

# --------------------------------------------------------------- deny always
DENIED=""
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  while IFS= read -r f; do match "$f" "$pat" && DENIED="${DENIED}${f}"$'\n'; done <<< "$FILES"
done <<< "$DENY"

if [ -n "$DENIED" ]; then
  printf '\ntouch-scope: DENIED paths in the diff\n\n'
  printf '%s' "$DENIED" | sed 's/^/  /'
  printf '\nThese must never be committed. Remove them; if a credential is real, revoke and rotate it.\n'
  exit 1
fi

# --------------------------------------------------------------- allow check
if [ -z "$ALLOW" ]; then
  printf 'touch-scope: no active task scope declared — %s files changed, not checked\n' \
    "$(printf '%s\n' "$FILES" | wc -l | tr -d ' ')"
  exit 0
fi

OUT=""
IN=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  # Project memory is always in scope: recording work is part of doing it.
  case "$f" in .work.flutter/*) IN=$((IN+1)); continue ;; esac
  ok=1
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    match "$f" "$pat" && { ok=0; break; }
  done <<< "$ALLOW"
  if [ "$ok" -eq 0 ]; then IN=$((IN+1)); else OUT="${OUT}${f}"$'\n'; fi
done <<< "$FILES"

printf '\ntouch-scope (task: %s)\n\n' "${TASK:-none}"
printf '  in scope:     %s\n' "$IN"
printf '  out of scope: %s\n' "$(printf '%s' "$OUT" | grep -c . | tr -d ' ')"

if [ -n "$OUT" ]; then
  printf '\n  out-of-scope files:\n'
  printf '%s' "$OUT" | sed 's/^/    /'
  printf '\n  Declared scope:\n'
  printf '%s\n' "$ALLOW" | sed 's/^/    /'
  printf '\ntouch-scope: OUT OF SCOPE — either revert these, or widen the scope in the\n'
  printf 'iteration block and say why. Do not edit touch-scope to silence this.\n'
  exit 1
fi

printf '\ntouch-scope: IN SCOPE\n'
exit 0
