import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:proxyman_script_gen_flutter/src/models.dart';
import 'package:proxyman_script_gen_flutter/src/storage.dart';

void main() {
  test('persists history and settings', () async {
    final directory = await Directory.systemTemp.createTemp('proxyman_test_');
    addTearDown(() => directory.delete(recursive: true));
    final storage = LocalStorage(directory: directory);
    final entry = HistoryEntry.create(
      title: '/products',
      inputJson: '{"ok":true}',
      outputScript: 'script',
    );

    await storage.saveHistory([entry]);
    await storage.saveSettings(AppSettings(defaultProxyPort: '8080'));

    expect((await storage.loadHistory()).single.title, '/products');
    expect((await storage.loadSettings()).defaultProxyPort, '8080');
  });
}
