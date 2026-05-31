final class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.title,
    required this.inputJson,
    required this.outputScript,
    required this.timestamp,
    this.tag = 'Local',
  });

  factory HistoryEntry.create({
    required String title,
    required String inputJson,
    required String outputScript,
  }) {
    return HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      inputJson: inputJson,
      outputScript: outputScript,
      timestamp: DateTime.now(),
    );
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    inputJson: json['inputJson'] as String,
    outputScript: json['outputScript'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    tag: json['tag'] as String? ?? 'Local',
  );

  final String id;
  final String title;
  final String inputJson;
  final String outputScript;
  final DateTime timestamp;
  final String tag;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'inputJson': inputJson,
    'outputScript': outputScript,
    'timestamp': timestamp.toIso8601String(),
    'tag': tag,
  };
}

enum SnippetCategory {
  all('All Templates'),
  headers('Headers'),
  bodyInjection('Body Injection'),
  latency('Latency'),
  authentication('Authentication');

  const SnippetCategory(this.label);
  final String label;
}

final class Snippet {
  const Snippet({
    required this.title,
    required this.description,
    required this.category,
    required this.code,
    required this.icon,
    required this.createdAgo,
  });

  final String title;
  final String description;
  final SnippetCategory category;
  final String code;
  final String icon;
  final String createdAgo;
}

const snippets = [
  Snippet(
    title: 'Status Code Modifier',
    description: 'Override the HTTP status code for an intercepted response.',
    category: SnippetCategory.headers,
    code: '''async function onResponse(context, url, request, response) {
  response.statusCode = 200;
  return response;
}''',
    icon: 'JS',
    createdAgo: '2 days ago',
  ),
  Snippet(
    title: 'Field Injection',
    description: 'Deep-merge fields into JSON responses for feature mocks.',
    category: SnippetCategory.bodyInjection,
    code: '''async function onResponse(context, url, request, response) {
  var body = JSON.parse(response.body);
  body.feature_flags = { new_ui: true, beta: true };
  response.body = JSON.stringify(body);
  return response;
}''',
    icon: '{}',
    createdAgo: '1 week ago',
  ),
  Snippet(
    title: 'Delay Response',
    description: 'Simulate endpoint latency to test app resilience.',
    category: SnippetCategory.latency,
    code: '''async function onResponse(context, url, request, response) {
  await new Promise(resolve => setTimeout(resolve, 2000));
  return response;
}''',
    icon: '⏱',
    createdAgo: '3 weeks ago',
  ),
  Snippet(
    title: 'OAuth2 Token Injector',
    description: 'Attach a bearer token to outbound requests.',
    category: SnippetCategory.authentication,
    code: '''async function onRequest(context, url, request) {
  const token = "your_bearer_token_here";
  request.headers["Authorization"] = `Bearer \${token}`;
  return request;
}''',
    icon: '🔑',
    createdAgo: '1 month ago',
  ),
  Snippet(
    title: 'Header Sanitizer',
    description: 'Remove diagnostic headers before requests reach production.',
    category: SnippetCategory.headers,
    code: '''async function onRequest(context, url, request) {
  delete request.headers["X-Debug-Token"];
  delete request.headers["X-Internal-Trace"];
  return request;
}''',
    icon: 'H',
    createdAgo: '1 month ago',
  ),
];

final class AppSettings {
  AppSettings({
    this.defaultScriptHeaders = true,
    this.autoVersioning = false,
    this.defaultProxyPort = '9090',
    this.editorFontSize = 13,
    this.selectedTheme = 'Obsidian',
    this.selectedFont = 'JetBrains Mono',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    defaultScriptHeaders: json['defaultScriptHeaders'] as bool? ?? true,
    autoVersioning: json['autoVersioning'] as bool? ?? false,
    defaultProxyPort: json['defaultProxyPort'] as String? ?? '9090',
    editorFontSize: (json['editorFontSize'] as num?)?.toDouble() ?? 13,
    selectedTheme: json['selectedTheme'] as String? ?? 'Obsidian',
    selectedFont: json['selectedFont'] as String? ?? 'JetBrains Mono',
  );

  bool defaultScriptHeaders;
  bool autoVersioning;
  String defaultProxyPort;
  double editorFontSize;
  String selectedTheme;
  String selectedFont;

  Map<String, dynamic> toJson() => {
    'defaultScriptHeaders': defaultScriptHeaders,
    'autoVersioning': autoVersioning,
    'defaultProxyPort': defaultProxyPort,
    'editorFontSize': editorFontSize,
    'selectedTheme': selectedTheme,
    'selectedFont': selectedFont,
  };
}
