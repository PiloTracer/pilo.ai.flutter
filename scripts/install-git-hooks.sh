#!/usr/bin/env bash
# Installs the Flutter Agent OS git hooks into a repository.
#
# Existing non-framework hooks are preserved as <hook>.local and chained, never
# deleted. A team's existing hook is their decision, not ours to discard.
#
# Usage: install-git-hooks.sh [--repo <path>] [--uninstall] [--force]
# Exit: 0 ok · 1 error

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_SRC="${FRAMEWORK_ROOT}/hooks"
REPO=""
UNINSTALL=0
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)      REPO="${2:-}"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    --force)     FORCE=1; shift ;;
    -h|--help)   sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$REPO" ] || REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
REPO="$(cd "$REPO" && pwd)"
GITDIR="$(cd "$REPO" && git rev-parse --git-dir 2>/dev/null || true)"

if [ -z "$GITDIR" ]; then
  echo "install-git-hooks: no .git directory in ${REPO} — skipped"
  exit 0
fi
case "$GITDIR" in /*) ;; *) GITDIR="${REPO}/${GITDIR}" ;; esac
DEST="${GITDIR}/hooks"
mkdir -p "$DEST"

HOOKS="pre-commit commit-msg prepare-commit-msg post-commit pre-push"

if [ "$UNINSTALL" -eq 1 ]; then
  for h in $HOOKS; do
    if [ -f "${DEST}/${h}" ] && grep -q 'FLUTTER_AGENT_OS_HOOK' "${DEST}/${h}" 2>/dev/null; then
      rm -f "${DEST}/${h}"
      if [ -f "${DEST}/${h}.local" ]; then
        mv "${DEST}/${h}.local" "${DEST}/${h}"
        echo "  restored ${h} from ${h}.local"
      else
        echo "  removed  ${h}"
      fi
    fi
  done
  echo "install-git-hooks: uninstalled"
  exit 0
fi

echo "Installing Flutter Agent OS hooks into ${DEST}"
INSTALLED=0

for h in $HOOKS; do
  src="${HOOKS_SRC}/${h}"
  dst="${DEST}/${h}"
  [ -f "$src" ] || { echo "  skip     ${h} (no source)"; continue; }

  if [ -f "$dst" ] && ! grep -q 'FLUTTER_AGENT_OS_HOOK' "$dst" 2>/dev/null; then
    if [ -f "${dst}.local" ] && [ "$FORCE" -eq 0 ]; then
      echo "  WARN     ${h}: ${h}.local already exists — not overwriting. Use --force." >&2
      continue
    fi
    mv "$dst" "${dst}.local"
    chmod +x "${dst}.local"
    echo "  preserve ${h} -> ${h}.local (will be chained)"
  fi

  cp "$src" "$dst"
  chmod +x "$dst"

  # Point the hook at the framework so it can find the scripts.
  tmp="$(mktemp)"
  sed "s|__FLUTTER_AGENT_OS_ROOT__|${FRAMEWORK_ROOT}|g" "$dst" > "$tmp" && mv "$tmp" "$dst"
  chmod +x "$dst"

  INSTALLED=$((INSTALLED + 1))
  echo "  install  ${h}"
done

cat <<EOF

install-git-hooks: ${INSTALLED} hooks installed

  pre-commit          format, analyze, secrets, touch-scope, blast radius
  commit-msg          rejects AI attribution; warns on a missing task ref
  prepare-commit-msg  prepends the active task id when one is known
  post-commit         records the commit for later gate reconciliation
  pre-push            runs the test suite

Bypass with --no-verify only as a deliberate human decision. Agents never bypass.
Uninstall: ${FRAMEWORK_ROOT}/scripts/install-git-hooks.sh --repo ${REPO} --uninstall
EOF
