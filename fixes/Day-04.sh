#!/bin/bash
# Day 04 - Fix Broken Widget Test
# Issue #4: Test references MyApp which doesn't exist
# Fix: Rewrite test for ProxymanScriptGenApp

cat > test/widget_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:proxyman_script_gen_flutter/src/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProxymanScriptGenApp());
    expect(find.text('Proxyman Script Gen'), findsAny);
  });
}
EOF

echo "Fixed broken widget test issue #4"