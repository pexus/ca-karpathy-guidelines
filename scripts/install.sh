#!/usr/bin/env bash
#
# ca-karpathy-guidelines installer (v2)
# https://github.com/pexus/ca-karpathy-guidelines
#
# Features:
# - Safe: Always creates timestamped backups before any modification
# - Idempotent + Updatable: Replaces existing Karpathy section (even old versions)
# - Interactive or non-interactive (--agents flag)
# - Supports multiple agents
#
# Usage examples:
#   # Interactive (recommended for first run)
#   bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh)
#
#   # Non-interactive - specific agents
#   curl -sL .../install.sh | bash -s -- --agents grok,claude,cursor
#
#   # Non-interactive - all agents
#   curl -sL .../install.sh | bash -s -- --agents all --yes

set -euo pipefail

# --- Configuration ---------------------------------------------------------------
REPO_RAW_URL="https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main"
GUIDELINES_URL="${REPO_RAW_URL}/karpathy-guidelines.md"
CURSOR_MDC_URL="${REPO_RAW_URL}/.cursor/rules/karpathy-guidelines.mdc"
BACKUP_DIR=".karpathy-backups"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# --- Argument Parsing ------------------------------------------------------------
AGENTS_SPEC=""
NON_INTERACTIVE=false
ASSUME_YES=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agents)
            AGENTS_SPEC="$2"
            NON_INTERACTIVE=true
            shift 2
            ;;
        --yes|-y)
            ASSUME_YES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--agents grok,claude,cursor,copilot,all] [--yes]"
            echo ""
            echo "  --agents   Comma-separated list: grok,claude,cursor,copilot,all"
            echo "  --yes      Assume yes to prompts (use with --agents)"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# --- Safety Checks ---------------------------------------------------------------
if [[ ! -d .git ]]; then
    log_warn "This directory does not appear to be a git repository."
    if [[ "$ASSUME_YES" != true ]]; then
        read -r -p "Continue anyway? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Aborted."
            exit 0
        fi
    fi
fi

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_PREFIX="${BACKUP_DIR}/${TIMESTAMP}"
log_info "Backup directory: ${BACKUP_PREFIX}"

# --- Download Latest Guidelines --------------------------------------------------
log_info "Fetching latest guidelines..."

if ! GUIDELINES_CONTENT=$(curl -fsSL "$GUIDELINES_URL" 2>/dev/null); then
    log_error "Failed to download from GitHub."
    exit 1
fi

GUIDELINES_SECTION=$(echo "$GUIDELINES_CONTENT" | sed -n '/<!-- BEGIN karpathy-guidelines -->/,/<!-- END karpathy-guidelines -->/p')

if [[ -z "$GUIDELINES_SECTION" ]]; then
    log_error "Could not extract demarcated section."
    exit 1
fi

# --- Core Logic: Replace or Append -----------------------------------------------
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup_path="${BACKUP_PREFIX}-$(basename "$file")"
        cp "$file" "$backup_path"
        log_success "Backed up: $file → $backup_path"
    fi
}

# This is the key improved function: replaces existing block or appends
upsert_karpathy_section() {
    local file="$1"
    local new_content="$2"
    local heading="${3:-Karpathy Behavioral Guidelines}"

    backup_file "$file"

    if [[ ! -f "$file" ]]; then
        cat > "$file" << 'EOF'
# AGENTS.md

This file contains instructions and behavioral guidelines for coding agents.

EOF
        log_info "Created new $file"
    fi

    if grep -q "BEGIN karpathy-guidelines" "$file" 2>/dev/null; then
        # Replace existing block (supports updating old versions)
        # We use a portable awk approach
        awk -v content="$new_content" '
            BEGIN { in_block=0; replaced=0 }
            /<!-- BEGIN karpathy-guidelines -->/ { 
                print "## '"$heading"'"
                print ""
                print content
                in_block=1; replaced=1; next 
            }
            /<!-- END karpathy-guidelines -->/ { in_block=0; next }
            in_block==0 { print }
            END {
                if (replaced==0) {
                    # Fallback (should not happen)
                    print "## '"$heading"'"
                    print ""
                    print content
                }
            }
        ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

        log_success "Replaced existing Karpathy section in $file (updated to latest)"
    else
        # Append fresh
        {
            echo ""
            echo "## $heading"
            echo ""
            echo "$new_content"
            echo ""
        } >> "$file"
        log_success "Appended Karpathy guidelines to $file"
    fi
}

# --- Agent Selection -------------------------------------------------------------
select_agents() {
    local spec="$1"

    SELECTED_GROK=false
    SELECTED_CLAUDE=false
    SELECTED_CURSOR=false
    SELECTED_COPILOT=false

    if [[ -z "$spec" ]]; then
        # Interactive mode
        echo
        log_info "Which coding agents / environments do you use?"
        echo "Enter numbers separated by space (e.g. 1 3 4), or 'a' for all:"
        echo
        echo "  1) Grok Build"
        echo "  2) Claude Code"
        echo "  3) Cursor"
        echo "  4) GitHub Copilot"
        echo "  5) None"
        echo
        read -r -p "Your choice: " choices

        if [[ "$choices" == "a" || "$choices" == "A" ]]; then
            SELECTED_GROK=true; SELECTED_CLAUDE=true
            SELECTED_CURSOR=true; SELECTED_COPILOT=true
        else
            for c in $choices; do
                case "$c" in
                    1) SELECTED_GROK=true ;;
                    2) SELECTED_CLAUDE=true ;;
                    3) SELECTED_CURSOR=true ;;
                    4) SELECTED_COPILOT=true ;;
                esac
            done
        fi
    else
        # Non-interactive
        spec_lower=$(echo "$spec" | tr '[:upper:]' '[:lower:]')
        if [[ "$spec_lower" == "all" ]]; then
            SELECTED_GROK=true; SELECTED_CLAUDE=true
            SELECTED_CURSOR=true; SELECTED_COPILOT=true
        else
            IFS=',' read -ra parts <<< "$spec_lower"
            for p in "${parts[@]}"; do
                p=$(echo "$p" | xargs) # trim
                case "$p" in
                    grok|groq)          SELECTED_GROK=true ;;
                    claude)             SELECTED_CLAUDE=true ;;
                    cursor)             SELECTED_CURSOR=true ;;
                    copilot|github)     SELECTED_COPILOT=true ;;
                    *) log_warn "Unknown agent: $p" ;;
                esac
            done
        fi
    fi
}

select_agents "$AGENTS_SPEC"

# --- Main Execution --------------------------------------------------------------
echo
log_info "Starting installation (safe + updatable mode)..."

AGENTS_FILE="AGENTS.md"
upsert_karpathy_section "$AGENTS_FILE" "$GUIDELINES_SECTION" "Karpathy Behavioral Guidelines"

# Thin references
if $SELECTED_CLAUDE; then
    create_thin_reference() {
        local path="$1" agent="$2"
        if [[ -f "$path" ]] && grep -qi "karpathy" "$path"; then
            log_warn "$path already references Karpathy guidelines."
            return
        fi
        backup_file "$path"
        mkdir -p "$(dirname "$path")"
        cat > "$path" << EOF
# $(basename "$path")

This project uses the Karpathy Behavioral Guidelines.

**Follow the demarcated section in [AGENTS.md](./AGENTS.md).**

These rules apply for ${agent}.
EOF
        log_success "Created thin reference: $path"
    }
    create_thin_reference "CLAUDE.md" "Claude Code"
fi

if $SELECTED_COPILOT; then
    create_thin_reference() {
        local path="$1" agent="$2"
        if [[ -f "$path" ]] && grep -qi "karpathy" "$path"; then
            log_warn "$path already references Karpathy guidelines."
            return
        fi
        backup_file "$path"
        mkdir -p "$(dirname "$path")"
        cat > "$path" << EOF
# $(basename "$path")

This project uses the Karpathy Behavioral Guidelines.

**Follow the demarcated section in [AGENTS.md](../../AGENTS.md).**

These rules apply for ${agent}.
EOF
        log_success "Created thin reference: $path"
    }
    create_thin_reference ".github/copilot-instructions.md" "GitHub Copilot"
fi

if $SELECTED_CURSOR; then
    CURSOR_RULE=".cursor/rules/karpathy-guidelines.mdc"
    backup_file "$CURSOR_RULE"
    mkdir -p ".cursor/rules"

    if MDC_CONTENT=$(curl -fsSL "$CURSOR_MDC_URL" 2>/dev/null); then
        echo "$MDC_CONTENT" > "$CURSOR_RULE"
        log_success "Installed Cursor rule: $CURSOR_RULE"
    else
        log_warn "Could not download Cursor .mdc file."
    fi
fi

# --- Summary ---------------------------------------------------------------------
echo
log_success "Done!"
log_info "Backups: $BACKUP_DIR/"

if [[ -d .git ]]; then
    echo
    echo "Next steps:"
    echo "  git status"
    echo "  git diff $AGENTS_FILE"
    echo "  git add $AGENTS_FILE CLAUDE.md .github .cursor 2>/dev/null || true"
    echo "  git commit -m 'docs: add/update Karpathy behavioral guidelines'"
fi

echo
log_info "The Karpathy section is now safely demarcated and updatable."
