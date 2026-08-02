#!/usr/bin/env bash
# Measures the blast radius of the current change against the thresholds and
# protected surfaces in PROTECTED_SURFACES.json.
#
# A large or wide diff is not forbidden — it is required to be acknowledged.
# Silent large diffs are how a "small fix" takes down a release.
#
# Usage: blast-radius-check.sh [--staged|--head|--range <a>..<b>]
# Exit: 0 low/medium · 1 high (needs explicit acknowledgement) · 2 usage

set -uo pipefail

MODE="staged"
RANGE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --staged) MODE="staged"; shift ;;
    --head)   MODE="head"; shift ;;
    --range)  MODE="range"; RANGE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 2; }
REPO="$(git rev-parse --show-toplevel)"

case "$MODE" in
  staged) DIFF_ARGS=(--cached) ;;
  head)   DIFF_ARGS=(HEAD~1 HEAD) ;;
  range)  DIFF_ARGS=("$RANGE") ;;
esac

FILES="$(git diff --name-only "${DIFF_ARGS[@]}" 2>/dev/null)"
[ -z "$FILES" ] && { echo "blast-radius: no changes"; exit 0; }

STAT="$(git diff --numstat "${DIFF_ARGS[@]}" 2>/dev/null)"
ADDED=$(printf '%s\n' "$STAT" | awk '$1 ~ /^[0-9]+$/ {s+=$1} END{print s+0}')
REMOVED=$(printf '%s\n' "$STAT" | awk '$2 ~ /^[0-9]+$/ {s+=$2} END{print s+0}')
NFILES=$(printf '%s\n' "$FILES" | wc -l | tr -d ' ')
LINES=$((ADDED + REMOVED))

# ------------------------------------------------------------- config lookup
PS="${REPO}/.work.flutter/standards/PROTECTED_SURFACES.json"
[ -f "$PS" ] || PS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/standards/PROTECTED_SURFACES.json"

# Dependency-free JSON string-array reader. Handles the inline empty form
# ("allow": []) as well as the multi-line form; without that, an empty array
# swallows the next key's contents.
jqish() {
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
  ' "$PS" 2>/dev/null
}

LINES_WARN=200; LINES_FAIL=600; FILES_WARN=15; FILES_FAIL=40; AREAS_WARN=2; AREAS_FAIL=3
if [ -f "$PS" ]; then
  v() { grep -oE "\"$1\" *: *[0-9]+" "$PS" 2>/dev/null | grep -oE '[0-9]+$' | head -1; }
  LINES_WARN="$(v max_lines_warn || echo $LINES_WARN)"
  LINES_FAIL="$(v max_lines_fail || echo $LINES_FAIL)"
  FILES_WARN="$(v max_files_warn || echo $FILES_WARN)"
  FILES_FAIL="$(v max_files_fail || echo $FILES_FAIL)"
  AREAS_WARN="$(v max_areas_warn || echo $AREAS_WARN)"
  AREAS_FAIL="$(v max_areas_fail || echo $AREAS_FAIL)"
fi

# ------------------------------------------------------------------- areas
AREAS="$(printf '%s\n' "$FILES" | awk -F/ '
  /^lib\/core\//        {print "lib/core"; next}
  /^lib\/features\//    {print "lib/features"; next}
  /^lib\//              {print "lib"; next}
  /^android\//          {print "android"; next}
  /^ios\//              {print "ios"; next}
  /^web\//              {print "web"; next}
  /^test\//             {print "test"; next}
  /^integration_test\// {print "integration_test"; next}
  /^\.github\//         {print ".github"; next}
  /^\.work\.flutter\//  {print ".work.flutter"; next}
                        {print "root"}
' | sort -u)"
NAREAS=$(printf '%s\n' "$AREAS" | grep -c . | tr -d ' ')

# -------------------------------------------------------- protected surfaces
HITS=""
# Shell case globbing has no `**`. A `**/` prefix must also match at the
# repository root, or `**/.env` misses a root-level `.env` — the exact file the
# pattern exists to catch.
match_glob() {
  local f="$1" pat="$2"
  case "$f" in $pat) return 0 ;; esac
  case "$pat" in
    '**/'*) case "$f" in ${pat#'**/'}) return 0 ;; esac ;;
  esac
  return 1
}
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  while IFS= read -r f; do
    match_glob "$f" "$pat" && HITS="${HITS}${f} (matches ${pat})"$'\n'
  done <<< "$FILES"
done < <( { jqish consumer_paths; jqish consumer_patterns; jqish framework_paths; jqish framework_patterns; } 2>/dev/null )

NEVER=""
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  while IFS= read -r f; do
    match_glob "$f" "$pat" && NEVER="${NEVER}${f}"$'\n'
  done <<< "$FILES"
done < <(jqish never_commit_patterns 2>/dev/null)

# ------------------------------------------------------------------ verdict
RISK="low"
REASONS=""
add() { REASONS="${REASONS}  - $1"$'\n'; }

[ "$LINES" -ge "$LINES_WARN" ]  && { RISK="medium"; add "$LINES changed lines (warn at $LINES_WARN)"; }
[ "$LINES" -ge "$LINES_FAIL" ]  && { RISK="high";   add "$LINES changed lines exceeds the $LINES_FAIL limit"; }
[ "$NFILES" -ge "$FILES_WARN" ] && { [ "$RISK" = low ] && RISK="medium"; add "$NFILES files (warn at $FILES_WARN)"; }
[ "$NFILES" -ge "$FILES_FAIL" ] && { RISK="high";   add "$NFILES files exceeds the $FILES_FAIL limit"; }
[ "$NAREAS" -gt "$AREAS_WARN" ] && { [ "$RISK" = low ] && RISK="medium"; add "$NAREAS areas touched"; }
[ "$NAREAS" -gt "$AREAS_FAIL" ] && { RISK="high";   add "$NAREAS areas exceeds the $AREAS_FAIL limit"; }
[ -n "$HITS" ]  && { RISK="high"; add "protected surfaces touched"; }
[ -n "$NEVER" ] && { RISK="high"; add "NEVER-COMMIT paths present"; }

printf '\nBlast radius (%s)\n\n' "$MODE"
printf '  files:  %s\n  lines:  +%s/-%s (%s)\n  areas:  %s (%s)\n' \
  "$NFILES" "$ADDED" "$REMOVED" "$LINES" "$NAREAS" "$(printf '%s' "$AREAS" | tr '\n' ' ')"

if [ -n "$HITS" ]; then
  printf '\n  protected surfaces:\n'
  printf '%s' "$HITS" | sed 's/^/    /'
  printf '    → requires explicit human approval in the request\n'
fi

if [ -n "$NEVER" ]; then
  printf '\n  NEVER COMMIT:\n'
  printf '%s' "$NEVER" | sed 's/^/    /'
  printf '    → signing material or credentials. Remove, then revoke and rotate.\n'
fi

printf '\n  risk: %s\n' "$RISK"
[ -n "$REASONS" ] && printf '%s' "$REASONS"

case "$RISK" in
  high) printf '\nblast-radius: HIGH — acknowledge explicitly in the verification report\n'; exit 1 ;;
  *)    printf '\nblast-radius: %s\n' "$RISK"; exit 0 ;;
esac
