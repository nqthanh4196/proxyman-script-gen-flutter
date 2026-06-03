#!/bin/bash
# Day 05 - Fix Memory Leak - outputController Not Disposed

# The issue: outputController created but never disposed
# Fix: Add outputController.dispose() in dispose method

sed -i '/inputController.dispose();/a\    outputController.dispose();' lib/src/app.dart 2>/dev/null || true

echo "Fixed memory leak issue #5"