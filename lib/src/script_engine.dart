import 'dart:convert';

enum ScriptError { emptyInput, invalidJson }

final class ScriptResult {
  const ScriptResult.success(this.script) : error = null;
  const ScriptResult.failure(this.error) : script = null;

  final String? script;
  final ScriptError? error;

  bool get isSuccess => script != null;
}

final class ScriptEngine {
  static ScriptResult processJson(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const ScriptResult.failure(ScriptError.emptyInput);
    }
    try {
      jsonDecode(trimmed);
      return ScriptResult.success(generateScript(trimmed));
    } on FormatException {
      return const ScriptResult.failure(ScriptError.invalidJson);
    }
  }

  static String generateScript(String rawJson) {
    final lines = rawJson.split('\n');
    final indented = [
      lines.first,
      ...lines.skip(1).map((line) => '    $line'),
    ].join('\n');

    return '''
console.log("🔥 SCRIPT LOADED");

sharedState.savedResponse = null;

async function onRequest(context, url, request) {
  console.log("➡️ onRequest:", url);

  if (sharedState.savedResponse?.data) {
    request.headers["X-Debug"] = "From-Proxyman";
  }

  return request;
}

async function onResponse(context, url, request, response) {
  console.log("⬅️ onResponse:", url);
  console.log("Status:", response.statusCode);

  const MOCK_RESPONSE = $indented;

  // ✅ FORCE override response
  response.headers["Content-Type"] = "application/json";
  response.body = MOCK_RESPONSE;

  sharedState.savedResponse = MOCK_RESPONSE;

  console.log("✅ RESPONSE OVERRIDDEN");

  return response;
}''';
  }

  static String? beautify(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(trimmed));
    } on FormatException {
      return null;
    }
  }

  static String extractTitle(String input) {
    try {
      final decoded = jsonDecode(input);
      if (decoded is! Map<String, dynamic>) return 'Generated Script';
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final attributes = data['attributes'];
        if (attributes is Map<String, dynamic>) {
          final endpoint = attributes['endpoint'];
          if (endpoint is String) return endpoint;
        }
      }
      final type = decoded['type'];
      return type is String ? type : 'Generated Script';
    } on FormatException {
      return 'Generated Script';
    }
  }
}
