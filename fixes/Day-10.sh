#!/bin/bash
# Day 10 - Add History Limit
# Issue #10: history list grows unbounded
# Fix: Implement max history size (100 entries) and prune oldest

echo "Fix for issue #10 requires manual review of app_state.dart"
echo "Recommendation: Add check in addHistory to remove oldest when > 100 entries"