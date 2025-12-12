#!/bin/bash
# Validates required dependencies for workflow-toolkit plugin
# Outputs only missing dependencies for minimal context usage

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


# Session state file to track if validation already ran
STATE_FILE="/tmp/workflow-toolkit-deps-validated-$$"

# Check if validation already ran this session
if [ -f "$STATE_FILE" ]; then
    exit 0
fi

# Source run_silent.sh for helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/run_silent.sh"

# Required dependencies
REQUIRED_DEPS=("git-town" "gh" "humanlayer")
OPTIONAL_DEPS=("just")

MISSING=()

# Check required dependencies
for dep in "${REQUIRED_DEPS[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        MISSING+=("$dep")
    fi
done

# Check optional dependencies (but don't add to MISSING - just note)
for dep in "${OPTIONAL_DEPS[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        MISSING+=("$dep (optional)")
    fi
done

# Create state file to mark validation as complete
touch "$STATE_FILE"

# Output missing dependencies (if any)
if [ ${#MISSING[@]} -gt 0 ]; then
    printf "${RED}MISSING_DEPS: ${NC} %s\n"
    printf '%s\n' "${MISSING[@]}"
    exit 1
else
    printf "  ${GREEN}✓${NC}  %s\n" "All dependencies available"
    exit 0
fi
