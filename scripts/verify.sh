#!/usr/bin/env bash
#
# verify.sh - Check if Karpathy Behavioral Guidelines are properly installed
# Exit code: 0 = good, 1 = missing or incomplete

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok=0
fail=0

check() {
    local name="$1"
    local condition="$2"

    if eval "$condition"; then
        echo -e "  ${GREEN}✓${NC} $name"
        ((ok++))
    else
        echo -e "  ${RED}✗${NC} $name"
        ((fail++))
    fi
}

echo -e "${BLUE}=== Karpathy Guidelines Verification ===${NC}"
echo

# Check main AGENTS.md
check "AGENTS.md exists"                  "[[ -f AGENTS.md ]]"
check "Karpathy section present in AGENTS.md" "grep -q 'BEGIN karpathy-guidelines' AGENTS.md 2>/dev/null"

# Optional but recommended thin files
if [[ -f CLAUDE.md ]]; then
    check "CLAUDE.md references Karpathy" "grep -qi 'karpathy' CLAUDE.md"
else
    echo -e "  ${YELLOW}○${NC} CLAUDE.md (not present)"
fi

if [[ -f .github/copilot-instructions.md ]]; then
    check "copilot-instructions.md references Karpathy" "grep -qi 'karpathy' .github/copilot-instructions.md"
else
    echo -e "  ${YELLOW}○${NC} .github/copilot-instructions.md (not present)"
fi

if [[ -f .cursor/rules/karpathy-guidelines.mdc ]]; then
    check "Cursor .mdc rule present" "[[ -f .cursor/rules/karpathy-guidelines.mdc ]]"
else
    echo -e "  ${YELLOW}○${NC} .cursor/rules/karpathy-guidelines.mdc (not present)"
fi

echo
if [[ $fail -eq 0 ]]; then
    echo -e "${GREEN}All critical checks passed.${NC}"
    exit 0
else
    echo -e "${RED}${fail} check(s) failed.${NC}"
    echo "Run the installer to fix:"
    echo "  bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh)"
    exit 1
fi
