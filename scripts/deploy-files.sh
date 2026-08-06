#!/usr/bin/env bash
# Fat install: copies the framework into the target so it is self-contained.
#
# Use for CI, containers, and contributors who will not have the source. Costs
# duplication; buys reproducibility.
#
# Usage: deploy-files.sh --target <repo> [--into <dir>] [--dry-run] [--force]
# Exit: 0 ok · 1 error · 2 already installed

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=""
INTO=".ai.flutter"
DRY=0
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)  TARGET="${2:-}"; shift 2 ;;
    --into)    INTO="${2:-}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$TARGET" ] || { echo "error: --target is required" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "error: target does not exist: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" = "$FRAMEWORK_ROOT" ] && { echo "error: refusing to install into the framework itself" >&2; exit 1; }

DEST="${TARGET}/${INTO}"
VERSION="$(grep -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "${FRAMEWORK_ROOT}/CHANGELOG.md" 2>/dev/null \
           | head -1 | tr -d '#[] ' || echo "unversioned")"

if [ -d "$DEST" ] && [ "$FORCE" -eq 0 ]; then
  echo "already installed at ${DEST}"
  echo "This is an update. Run @flutter-deploy-files update - ${TARGET} (or --update)"
  exit 2
fi

echo "Flutter Agent OS — files (fat) install"
echo "  framework : ${FRAMEWORK_ROOT}"
echo "  target    : ${DEST}"
echo "  version   : ${VERSION}"
[ "$DRY" -eq 1 ] && echo "  (dry run)"
echo

COPY="skills standards concepts templates scripts hooks stacks resources docs .quick"
ROOTFILES="README.md START_HERE.md APPROACH.md PROCESS_ROUTER.md COHABITATION.md CONTRIBUTING.md CHANGELOG.md LICENSE"

# Collision report before writing anything.
COLLISIONS=0
for d in $COPY; do
  [ -e "${DEST}/${d}" ] && { echo "  collision ${INTO}/${d}"; COLLISIONS=$((COLLISIONS+1)); }
done
if [ "$COLLISIONS" -gt 0 ] && [ "$FORCE" -eq 0 ]; then
  echo >&2
  echo "error: ${COLLISIONS} existing paths. Use --force to replace, or run an update." >&2
  exit 1
fi

if [ "$DRY" -eq 0 ]; then
  mkdir -p "$DEST"
  for d in $COPY; do
    [ -d "${FRAMEWORK_ROOT}/${d}" ] || continue
    rm -rf "${DEST:?}/${d}"
    cp -R "${FRAMEWORK_ROOT}/${d}" "${DEST}/${d}"
    echo "  copy      ${INTO}/${d}/"
  done
  for f in $ROOTFILES; do
    [ -f "${FRAMEWORK_ROOT}/${f}" ] && cp "${FRAMEWORK_ROOT}/${f}" "${DEST}/${f}" && echo "  copy      ${INTO}/${f}"
  done
  # Never carry the framework's own git or project memory into a consumer.
  rm -rf "${DEST}/.git" "${DEST}/.work.flutter" "${DEST}/TMP" 2>/dev/null || true
  find "${DEST}/scripts" "${DEST}/hooks" "${DEST}/templates" -type f \
       \( -name '*.sh' -o -name 'pre-*' -o -name 'commit-*' -o -name 'post-*' -o -name 'prepare-*' \) \
       -exec chmod +x {} + 2>/dev/null || true
else
  for d in $COPY; do echo "  copy      ${INTO}/${d}/"; done
fi

# Pointer.
if [ "$DRY" -eq 0 ]; then
  cat > "${TARGET}/FLUTTER_AGENT_OS.md" <<EOF
# Flutter Agent OS — installed (files)

**Source:** ${INTO}/ (self-contained copy)
**Version:** ${VERSION}
**Installed:** $(date +%Y-%m-%d)
**Mode:** files — the framework travels with this repository.

| What | Where |
|------|-------|
| Entry point | \`${INTO}/START_HERE.md\` |
| Skills | \`${INTO}/skills/\` |
| Standards | \`${INTO}/standards/\` |
| Project memory | \`.work.flutter/\` |

**Licence:** MIT. See \`${INTO}/LICENSE\`.

## Next

\`\`\`
@flutter-bootstrap init
\`\`\`
EOF
fi
echo "  write     FLUTTER_AGENT_OS.md"

CR="${TARGET}/.cursorrules"
SNIPPET="${FRAMEWORK_ROOT}/templates/cursorrules.flutter.snippet.template"
if [ ! -f "$CR" ]; then
  [ "$DRY" -eq 0 ] && cp "${FRAMEWORK_ROOT}/templates/cursorrules.flutter.template" "$CR"
  echo "  write     .cursorrules"
elif grep -q 'FLUTTER_AGENT_OS_BEGIN' "$CR" 2>/dev/null; then
  echo "  keep      .cursorrules (already registered)"
else
  [ "$DRY" -eq 0 ] && { printf '\n\n' >> "$CR"; cat "$SNIPPET" >> "$CR"; }
  echo "  append    .cursorrules"
fi
if [ "$DRY" -eq 0 ]; then
  tmp="$(mktemp)"; sed "s|REPLACE:FLUTTER_FRAMEWORK_PATH|${INTO}|g" "$CR" > "$tmp" && mv "$tmp" "$CR"
fi

cat <<EOF

deploy-files: installed

Verify: bash ${INTO}/scripts/framework-verify.sh --root ${DEST}
Next:   @flutter-bootstrap init
EOF
