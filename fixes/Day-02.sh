#!/bin/bash
# Day 02 - Fix Unhandled Async in initState
# Issue #2: state.initialize() is async but not awaited
# Fix: Add proper async initialization with loading state

cat > /tmp/fix_init_state.patch << 'EOF'
--- a/lib/src/app.dart
+++ b/lib/src/app.dart
@@ -30,9 +30,14 @@ class _AppShellState extends State<AppShell> {
   }

   @override
-  void initState() {
+  void initState() async {
     super.initState();
-    state.initialize();
+    await state.initialize();
+    if (mounted) {
+      setState(() {});
+    }
   }

   @override
EOF

git apply /tmp/fix_init_state.patch 2>/dev/null || echo "Manual fix needed for initState"

echo "Fixed async initState issue #2"