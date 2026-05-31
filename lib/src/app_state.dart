import 'package:flutter/foundation.dart';

import 'models.dart';
import 'storage.dart';

final class AppState extends ChangeNotifier {
  AppState({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;
  final List<HistoryEntry> history = [];
  AppSettings settings = AppSettings();

  Future<void> initialize() async {
    history
      ..clear()
      ..addAll(await _storage.loadHistory());
    settings = await _storage.loadSettings();
    notifyListeners();
  }

  Future<void> addHistory(HistoryEntry entry) async {
    history.insert(0, entry);
    notifyListeners();
    await _storage.saveHistory(history);
  }

  Future<void> clearHistory() async {
    history.clear();
    notifyListeners();
    await _storage.saveHistory(history);
  }

  Future<void> updateSettings(void Function(AppSettings) update) async {
    update(settings);
    notifyListeners();
    await _storage.saveSettings(settings);
  }
}
