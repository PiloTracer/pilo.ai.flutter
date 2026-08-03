#!/usr/bin/env bash
# Repo install: clone or unpack the framework as a version-pinned directory
# inside the target, so the exact framework revision is recorded in the target's
# own history.
#
# Usage: deploy-repo.sh --target <repo> [--into <dir>] [--ref <git-ref>]
#                       [--from <url|path>] [--submodule] [--dry-run]
# Exit: 0 ok · 1 error · 2 already installed

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=""
INTO=".ai.flutter"
REF=""
FROM="$FRAMEWORK_ROOT"
SUBMODULE=0
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)    TARGET="${2:-}"; shift 2 ;;
    --into)      INTO="${2:-}"; shift 2 ;;
    --ref)       REF="${2:-}"; shift 2 ;;
    --from)      FROM="${2:-}"; shift 2 ;;
    --submodule) SUBMODULE=1; shift ;;
    --dry-run)   DRY=1; shift ;;
    -h|--help)   sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$TARGET" ] || { echo "error: --target is required" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "error: target does not exist: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" = "$FRAMEWORK_ROOT" ] && { echo "error: refusing to install into the framework itself" >&2; exit 1; }

DEST="${TARGET}/${INTO}"
[ -e "$DEST" ] && { echo "already present: ${DEST}"; echo "Run @flutter-deploy update - ${TARGET}"; exit 2; }

command -v git >/dev/null 2>&1 || { echo "error: git is required for a repo install" >&2; exit 1; }

echo "Flutter Agent OS — repo install"
echo "  from      : ${FROM}"
echo "  target    : ${DEST}"
echo "  ref       : ${REF:-<default branch>}"
echo "  mode      : $([ "$SUBMODULE" -eq 1 ] && echo submodule || echo 'clone (detached, .git removed)')"
[ "$DRY" -eq 1 ] && { echo "  (dry run)"; exit 0; }
echo

if [ "$SUBMODULE" -eq 1 ]; then
  ( cd "$TARGET" && git submodule add "$FROM" "$INTO" )
  [ -n "$REF" ] && ( cd "$DEST" && git checkout --detach "$REF" )
  ( cd "$TARGET" && git add .gitmodules "$INTO" )
  echo "  added as a submodule — collaborators must run: git submodule update --init"
else
  git clone --quiet "$FROM" "$DEST"
  [ -n "$REF" ] && ( cd "$DEST" && git checkout --quiet --detach "$REF" )
  PINNED="$( cd "$DEST" && git rev-parse --short HEAD )"
  rm -rf "${DEST}/.git"
  echo "  cloned and pinned at ${PINNED} (.git removed — the framework is now part of this repo's history)"
fi

rm -rf "${DEST}/.work.flutter" "${DEST}/TMP" "${DEST}/plans" 2>/dev/null || true
find "${DEST}/scripts" "${DEST}/hooks" "${DEST}/templates" -type f \
     \( -name '*.sh' -o -name 'pre-*' -o -name 'commit-*' -o -name 'post-*' -o -name 'prepare-*' \) \
     -exec chmod +x {} + 2>/dev/null || true

VERSION="$(grep -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "${DEST}/CHANGELOG.md" 2>/dev/null \
           | head -1 | tr -d '#[] ' || echo "unversioned")"

cat > "${TARGET}/FLUTTER_AGENT_OS.md" <<EOF
# Flutter Agent OS — installed (repo)

**Source:** ${INTO}/ ($([ "$SUBMODULE" -eq 1 ] && echo 'git submodule' || echo "pinned copy of ${FROM}"))
**Version:** ${VERSION}
**Ref:** ${REF:-default branch}
**Installed:** $(date +%Y-%m-%d)
**Mode:** repo

| What | Where |
|------|-------|
| Entry point | \`${INTO}/START_HERE.md\` |
| Skills | \`${INTO}/skills/\` |
| Project memory | \`.work.flutter/\` |

**Licence:** MIT. See \`${INTO}/LICENSE\`.

## Next

\`\`\`
@flutter-bootstrap init
\`\`\`
EOF

CR="${TARGET}/.cursorrules"
SNIPPET="${DEST}/templates/cursorrules.flutter.snippet.template"
if [ ! -f "$CR" ]; then
  cp "${DEST}/templates/cursorrules.flutter.template" "$CR"
elif ! grep -q 'FLUTTER_AGENT_OS_BEGIN' "$CR" 2>/dev/null; then
  printf '\n\n' >> "$CR"; cat "$SNIPPET" >> "$CR"
fi
tmp="$(mktemp)"; sed "s|REPLACE:FLUTTER_FRAMEWORK_PATH|${INTO}|g" "$CR" > "$tmp" && mv "$tmp" "$CR"

cat <<EOF

deploy-repo: installed

Verify: bash ${INTO}/scripts/framework-verify.sh --root ${DEST}
Next:   @flutter-bootstrap init
EOF
