#!/bin/bash
set -e

DAY_NUM=$1
DAY_PAD=$2

# Map day to issue number
ISSUE_NUM=$DAY_NUM

# Check if fix file exists
FIX_FILE="fixes/Day-${DAY_PAD}.sh"
if [ ! -f "$FIX_FILE" ]; then
    echo "No fix file found for Day ${DAY_PAD}"
    exit 0
fi

# Source the fix script
source "$FIX_FILE"

echo "Applied fix for Day ${DAY_PAD} (Issue #${ISSUE_NUM})"