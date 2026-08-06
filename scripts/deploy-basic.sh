#!/usr/bin/env bash
# Thin install: a pointer file plus a .cursorrules registration. Skills are read
# from this framework's location.
#
# Fast and always current, but it breaks if this directory moves and it does not
# travel with a clone. Use deploy-files.sh when either matters.
#
# Usage: deploy-basic.sh --target <repo> [--dry-run]
# Exit: 0 ok · 1 error · 2 already installed

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=""
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)  TARGET="${2:-}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$TARGET" ] || { echo "error: --target is required" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "error: target does not exist: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" = "$FRAMEWORK_ROOT" ] && { echo "error: refusing to install into the framework itself" >&2; exit 1; }

VERSION="$(grep -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "${FRAMEWORK_ROOT}/CHANGELOG.md" 2>/dev/null \
           | head -1 | tr -d '#[] ' || echo "unversioned")"
POINTER="${TARGET}/FLUTTER_AGENT_OS.md"

if [ -f "$POINTER" ]; then
  echo "already installed: $POINTER"
  grep -E '^\*\*(Version|Mode|Source):' "$POINTER" || true
  echo
  echo "This is an update. Run @flutter-deploy-basic update - ${TARGET} (or --update)"
  exit 2
fi

echo "Flutter Agent OS — basic (thin) install"
echo "  framework : ${FRAMEWORK_ROOT}"
echo "  target    : ${TARGET}"
echo "  version   : ${VERSION}"
[ "$DRY" -eq 1 ] && echo "  (dry run)"
echo

if [ "$DRY" -eq 0 ]; then
  cat > "$POINTER" <<EOF
# Flutter Agent OS — installed (basic)

**Source:** ${FRAMEWORK_ROOT}
**Version:** ${VERSION}
**Installed:** $(date +%Y-%m-%d)
**Mode:** basic — thin. Skills are read from the source path above.

| What | Where |
|------|-------|
| Entry point | \`${FRAMEWORK_ROOT}/START_HERE.md\` |
| Skills | \`${FRAMEWORK_ROOT}/skills/\` |
| Standards | \`${FRAMEWORK_ROOT}/standards/\` |
| Project memory | \`.work.flutter/\` (this repo) |

**Licence:** MIT. Installing this framework places MIT-licensed documentation
alongside your code; it makes no claim on your code.

**Caveat of a thin install:** if the source path moves or is unavailable (a
clone on another machine, a CI container), the skills cannot be read. Use a
\`files\` install where that matters.

## Next

\`\`\`
@flutter-bootstrap init
\`\`\`
EOF
fi
echo "  write     FLUTTER_AGENT_OS.md"

# .cursorrules — merge, never clobber.
CR="${TARGET}/.cursorrules"
SNIPPET="${FRAMEWORK_ROOT}/templates/cursorrules.flutter.snippet.template"
if [ ! -f "$CR" ]; then
  [ "$DRY" -eq 0 ] && cp "${FRAMEWORK_ROOT}/templates/cursorrules.flutter.template" "$CR"
  echo "  write     .cursorrules"
elif grep -q 'FLUTTER_AGENT_OS_BEGIN' "$CR" 2>/dev/null; then
  echo "  keep      .cursorrules (Flutter block already registered)"
else
  if [ "$DRY" -eq 0 ]; then
    printf '\n\n' >> "$CR"
    cat "$SNIPPET" >> "$CR"
  fi
  echo "  append    .cursorrules (Flutter block; existing rules preserved)"
fi

if [ "$DRY" -eq 0 ]; then
  # A fresh .cursorrules copied from the full template still carries the
  # REPLACE:FLUTTER_SNIPPET_BLOCK token — expand it the same way
  # templates/bootstrap.sh does, or the marker block never lands.
  if grep -q 'REPLACE:FLUTTER_SNIPPET_BLOCK' "$CR"; then
    tmp="$(mktemp)"
    awk -v snip="$SNIPPET" '
      /REPLACE:FLUTTER_SNIPPET_BLOCK/ { while ((getline line < snip) > 0) print line; next }
      { print }
    ' "$CR" > "$tmp" && mv "$tmp" "$CR"
  fi
  tmp="$(mktemp)"
  sed "s|REPLACE:FLUTTER_FRAMEWORK_PATH|${FRAMEWORK_ROOT}|g" "$CR" > "$tmp" && mv "$tmp" "$CR"
fi

# Collision check with sibling frameworks.
for other in "${TARGET}/.ai" "${TARGET}/.ai.ui"; do
  [ -d "$other" ] && echo "  note      $(basename "$other") present — cohabitation applies; no skill ids collide (all are flutter-*)"
done

cat <<EOF

deploy-basic: installed

Verify: @flutter-deploy-basic verify - ${TARGET}
Next:   @flutter-bootstrap init   (install is not setup — the project memory
        scaffold is a separate, required step)
EOF
