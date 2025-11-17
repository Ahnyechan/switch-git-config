#!/bin/bash

# Git Config Switcher
# Easy switching between git configurations

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: config.json not found!${NC}"
    echo "Please copy config.example.json to config.json and edit it with your settings:"
    echo "  cp config.example.json config.json"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: 'jq' is not installed. Using basic JSON parsing.${NC}"
    echo -e "${YELLOW}For better experience, install jq: brew install jq (macOS) or apt-get install jq (Linux)${NC}"
    echo ""
    USE_JQ=false
else
    USE_JQ=true
fi

# Parse config file
if [ "$USE_JQ" = true ]; then
    # Parse with jq (reliable)
    PROFILE_COUNT=$(jq '.profiles | length' "$CONFIG_FILE")

    # Read all profiles into arrays
    declare -a PROFILE_NAMES
    declare -a PROFILE_EMAILS
    declare -a PROFILE_LABELS

    for ((i=0; i<PROFILE_COUNT; i++)); do
        PROFILE_NAMES[$i]=$(jq -r ".profiles[$i].name" "$CONFIG_FILE")
        PROFILE_EMAILS[$i]=$(jq -r ".profiles[$i].email" "$CONFIG_FILE")
        PROFILE_LABELS[$i]=$(jq -r ".profiles[$i].label" "$CONFIG_FILE")
    done
else
    # Simple parsing without jq (less reliable but works for basic cases)
    PROFILE_COUNT=$(grep -o '"name"' "$CONFIG_FILE" | wc -l)

    declare -a PROFILE_NAMES
    declare -a PROFILE_EMAILS
    declare -a PROFILE_LABELS

    i=0
    while IFS= read -r line; do
        if [[ $line =~ \"name\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            PROFILE_NAMES[$i]="${BASH_REMATCH[1]}"
        elif [[ $line =~ \"email\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            PROFILE_EMAILS[$i]="${BASH_REMATCH[1]}"
        elif [[ $line =~ \"label\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            PROFILE_LABELS[$i]="${BASH_REMATCH[1]}"
            ((i++))
        fi
    done < "$CONFIG_FILE"

    PROFILE_COUNT=$i
fi

# Show current git configuration
show_current_config() {
    echo -e "${BLUE}Current Git Configuration:${NC}"
    echo "  Name: $(git config user.name)"
    echo "  Email: $(git config user.email)"
    echo ""
}

# Display current configuration
show_current_config

# Show menu
echo -e "${YELLOW}Which configuration would you like to switch to?${NC}"
for ((i=0; i<PROFILE_COUNT; i++)); do
    echo "$((i+1))) ${PROFILE_LABELS[$i]} (${PROFILE_NAMES[$i]} <${PROFILE_EMAILS[$i]}>)"
done
echo "$((PROFILE_COUNT+1))) Cancel"
echo ""
read -p "Select (1-$((PROFILE_COUNT+1))): " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
fi

# Handle selection
if [ "$choice" -eq "$((PROFILE_COUNT+1))" ]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
elif [ "$choice" -ge 1 ] && [ "$choice" -le "$PROFILE_COUNT" ]; then
    idx=$((choice-1))
    git config --global user.name "${PROFILE_NAMES[$idx]}"
    git config --global user.email "${PROFILE_EMAILS[$idx]}"
    echo -e "${GREEN}✓ Switched to ${PROFILE_LABELS[$idx]} account.${NC}"
else
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
fi

echo ""
show_current_config
