# 30-Day Code Fix Plan

This directory contains daily fix scripts for the 30 issues identified in CODE_REVIEW.md.

## How it works

Each `Day-XX.sh` script fixes one issue from the code review. The workflow runs daily at 12:00 PM Vietnam time (UTC+7) and applies the next fix.

## Schedule

| Day | Issue # | Title |
|-----|---------|-------|
| 01 | #1 | Syntax Error in app.dart Line 741 |
| 02 | #2 | Unhandled Async in initState |
| 03 | #3 | JavaScript Injection Vulnerability |
| 04 | #4 | Broken Widget Test |
| 05 | #5 | Memory Leak - outputController Not Disposed |
| 06 | #6 | Potential Data Loss in addHistory |
| 07 | #7 | No Debouncing on Settings |
| 08 | #8 | No Port Validation |
| 09 | #9 | Fake Feedback Submission |
| 10 | #10 | No History Limit |
| 11 | #11 | Broken Tests |
| 12 | #12 | Synchronous File I/O |
| 13 | #13 | No Error Boundary |
| 14 | #14 | Over-Notifying Listeners |
| 15 | #15 | Hardcoded Color |
| 16 | #16 | No Clear History Confirmation |
| 17 | #17 | Multi-line JSON Collapsed |
| 18 | #18 | Unused pubspec Dependency |
| 19 | #19 | Generated ID Collision Risk |
| 20 | #20 | No Input Validation in beautify |
| 21 | #21 | Magic Numbers |
| 22 | #22 | Hardcoded Theme Strings |
| 23 | #23 | Large Method _currentView() |
| 24 | #24 | No Accessibility Labels |
| 25 | #25 | No Keyboard Shortcuts |
| 26 | #26 | No Loading Indicator |
| 27 | #27 | No Empty Input Validation |
| 28 | #28 | Console.log with Emoji |
| 29 | #29 | Settings Not Persisted on Crash |
| 30 | #30 | No Validation Feedback |

## Manual Trigger

To trigger manually, use repository dispatch:
```bash
gh workflow run daily-fix.yml -f day=5
```

Or via GitHub API:
```bash
gh api repos/nqthanh4196/proxyman-script-gen-flutter/dispatches -f event_type=daily-fix
```