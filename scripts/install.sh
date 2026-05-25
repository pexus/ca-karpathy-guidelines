#!/usr/bin/env bash
#
# ca-karpathy-guidelines installer
# https://github.com/pexus/ca-karpathy-guidelines
#
# Safely appends the Karpathy Behavioral Guidelines into an existing (or new)
# AGENTS.md file, and creates thin reference files for chosen coding agents.
#
# Usage (recommended):
#   bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh)
#
# Or locally:
#   ./scripts/install.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_RAW_URL="https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main"
GUIDELINES_URL="${REPO_RAW_URL}/karpathy-guidelines.md"
BACKUP_DIR=".karpathy-backups"

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# --- Safety & Environment Checks -------------------------------------------------

if [[ ! -d .git ]]; then
    log_warn "This directory does not appear to be a git repository."
    read -r -p "Continue anyway? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Aborted."
        exit 0
    fi
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_PREFIX="${BACKUP_DIR}/${TIMESTAMP}"

log_info "Backup directory: ${BACKUP_PREFIX}"

# --- Download latest guidelines ----------------------------------------------------

log_info "Fetching latest karpathy-guidelines.md ..."
if ! GUIDELINES_CONTENT=$(curl -fsSL "$GUIDELINES_URL" 2>/dev/null); then
    log_error "Failed to download guidelines from GitHub."
    log_error "Please check your internet connection or run the script from a cloned copy."
    exit 1
fi

# Extract only the demarcated section (between BEGIN and END markers)
GUIDELINES_SECTION=$(echo "$GUIDELINES_CONTENT" | sed -n '/<!-- BEGIN karpathy-guidelines -->/,/<!-- END karpathy-guidelines -->/p')

if [[ -z "$GUIDELINES_SECTION" ]]; then
    log_error "Could not find the demarcated guidelines section in the downloaded file."
    exit 1
fi

# --- Helper Functions --------------------------------------------------------------

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup_path="${BACKUP_PREFIX}-$(basename "$file")"
        cp "$file" "$backup_path"
        log_success "Backed up: $file → $backup_path"
        echo "$backup_path"
    fi
}

file_contains_karpathy_section() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -q "BEGIN karpathy-guidelines" "$file" 2>/dev/null
    else
        return 1
    fi
}

append_to_file() {
    local file="$1"
    local content="$2"
    local heading="$3"

    if [[ ! -f "$file" ]]; then
        echo -e "# ${file}\n\nThis file contains instructions for coding agents.\n" > "$file"
        log_info "Created new file: $file"
    fi

    if file_contains_karpathy_section "$file"; then
        log_warn "$file already contains the Karpathy guidelines section. Skipping append."
        return 0
    fi

    {
        echo ""
        echo "## ${heading}"
        echo ""
        echo "$content"
        echo ""
    } >> "$file"

    log_success "Appended Karpathy guidelines to $file"
}

create_thin_reference() {
    local file="$1"
    local target="$2"
    local agent_name="$3"

    if [[ -f "$file" ]]; then
        if grep -qi "karpathy" "$file" 2>/dev/null; then
            log_warn "$file already references Karpathy guidelines. Skipping."
            return 0
        fi
        backup_file "$file" >/dev/null
    fi

    mkdir -p "$(dirname "$file")"

    cat > "$file" << EOF
# $(basename "$file")

This project uses the Karpathy Behavioral Guidelines for coding agents.

**Please follow the demarcated "Karpathy Behavioral Guidelines" section in [${target}](./${target}).**

The pure guidelines are also available in \`karpathy-guidelines.md\` at the root of this repository.

These rules apply when using ${agent_name}.
EOF

    log_success "Created/updated thin reference: $file"
}

# --- User Interaction --------------------------------------------------------------

echo
log_info "=== Karpathy Guidelines Installer ==="
echo

# Detect existing AGENTS.md
AGENTS_FILE="AGENTS.md"
if [[ -f "$AGENTS_FILE" ]]; then
    log_info "Found existing ${AGENTS_FILE}"
else
    log_info "No ${AGENTS_FILE} found in current directory."
fi

echo
log_info "Which coding agents / environments do you use in this project?"
echo "Enter numbers separated by space (e.g. 1 3 4), or 'a' for all:"
echo
echo "  1) Grok Build"
echo "  2) Claude Code"
echo "  3) Cursor"
echo "  4) GitHub Copilot"
echo "  5) None / I'll add them myself later"
echo

read -r -p "Your choice: " choices

SELECTED_GROK=false
SELECTED_CLAUDE=false
SELECTED_CURSOR=false
SELECTED_COPILOT=false

if [[ "$choices" == "a" || "$choices" == "A" ]]; then
    SELECTED_GROK=true
    SELECTED_CLAUDE=true
    SELECTED_CURSOR=true
    SELECTED_COPILOT=true
else
    for c in $choices; do
        case "$c" in
            1) SELECTED_GROK=true ;;
            2) SELECTED_CLAUDE=true ;;
            3) SELECTED_CURSOR=true ;;
            4) SELECTED_COPILOT=true ;;
            5) : ;; # none
            *) log_warn "Unknown option: $c" ;;
        esac
    done
fi

# --- Main Logic --------------------------------------------------------------------

echo
log_info "Starting installation..."

# Always ensure AGENTS.md exists and has the guidelines
if [[ -f "$AGENTS_FILE" ]]; then
    backup_file "$AGENTS_FILE" >/dev/null
fi

if file_contains_karpathy_section "$AGENTS_FILE"; then
    log_warn "${AGENTS_FILE} already contains the Karpathy section."
else
    append_to_file "$AGENTS_FILE" "$GUIDELINES_SECTION" "Karpathy Behavioral Guidelines"
fi

# Create thin references for selected agents
if $SELECTED_CLAUDE; then
    create_thin_reference "CLAUDE.md" "AGENTS.md" "Claude Code"
fi

if $SELECTED_COPILOT; then
    create_thin_reference ".github/copilot-instructions.md" "AGENTS.md" "GitHub Copilot"
fi

if $SELECTED_CURSOR; then
    # For Cursor we also offer the stronger .mdc file
    CURSOR_RULE=".cursor/rules/karpathy-guidelines.mdc"
    if [[ -f "$CURSOR_RULE" ]]; then
        if grep -qi "karpathy" "$CURSOR_RULE" 2>/dev/null; then
            log_warn "$CURSOR_RULE already exists with Karpathy content. Skipping."
        else
            backup_file "$CURSOR_RULE" >/dev/null
        fi
    fi

    mkdir -p ".cursor/rules"

    # Download the official .mdc version
    if MDC_CONTENT=$(curl -fsSL "${REPO_RAW_URL}/.cursor/rules/karpathy-guidelines.mdc" 2>/dev/null); then
        echo "$MDC_CONTENT" > "$CURSOR_RULE"
        log_success "Installed Cursor rule: $CURSOR_RULE"
    else
        log_warn "Could not download Cursor .mdc file. You can add it manually later."
    fi
fi

# --- Summary & Git hints -----------------------------------------------------------

echo
log_success "Installation complete!"
echo
log_info "Backups were saved in: ${BACKUP_DIR}/"
echo

if [[ -d .git ]]; then
    echo "Suggested next steps:"
    echo "  git status"
    echo "  git diff ${AGENTS_FILE}"
    echo "  git add ${AGENTS_FILE} CLAUDE.md .github/ .cursor/ 2>/dev/null || true"
    echo "  git commit -m \"docs: add Karpathy behavioral guidelines for coding agents\""
fi

echo
log_info "You can re-run this script safely at any time. It will not duplicate the guidelines."
echo

# Optional: show the user where the section was added
if [[ -f "$AGENTS_FILE" ]]; then
    log_info "The Karpathy section is now demarcated in ${AGENTS_FILE} with:"
    echo "    <!-- BEGIN karpathy-guidelines -->"
    echo "    ... guidelines ..."
    echo "    <!-- END karpathy-guidelines -->"
fi
