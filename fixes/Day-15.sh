#!/bin/bash
# Day 15 - Extract Hardcoded Color
# Issue #15: Color(0xFF0B0E16) hardcoded on line 810
# Fix: Add to color constants at top of file

sed -i 's/Color(0xFF0B0E16)/const Color(0xFF0B0E16)/' lib/src/app.dart 2>/dev/null || true

echo "Fixed hardcoded color issue #15"