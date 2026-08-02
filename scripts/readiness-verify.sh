#!/usr/bin/env bash
# Probe ledger honesty check.
#
# A probe ledger is only useful if its scores are earned. This script fails the
# two ways a ledger lies: a dimension claimed confirmed with no recorded answer,
# and a stated coverage figure that the table does not support.
#
# Honesty and readiness are separate questions. A ledger can be perfectly honest
# and nowhere near ready. Pass --gate (what `certify` uses) to also require every
# ★ dimension confirmed.
#
# Usage: readiness-verify.sh <PROBE_LEDGER.md> [--gate]
# Exit: 0 pass · 1 fail · 2 usage

set -uo pipefail

LEDGER=""
GATE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --gate) GATE=1; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) LEDGER="$1"; shift ;;
  esac
done

[ -n "$LEDGER" ] || { echo "usage: readiness-verify.sh <PROBE_LEDGER.md> [--gate]" >&2; exit 2; }
[ -f "$LEDGER" ] || { echo "error: not found: $LEDGER" >&2; exit 2; }

FAILS=0
pass() { printf '  ok    %s\n' "$1"; }
fail() { FAILS=$((FAILS+1)); printf '  FAIL  %s\n' "$1" >&2; }
warn() { printf '  warn  %s\n' "$1"; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# ------------------------------------------------------------ coverage table
awk '/^\| *Dim *\|/{f=1} f && /^\|/{print} f && !/^\|/{f=0}' "$LEDGER" > "$TMP/cov"
# ----------------------------------------------------------------- Q&A table
awk '/^\| *# *\| *Date *\|/{f=1} f && /^\|/{print} f && !/^\|/{f=0}' "$LEDGER" > "$TMP/qa"

DIMS=0; CONFIRMED=0; STARRED=0; STARRED_OK=0; BAD=0

while IFS= read -r line; do
  case "$line" in
    *'---'*|*'| Dim '*) continue ;;
  esac
  dim="$(printf '%s' "$line" | awk -F'|' '{gsub(/ /,"",$2); print $2}')"
  [ -z "$dim" ] && continue
  case "$dim" in D[0-9]*|S[0-9]*|K[0-9]*|P[0-9]*) ;; *) continue ;; esac

  star="$(printf '%s' "$line" | awk -F'|' '{gsub(/ /,"",$4); print $4}')"
  score="$(printf '%s' "$line" | awk -F'|' '{gsub(/ /,"",$5); print $5}')"

  DIMS=$((DIMS+1))
  [ "$star" = "★" ] && STARRED=$((STARRED+1))

  case "$score" in
    2)
      CONFIRMED=$((CONFIRMED+1))
      [ "$star" = "★" ] && STARRED_OK=$((STARRED_OK+1))
      # A confirmed dimension must have at least one recorded answer.
      if ! grep -qE "\| *${dim} *\|" "$TMP/qa"; then
        printf '  FAIL  %s scores 2 (confirmed) but has no entry in the ledger table\n' "$dim" >&2
        BAD=$((BAD+1))
      fi
      ;;
    0|1) ;;
    *) warn "$dim has an unrecognised score: '${score}'" ;;
  esac
done < "$TMP/cov"

printf '\nCoverage table\n'
[ "$DIMS" -gt 0 ] && pass "$DIMS dimensions parsed" || fail "no coverage dimensions parsed"
[ "$BAD" -eq 0 ] && pass "every confirmed dimension has a recorded answer" \
  || { FAILS=$((FAILS+1)); printf '  FAIL  %s unsupported confirmations\n' "$BAD" >&2; }

printf '\nLedger entries\n'
# Entry ids may be bare integers (fixture style: | 1 |) or prefixed (L1, Q1).
ENTRY_RE='^\| *[A-Za-z]?[0-9]+ *\|'
ENTRIES="$(grep -cE "$ENTRY_RE" "$TMP/qa" 2>/dev/null | tr -d ' ')"
ENTRIES="${ENTRIES:-0}"
if [ "$CONFIRMED" -gt 0 ] && [ "$ENTRIES" -eq 0 ]; then
  fail "$CONFIRMED dimensions confirmed but the ledger records no questions at all"
else
  pass "$ENTRIES recorded question/answer entries"
fi

# Every entry must name what it unblocked and where it was recorded.
THIN=0
while IFS= read -r row; do
  case "$row" in *'---'*) continue ;; esac
  rec="$(printf '%s' "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$8); print $8}')"
  ans="$(printf '%s' "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$6); print $6}')"
  [ -z "$ans" ] && THIN=$((THIN+1))
  [ -z "$rec" ] && THIN=$((THIN+1))
done < <(grep -E "$ENTRY_RE" "$TMP/qa" 2>/dev/null)
[ "$THIN" -eq 0 ] && pass "every entry has an answer and a destination" \
  || fail "$THIN ledger cells are empty (answer or 'recorded in')"

printf '\nStar dimensions\n'
STAR_SHORT=0
if [ "$STARRED" -gt 0 ]; then
  printf '  info  %s/%s starred dimensions confirmed\n' "$STARRED_OK" "$STARRED"
  if [ "$STARRED_OK" -eq "$STARRED" ]; then
    pass "all ★ dimensions confirmed — gate may open"
  else
    STAR_SHORT=$((STARRED - STARRED_OK))
    if [ "$GATE" -eq 1 ]; then
      fail "$STAR_SHORT ★ dimensions unconfirmed — cannot certify"
    else
      warn "$STAR_SHORT ★ dimensions unconfirmed — the phase gate stays shut"
    fi
  fi
else
  warn "no ★ dimensions marked"
fi

printf '\nStated coverage\n'
STATED="$(grep -oE 'coverage:? *[0-9]+%' "$LEDGER" | head -1 | grep -oE '[0-9]+' || true)"
if [ -n "$STATED" ] && [ "$DIMS" -gt 0 ]; then
  ACTUAL=$(( CONFIRMED * 100 / DIMS ))
  DIFF=$(( STATED > ACTUAL ? STATED - ACTUAL : ACTUAL - STATED ))
  if [ "$DIFF" -le 5 ]; then
    pass "stated coverage ${STATED}% matches the table (${ACTUAL}%)"
  else
    fail "stated coverage ${STATED}% but the table supports ${ACTUAL}%"
  fi
else
  pass "no stated coverage figure to cross-check"
fi

printf '\nfailures: %s\n' "$FAILS"
if [ "$FAILS" -gt 0 ]; then
  printf 'readiness-verify: FAIL\n'
  exit 1
fi
# An honest ledger is not the same as a finished one. Say which was checked, so
# "PASS" is never read as "certifiable".
if [ "$STAR_SHORT" -gt 0 ]; then
  printf 'readiness-verify: HONEST — but %s ★ dimensions remain. Not certifiable.\n' "$STAR_SHORT"
else
  printf 'readiness-verify: PASS\n'
fi
exit 0
