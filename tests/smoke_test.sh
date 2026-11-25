#!/usr/bin/env bash
# Smoke tests for my-agent-config/install.sh in an isolated temporary HOME
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO_DIR/install.sh"

TMP_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

TEST_HOME="$TMP_ROOT/home"
mkdir -p "$TEST_HOME"
export HOME="$TEST_HOME"

assert_file() {
    local path="$1"
    if [ ! -f "$path" ]; then
        printf '[FAIL] Expected file missing: %s\n' "$path" >&2
        exit 1
    fi
}

assert_contains() {
    local path="$1" pattern="$2"
    if ! grep -Fq "$pattern" "$path"; then
        printf '[FAIL] Expected %s to contain: %s\n' "$path" "$pattern" >&2
        exit 1
    fi
}

# 1. --help exits 0
"$INSTALLER" --help >/dev/null

# 2. Unknown option exits non-zero
if "$INSTALLER" --unknown-flag >/dev/null 2>&1; then
    printf '[FAIL] Expected unknown flag to fail\n' >&2
    exit 1
fi

# 3. Global install
out1="$("$INSTALLER" --global)"
assert_file "$TEST_HOME/.gemini/GEMINI.md"
assert_file "$TEST_HOME/.gemini/config/skills/ub-mode/SKILL.md"
assert_file "$TEST_HOME/.gemini/config/agents/implementer.md"
if ! printf '%s\n' "$out1" | grep -Fq "backed_up=0"; then
    printf '[FAIL] Expected backed_up=0 on fresh install\n' >&2
    exit 1
fi

# 4. Idempotency (second run skips unchanged files)
out2="$("$INSTALLER" --global)"
if ! printf '%s\n' "$out2" | grep -Fq "installed=0 updated=0"; then
    printf '[FAIL] Expected idempotent second run, got: %s\n' "$out2" >&2
    exit 1
fi

# 5. Backup on modified GEMINI.md
printf '# custom local override\n' > "$TEST_HOME/.gemini/GEMINI.md"
out3="$("$INSTALLER" --global --backup-dir "$TMP_ROOT/backups")"
if ! printf '%s\n' "$out3" | grep -Fq "updated=1" || ! printf '%s\n' "$out3" | grep -Fq "backed_up=1"; then
    printf '[FAIL] Expected 1 update and 1 backup, got: %s\n' "$out3" >&2
    exit 1
fi
assert_file "$TEST_HOME/.gemini/GEMINI.md"
cmp -s "$REPO_DIR/GEMINI.md" "$TEST_HOME/.gemini/GEMINI.md"
backup_count="$(find "$TMP_ROOT/backups" -type f -name 'GEMINI.md' | wc -l | tr -d ' ')"
if [ "$backup_count" -ne 1 ]; then
    printf '[FAIL] Expected 1 backup file in backup-dir, got %s\n' "$backup_count" >&2
    exit 1
fi

# 6. --dry-run does not create files
rm -rf "$TEST_HOME/.gemini"
"$INSTALLER" --global --dry-run >/dev/null
if [ -e "$TEST_HOME/.gemini/GEMINI.md" ]; then
    printf '[FAIL] --dry-run should not create GEMINI.md\n' >&2
    exit 1
fi

# 7. --force overwrites even when identical
"$INSTALLER" --global >/dev/null
out_force="$("$INSTALLER" --global --force)"
if ! printf '%s\n' "$out_force" | grep -Fq "skipped=0"; then
    printf '[FAIL] --force should not skip files, got: %s\n' "$out_force" >&2
    exit 1
fi

# 8. --project on git repository updates .git/info/exclude idempotently
PROJ_GIT="$TMP_ROOT/proj with spaces"
mkdir -p "$PROJ_GIT"
git -C "$PROJ_GIT" init -q
"$INSTALLER" --project "$PROJ_GIT" >/dev/null
"$INSTALLER" --project "$PROJ_GIT" >/dev/null
assert_file "$PROJ_GIT/.agents/rules/dotnet.md"
assert_file "$PROJ_GIT/.agents/workflows/ticket.md"
assert_contains "$PROJ_GIT/.git/info/exclude" ".agents/"
exclude_lines="$(grep -cxF '.agents/' "$PROJ_GIT/.git/info/exclude")"
if [ "$exclude_lines" -ne 1 ]; then
    printf '[FAIL] Expected .agents/ once in exclude, got %s\n' "$exclude_lines" >&2
    exit 1
fi

# 9. --project on non-git directory succeeds without .git
PROJ_NOGIT="$TMP_ROOT/proj-nogit"
mkdir -p "$PROJ_NOGIT"
"$INSTALLER" --project "$PROJ_NOGIT" >/dev/null
assert_file "$PROJ_NOGIT/.agents/rules/shell-dotfiles.md"
assert_file "$PROJ_NOGIT/.agents/workflows/ticket.md"

printf '[PASS] All my-agent-config smoke tests passed.\n'
