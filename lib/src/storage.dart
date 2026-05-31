import 'dart:convert';
import 'dart:io';

import 'models.dart';

final class LocalStorage {
  LocalStorage({Directory? directory}) : _directory = directory;

  final Directory? _directory;

  Future<List<HistoryEntry>> loadHistory() async {
    final file = await _file('history.json');
    if (!await file.exists()) return [];
    final values = jsonDecode(await file.readAsString()) as List<dynamic>;
    return values
        .map((value) => HistoryEntry.fromJson(value as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<HistoryEntry> entries) async {
    final file = await _file('history.json');
    await file.writeAsString(
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final file = await _file('settings.json');
    if (!await file.exists()) return AppSettings();
    return AppSettings.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final file = await _file('settings.json');
    await file.writeAsString(jsonEncode(settings.toJson()));
  }

  Future<File> _file(String name) async {
    final directory = _directory ?? Directory(_defaultDataPath());
    if (!await directory.exists()) await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$name');
  }

  String _defaultDataPath() {
    if (Platform.isWindows) {
      final root =
          Platform.environment['APPDATA'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      return '$root${Platform.pathSeparator}ProxymanScriptGen';
    }
    final home = Platform.environment['HOME'] ?? '.';
    return '$home${Platform.pathSeparator}Library${Platform.pathSeparator}'
        'Application Support${Platform.pathSeparator}ProxymanScriptGenFlutter';
  }
}
