#!/bin/bash
# Day 18 - Remove Unused Dependency

# The issue: cupertino_icons not used
# Fix: Remove from pubspec.yaml

sed -i '/cupertino_icons/d' pubspec.yaml 2>/dev/null || true

echo "Removed unused cupertino_icons issue #18"