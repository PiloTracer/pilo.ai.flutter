#!/usr/bin/env bash
# Flutter Agent OS — project memory scaffold.
#
# Creates .work.flutter/ and the root toolchain files in a target repository.
# Idempotent and brownfield-safe: existing files are NEVER overwritten unless
# --overwrite-all is passed explicitly.
#
# Invoked by @flutter-bootstrap init. Safe to run directly.
#
# Usage:
#   bootstrap.sh [--repo <path>] [--mode overwrite-missing|keep|overwrite-all]
#                [--project <name>] [--dry-run]
#
# Exit codes: 0 ok · 1 usage or resolution error · 2 refused (would overwrite)

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="${FRAMEWORK_ROOT}/templates"

REPO=""
MODE="overwrite-missing"
PROJECT=""
DRY_RUN=0
CREATED=0
SKIPPED=0
OVERWRITTEN=0

die()  { printf 'error: %s\n' "$1" >&2; exit "${2:-1}"; }
info() { printf '%s\n' "$1"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)     REPO="${2:-}"; shift 2 ;;
    --mode)     MODE="${2:-}"; shift 2 ;;
    --project)  PROJECT="${2:-}"; shift 2 ;;
    --dry-run)  DRY_RUN=1; shift ;;
    -h|--help)  sed -n '2,20p' "$0"; exit 0 ;;
    *)          die "unknown argument: $1" ;;
  esac
done

case "$MODE" in
  overwrite-missing|keep|overwrite-all) ;;
  *) die "invalid --mode: $MODE (overwrite-missing|keep|overwrite-all)" ;;
esac

# ---------------------------------------------------------------- resolve repo
if [ -z "$REPO" ]; then
  REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
[ -d "$REPO" ] || die "repo root does not exist: $REPO"
REPO="$(cd "$REPO" && pwd)"

# Refuse to scaffold the framework into itself.
if [ "$REPO" = "$FRAMEWORK_ROOT" ]; then
  die "refusing to bootstrap the framework directory into itself" 2
fi

[ -n "$PROJECT" ] || PROJECT="$(basename "$REPO")"

WORK="${REPO}/.work.flutter"

# ------------------------------------------------------------------- utilities
# write_file <dest> <source>   — copy a template, honouring MODE
write_file() {
  local dest="$1" src="$2"
  [ -f "$src" ] || die "missing template: $src"

  if [ -e "$dest" ]; then
    case "$MODE" in
      keep|overwrite-missing)
        SKIPPED=$((SKIPPED + 1))
        [ "$DRY_RUN" -eq 1 ] && info "  skip      ${dest#"$REPO"/}"
        return 0 ;;
      overwrite-all)
        OVERWRITTEN=$((OVERWRITTEN + 1)) ;;
    esac
  else
    CREATED=$((CREATED + 1))
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    info "  write     ${dest#"$REPO"/}"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

make_dir() {
  [ "$DRY_RUN" -eq 1 ] && { info "  mkdir     ${1#"$REPO"/}"; return 0; }
  mkdir -p "$1"
}

# Fill only the tokens bootstrap legitimately knows. Everything else stays as
# REPLACE: so the token audit can report it. Guessing a value here would be
# worse than leaving the placeholder visible.
fill_tokens() {
  [ "$DRY_RUN" -eq 1 ] && return 0
  local f="$1"
  [ -f "$f" ] || return 0
  local tmp; tmp="$(mktemp)"
  sed -e "s|REPLACE:FLUTTER_PROJECT_NAME|${PROJECT}|g" \
      -e "s|REPLACE:FLUTTER_BOOTSTRAP_DATE|$(date +%Y-%m-%d)|g" \
      -e "s|REPLACE:FLUTTER_FRAMEWORK_PATH|${FRAMEWORK_ROOT}|g" \
      "$f" > "$tmp" && mv "$tmp" "$f"
}

# ----------------------------------------------------------------- brownfield
BROWNFIELD=""
[ -d "$WORK" ]                       && BROWNFIELD="${BROWNFIELD} .work.flutter/"
[ -f "${REPO}/.cursorrules" ]        && BROWNFIELD="${BROWNFIELD} .cursorrules"
[ -f "${REPO}/pubspec.yaml" ]        && BROWNFIELD="${BROWNFIELD} pubspec.yaml"
[ -d "${REPO}/lib" ]                 && BROWNFIELD="${BROWNFIELD} lib/"
[ -f "${REPO}/analysis_options.yaml" ] && BROWNFIELD="${BROWNFIELD} analysis_options.yaml"

if [ -n "$BROWNFIELD" ] && [ "$MODE" = "overwrite-all" ] && [ "$DRY_RUN" -eq 0 ]; then
  info "WARNING: --overwrite-all with existing artifacts:${BROWNFIELD}"
fi

info "Flutter Agent OS bootstrap"
info "  framework : ${FRAMEWORK_ROOT}"
info "  repo      : ${REPO}"
info "  project   : ${PROJECT}"
info "  mode      : ${MODE}$([ "$DRY_RUN" -eq 1 ] && echo ' (dry run)')"
info "  existing  :${BROWNFIELD:- none}"
info ""

# ------------------------------------------------------------- directory tree
for d in \
  "${WORK}" \
  "${WORK}/context" \
  "${WORK}/plans/foundation" \
  "${WORK}/plans/full" \
  "${WORK}/plans/proposals" \
  "${WORK}/plans/archives" \
  "${WORK}/plans/operations" \
  "${WORK}/features" \
  "${WORK}/standards" \
  "${WORK}/decisions" \
  "${WORK}/concepts" \
  "${WORK}/reports" \
  "${WORK}/prompts" \
  "${WORK}/analysis" \
  "${WORK}/docs/guides" \
  "${WORK}/docs/tutorials" \
  "${WORK}/docs/reference" \
  ; do make_dir "$d"; done

# ------------------------------------------------------------ project memory
T="${TEMPLATES}/work.flutter"
write_file "${WORK}/README.md"                              "${T}/README.md"
write_file "${WORK}/STACK.md"                               "${T}/STACK.md"
write_file "${WORK}/touch-scope"                            "${T}/touch-scope"
write_file "${WORK}/context/HANDOFF_FLUTTER.md"             "${T}/context/HANDOFF_FLUTTER.md"
write_file "${WORK}/plans/NEXT_FLUTTER.md"                  "${T}/plans/NEXT_FLUTTER.md"
write_file "${WORK}/plans/ASSUMPTIONS.md"                   "${T}/plans/ASSUMPTIONS.md"
write_file "${WORK}/plans/RISK_REGISTRY.md"                 "${T}/plans/RISK_REGISTRY.md"
write_file "${WORK}/plans/UNKNOWNS.md"                      "${T}/plans/UNKNOWNS.md"
write_file "${WORK}/plans/foundation/README.md"             "${T}/plans/foundation/README.md"
write_file "${WORK}/plans/foundation/PROBE_LEDGER.md"       "${T}/plans/foundation/PROBE_LEDGER.md"
write_file "${WORK}/features/README.md"                     "${T}/features/README.md"
write_file "${WORK}/decisions/README.md"                    "${T}/decisions/README.md"
write_file "${WORK}/reports/README.md"                      "${T}/reports/README.md"
write_file "${WORK}/prompts/README.md"                      "${T}/prompts/README.md"
write_file "${WORK}/docs/README.md"                         "${T}/docs/README.md"
write_file "${WORK}/standards/PROTECTED_SURFACES.json"      "${FRAMEWORK_ROOT}/standards/PROTECTED_SURFACES.json"

# ---------------------------------------------------------------- root files
write_file "${REPO}/DOCS_FLUTTER_STACK.md"   "${TEMPLATES}/DOCS_FLUTTER_STACK.md.template"
write_file "${REPO}/analysis_options.yaml"   "${TEMPLATES}/analysis_options.yaml.template"

# .cursorrules: create, or append the marker block. NEVER clobber - the file
# may carry rules for .ai / .ai.ui.
CURSORRULES="${REPO}/.cursorrules"
SNIPPET="${TEMPLATES}/cursorrules.flutter.snippet.template"
if [ ! -f "$CURSORRULES" ]; then
  write_file "$CURSORRULES" "${TEMPLATES}/cursorrules.flutter.template"
  if [ "$DRY_RUN" -eq 0 ] && grep -q 'REPLACE:FLUTTER_SNIPPET_BLOCK' "$CURSORRULES"; then
    tmp="$(mktemp)"
    awk -v snip="$SNIPPET" '
      /REPLACE:FLUTTER_SNIPPET_BLOCK/ { while ((getline line < snip) > 0) print line; next }
      { print }
    ' "$CURSORRULES" > "$tmp" && mv "$tmp" "$CURSORRULES"
  fi
elif grep -q 'FLUTTER_AGENT_OS_BEGIN' "$CURSORRULES" 2>/dev/null; then
  info "  keep      .cursorrules (Flutter block already present - update it in place)"
  SKIPPED=$((SKIPPED + 1))
else
  if [ "$DRY_RUN" -eq 0 ]; then
    printf '\n\n' >> "$CURSORRULES"
    cat "$SNIPPET" >> "$CURSORRULES"
  fi
  info "  append    .cursorrules (Flutter block appended; existing rules preserved)"
fi

# .gitignore: append only what is missing.
GITIGNORE="${REPO}/.gitignore"
if [ "$DRY_RUN" -eq 0 ]; then
  touch "$GITIGNORE"
  added=0
  while IFS= read -r line; do
    case "$line" in ''|\#*) continue ;; esac
    if ! grep -qxF "$line" "$GITIGNORE" 2>/dev/null; then
      [ "$added" -eq 0 ] && printf '\n# Flutter Agent OS\n' >> "$GITIGNORE"
      printf '%s\n' "$line" >> "$GITIGNORE"
      added=$((added + 1))
    fi
  done < "${TEMPLATES}/gitignore.flutter.snippet"
  [ "$added" -gt 0 ] && info "  append    .gitignore (${added} entries)"
fi

# ------------------------------------------------------------- token filling
if [ "$DRY_RUN" -eq 0 ]; then
  while IFS= read -r f; do fill_tokens "$f"; done < <(
    find "$WORK" -type f \( -name '*.md' -o -name '*.json' \) 2>/dev/null
  )
  fill_tokens "${REPO}/DOCS_FLUTTER_STACK.md"
  fill_tokens "${REPO}/analysis_options.yaml"
  fill_tokens "$CURSORRULES"
fi

# ------------------------------------------------------------------- summary
info ""
info "  created: ${CREATED}  skipped: ${SKIPPED}  overwritten: ${OVERWRITTEN}"

if [ "$DRY_RUN" -eq 0 ]; then
  REMAINING="$(grep -rl 'REPLACE:' "$WORK" "${REPO}/DOCS_FLUTTER_STACK.md" \
                 "${REPO}/analysis_options.yaml" "$CURSORRULES" 2>/dev/null | wc -l | tr -d ' ')"
  info "  files with unreplaced REPLACE: tokens: ${REMAINING}"
  info ""
  info "Next:"
  info "  1. Fill REPLACE: tokens the operator owns (project name is done; task ref prefix is not)"
  info "  2. bash ${FRAMEWORK_ROOT}/scripts/install-git-hooks.sh --repo ${REPO}"
  info "  3. @flutter-stack probe"
  if [ -d "${REPO}/lib" ]; then
    info "  4. @flutter-plan-verify brownfield    (existing code detected - recover, do not invent)"
  else
    info "  4. @flutter-foundation greenfield"
  fi
fi
