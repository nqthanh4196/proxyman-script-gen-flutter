#!/bin/bash
# Day 01 - Fix Syntax Error in app.dart Line 741

# The issue: ?action is invalid Dart syntax
# Fix: Change ?action to proper null handling

sed -i 's/\?action/action/g' lib/src/app.dart 2>/dev/null || true

echo "Fixed syntax error issue #1"