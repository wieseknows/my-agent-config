#!/usr/bin/env bash
# Cross-platform installer for my-agent-config (Git Bash on Windows + Linux)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

INSTALL_GLOBAL=0
DRY_RUN=0
FORCE=0
BACKUP_DIR=""
PROJECTS=()

INSTALLED_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0
BACKUP_COUNT=0

log_info()  { printf '[INFO] %s\n' "$*"; }
log_warn()  { printf '[WARN] %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Install Antigravity global configuration (~/.gemini/) and/or project-level
rules and workflows (<project>/.agents/).

Options:
  --global             Install global config (GEMINI.md, skills/, agents/)
  --project <path>     Install rules/ and workflows/ into <path>/.agents/ (repeatable)
  --dry-run            Show planned actions without modifying any files
  --backup-dir <path>  Store timestamped backups under <path> instead of alongside targets
  --force              Overwrite destination files even when content hashes match
  -h, --help           Show this help message

If neither --global nor --project is specified, --global is assumed.
EOF
}

normalize_path() {
    local raw="$1"
    if command -v cygpath >/dev/null 2>&1 && [[ "$raw" =~ ^[A-Za-z]:[/\\] ]]; then
        cygpath -u "$raw"
    elif [[ "$raw" =~ ^([A-Za-z]):[/\\](.*)$ ]]; then
        local drive="${BASH_REMATCH[1],,}"
        local rest="${BASH_REMATCH[2]//\\//}"
        printf '/%s/%s\n' "$drive" "$rest"
    else
        printf '%s\n' "${raw//\\//}"
    fi
}

file_hash() {
    local path="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$path" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$path" | awk '{print $1}'
    else
        return 1
    fi
}

files_identical() {
    local src="$1" dst="$2"
    local h1 h2
    if h1="$(file_hash "$src" 2>/dev/null)" && h2="$(file_hash "$dst" 2>/dev/null)"; then
        [ "$h1" = "$h2" ]
    else
        cmp -s "$src" "$dst"
    fi
}

backup_file() {
    local dst="$1" rel="$2"
    local backup_path
    if [ -n "$BACKUP_DIR" ]; then
        backup_path="$BACKUP_DIR/$TIMESTAMP/$rel"
    else
        backup_path="${dst}.bak.${TIMESTAMP}"
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "[dry-run] Would back up $dst -> $backup_path"
    else
        mkdir -p "$(dirname "$backup_path")"
        cp -p "$dst" "$backup_path"
        log_info "Backed up $dst -> $backup_path"
    fi
    BACKUP_COUNT=$((BACKUP_COUNT + 1))
}

install_file() {
    local src="$1" dst="$2" rel="$3"

    if [ ! -f "$src" ]; then
        log_warn "Source file missing, skipping: $src"
        return 0
    fi

    local action="Installed"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -f "$dst" ] && [ ! -L "$dst" ] && files_identical "$src" "$dst" && [ "$FORCE" -eq 0 ]; then
            log_info "Unchanged: $dst"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            return 0
        fi
        # Only back up when the existing target actually differs from the source
        if [ ! -f "$dst" ] || [ -L "$dst" ] || ! files_identical "$src" "$dst"; then
            backup_file "$dst" "$rel"
        fi
        action="Updated"
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "[dry-run] Would copy ($action): $src -> $dst"
    else
        mkdir -p "$(dirname "$dst")"
        # Copy instead of symlinking because Windows Git Bash symlinks are unreliable
        cp "$src" "$dst"
        log_info "$action: $dst"
    fi

    if [ "$action" = "Installed" ]; then
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        UPDATED_COUNT=$((UPDATED_COUNT + 1))
    fi
}

install_dir() {
    local src_dir="$1" dst_dir="$2" backup_prefix="$3"
    if [ ! -d "$src_dir" ]; then
        log_warn "Source directory missing, skipping: $src_dir"
        return 0
    fi

    local src_file rel
    while IFS= read -r src_file; do
        [ -n "$src_file" ] || continue
        rel="${src_file#"$src_dir"/}"
        install_file "$src_file" "$dst_dir/$rel" "$backup_prefix/$rel"
    done < <(find "$src_dir" -type f | sort)
}

ensure_git_exclude() {
    local project_dir="$1"
    if ! command -v git >/dev/null 2>&1; then
        return 0
    fi
    if ! git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
        log_info "Not a git repository, skipping .git/info/exclude: $project_dir"
        return 0
    fi

    local exclude_file
    exclude_file="$(git -C "$project_dir" rev-parse --git-path info/exclude)"
    if [[ "$exclude_file" != /* ]]; then
        exclude_file="$project_dir/$exclude_file"
    fi

    if [ -f "$exclude_file" ] && grep -qxE '\.agents/?' "$exclude_file"; then
        log_info ".agents/ already excluded in $exclude_file"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "[dry-run] Would add .agents/ to $exclude_file"
        return 0
    fi

    mkdir -p "$(dirname "$exclude_file")"
    if [ -s "$exclude_file" ] && [ -n "$(tail -c 1 "$exclude_file")" ]; then
        printf '\n' >> "$exclude_file"
    fi
    printf '.agents/\n' >> "$exclude_file"
    log_info "Added .agents/ to $exclude_file"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --global)
            INSTALL_GLOBAL=1
            shift
            ;;
        --project)
            if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
                log_error "--project requires a path argument"
                exit 1
            fi
            PROJECTS+=("$(normalize_path "$2")")
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --backup-dir)
            if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
                log_error "--backup-dir requires a path argument"
                exit 1
            fi
            BACKUP_DIR="$(normalize_path "$2")"
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage >&2
            exit 1
            ;;
    esac
done

if [ "$INSTALL_GLOBAL" -eq 0 ] && [ ${#PROJECTS[@]} -eq 0 ]; then
    INSTALL_GLOBAL=1
fi

if [ "$DRY_RUN" -eq 1 ]; then
    log_info "Dry-run mode enabled; no files will be modified"
fi

if [ "$INSTALL_GLOBAL" -eq 1 ]; then
    gemini_dir="$HOME/.gemini"
    log_info "Installing global configuration to $gemini_dir"
    install_file "$SCRIPT_DIR/GEMINI.md" "$gemini_dir/GEMINI.md" "global/GEMINI.md"
    install_dir "$SCRIPT_DIR/skills" "$gemini_dir/config/skills" "global/config/skills"
    install_dir "$SCRIPT_DIR/agents" "$gemini_dir/config/agents" "global/config/agents"
fi

if [ ${#PROJECTS[@]} -gt 0 ]; then
    for proj_path in "${PROJECTS[@]}"; do
        if [ ! -d "$proj_path" ]; then
            log_error "Project directory does not exist: $proj_path"
            exit 1
        fi
        log_info "Installing project configuration to $proj_path/.agents"
        proj_slug="$(basename "$proj_path")"
        install_dir "$SCRIPT_DIR/rules" "$proj_path/.agents/rules" "projects/$proj_slug/.agents/rules"
        install_dir "$SCRIPT_DIR/workflows" "$proj_path/.agents/workflows" "projects/$proj_slug/.agents/workflows"
        ensure_git_exclude "$proj_path"
    done
fi

log_info "Summary: installed=$INSTALLED_COUNT updated=$UPDATED_COUNT skipped=$SKIPPED_COUNT backed_up=$BACKUP_COUNT"
