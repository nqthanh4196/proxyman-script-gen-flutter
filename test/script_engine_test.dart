import 'package:flutter_test/flutter_test.dart';
import 'package:proxyman_script_gen_flutter/src/script_engine.dart';

void main() {
  group('ScriptEngine', () {
    test('rejects empty input', () {
      expect(ScriptEngine.processJson('  ').error, ScriptError.emptyInput);
    });

    test('rejects invalid JSON', () {
      expect(ScriptEngine.processJson('{').error, ScriptError.invalidJson);
    });

    test('generates Proxyman handlers', () {
      final result = ScriptEngine.processJson('{"ok":true}');
      expect(result.script, contains('async function onRequest'));
      expect(result.script, contains('async function onResponse'));
      expect(result.script, contains('const MOCK_RESPONSE = {"ok":true};'));
    });

    test('beautifies JSON', () {
      expect(ScriptEngine.beautify('{"b":2,"a":1}'), contains('\n'));
    });

    test('extracts endpoint title', () {
      expect(
        ScriptEngine.extractTitle(
          '{"data":{"attributes":{"endpoint":"/products"}}}',
        ),
        '/products',
      );
    });
  });
}
