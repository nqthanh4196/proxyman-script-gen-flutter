import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'models.dart';
import 'script_engine.dart';

const surface = Color(0xFF10131B);
const surfaceLow = Color(0xFF181C23);
const surfaceContainer = Color(0xFF1C2028);
const surfaceHigh = Color(0xFF31353D);
const editorBackground = Color(0xFF161616);
const onSurface = Color(0xFFE0E2ED);
const onSurfaceVariant = Color(0xFFC1C6D7);
const outline = Color(0xFF414755);
const primaryBlue = Color(0xFFADC6FF);
const primaryContainer = Color(0xFF4B8EFF);
const tertiary = Color(0xFFFFB595);

enum AppTab { editor, history, snippets, settings, feedback }

final class ProxymanScriptGenApp extends StatefulWidget {
  const ProxymanScriptGenApp({super.key});

  @override
  State<ProxymanScriptGenApp> createState() => _ProxymanScriptGenAppState();
}

final class _ProxymanScriptGenAppState extends State<ProxymanScriptGenApp> {
  final state = AppState();

  @override
  void initState() {
    super.initState();
    state.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proxyman Script Generator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: surface,
        colorScheme: const ColorScheme.dark(primary: primaryBlue),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
      ),
      home: AppShell(state: state),
    );
  }
}

final class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});
  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

final class _AppShellState extends State<AppShell> {
  AppTab selectedTab = AppTab.editor;
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  String statusMessage = 'Ready for processing';

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: Row(
              children: [
                _Sidebar(selected: selectedTab, onSelected: _selectTab),
                Expanded(child: _currentView()),
              ],
            ),
          ),
          _StatusBar(message: statusMessage),
        ],
      ),
    );
  }

  Widget _currentView() => switch (selectedTab) {
    AppTab.editor => EditorView(
      inputController: inputController,
      outputController: outputController,
      status: statusMessage,
      onGenerate: _generate,
      onBeautify: _beautify,
      onClear: _clear,
      onCopy: _copy,
    ),
    AppTab.history => HistoryView(state: widget.state, onRestore: _restore),
    AppTab.snippets => SnippetsView(onUse: _useSnippet),
    AppTab.settings => SettingsView(state: widget.state),
    AppTab.feedback => const FeedbackView(),
  };

  void _selectTab(AppTab value) => setState(() => selectedTab = value);

  void _generate() {
    final result = ScriptEngine.processJson(inputController.text);
    if (!result.isSuccess) {
      setState(
        () => statusMessage = result.error == ScriptError.emptyInput
            ? 'Please paste JSON first'
            : 'Invalid JSON',
      );
      return;
    }
    outputController.text = result.script!;
    widget.state.addHistory(
      HistoryEntry.create(
        title: ScriptEngine.extractTitle(inputController.text),
        inputJson: inputController.text.trim(),
        outputScript: result.script!,
      ),
    );
    setState(() => statusMessage = 'Script generated');
  }

  void _beautify() {
    final pretty = ScriptEngine.beautify(inputController.text);
    if (pretty == null) return;
    inputController.text = pretty;
    setState(() => statusMessage = 'JSON beautified');
  }

  void _clear() {
    inputController.clear();
    outputController.clear();
    setState(() => statusMessage = 'Ready for processing');
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: outputController.text));
    setState(() => statusMessage = 'Copied to clipboard');
  }

  void _restore(HistoryEntry entry) {
    inputController.text = entry.inputJson;
    outputController.text = entry.outputScript;
    setState(() {
      selectedTab = AppTab.editor;
      statusMessage = 'History entry restored';
    });
  }

  void _useSnippet(Snippet snippet) {
    outputController.text = snippet.code;
    setState(() {
      selectedTab = AppTab.editor;
      statusMessage = 'Snippet loaded';
    });
  }
}

final class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(
      color: surface,
      border: Border(bottom: BorderSide(color: outline, width: 0.5)),
    ),
    child: const Row(
      children: [
        Text(
          'Proxyman Script Generator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        _Badge(text: 'FLUTTER V1.0.0'),
      ],
    ),
  );
}

final class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelected});
  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    width: 205,
    decoration: const BoxDecoration(
      color: surfaceLow,
      border: Border(right: BorderSide(color: outline, width: 0.5)),
    ),
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryContainer,
                child: Text('{}'),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proxyman',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Script Engine',
                    style: TextStyle(color: onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final tab in AppTab.values.take(4)) _item(tab),
        const Spacer(),
        _item(AppTab.feedback),
        const SizedBox(height: 8),
      ],
    ),
  );

  Widget _item(AppTab tab) {
    final active = selected == tab;
    final label = tab.name[0].toUpperCase() + tab.name.substring(1);
    final icon = switch (tab) {
      AppTab.editor => Icons.code,
      AppTab.history => Icons.history,
      AppTab.snippets => Icons.terminal,
      AppTab.settings => Icons.settings,
      AppTab.feedback => Icons.feedback_outlined,
    };
    return Material(
      color: active ? primaryBlue.withValues(alpha: 0.12) : Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(tab),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? primaryBlue : onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: active ? primaryBlue : onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class EditorView extends StatelessWidget {
  const EditorView({
    super.key,
    required this.inputController,
    required this.outputController,
    required this.status,
    required this.onGenerate,
    required this.onBeautify,
    required this.onClear,
    required this.onCopy,
  });

  final TextEditingController inputController;
  final TextEditingController outputController;
  final String status;
  final VoidCallback onGenerate;
  final VoidCallback onBeautify;
  final VoidCallback onClear;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: _EditorPanel(
          title: 'INPUT: PASTE JSON RESPONSE HERE',
          controller: inputController,
          actions: [
            TextButton(onPressed: onBeautify, child: const Text('BEAUTIFY')),
            TextButton(onPressed: onClear, child: const Text('CLEAR')),
          ],
          floatingAction: FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.bolt, size: 16),
            label: const Text('Generate Script'),
          ),
        ),
      ),
      Expanded(
        child: _EditorPanel(
          title: 'OUTPUT: PROXYMAN JAVASCRIPT',
          controller: outputController,
          readOnly: true,
          hintText: 'Generated script will appear here...',
          floatingAction: FilledButton.icon(
            onPressed: outputController.text.isEmpty ? null : onCopy,
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('Copy Script'),
          ),
        ),
      ),
    ],
  );
}

final class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.title,
    required this.controller,
    this.actions = const [],
    this.floatingAction,
    this.readOnly = false,
    this.hintText,
  });

  final String title;
  final TextEditingController controller;
  final List<Widget> actions;
  final Widget? floatingAction;
  final bool readOnly;
  final String? hintText;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        color: surfaceContainer,
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ...actions,
          ],
        ),
      ),
      Expanded(
        child: Stack(
          children: [
            TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                color: onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: onSurfaceVariant.withValues(alpha: .4),
                ),
                filled: true,
                fillColor: editorBackground,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            if (floatingAction != null)
              Positioned(right: 16, bottom: 16, child: floatingAction!),
          ],
        ),
      ),
    ],
  );
}

final class HistoryView extends StatefulWidget {
  const HistoryView({super.key, required this.state, required this.onRestore});
  final AppState state;
  final ValueChanged<HistoryEntry> onRestore;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

final class _HistoryViewState extends State<HistoryView> {
  String query = '';

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.state,
    builder: (context, _) {
      final entries = widget.state.history.where((entry) {
        final q = query.toLowerCase();
        return entry.title.toLowerCase().contains(q) ||
            entry.inputJson.toLowerCase().contains(q);
      }).toList();
      return _Page(
        title: 'Execution History',
        subtitle: 'Manage and restore generated Proxyman scripts.',
        action: TextButton.icon(
          onPressed: widget.state.history.isEmpty
              ? null
              : widget.state.clearHistory,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear All'),
        ),
        children: [
          _SearchField(onChanged: (value) => setState(() => query = value)),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const _EmptyState(message: 'No history yet')
          else
            for (final entry in entries)
              Card(
                color: surfaceContainer,
                child: ListTile(
                  leading: const Icon(Icons.description, color: primaryBlue),
                  title: Text(entry.title),
                  subtitle: Text(
                    entry.inputJson.replaceAll('\n', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: FilledButton(
                    onPressed: () => widget.onRestore(entry),
                    child: const Text('Restore'),
                  ),
                ),
              ),
        ],
      );
    },
  );
}

final class SnippetsView extends StatefulWidget {
  const SnippetsView({super.key, required this.onUse});
  final ValueChanged<Snippet> onUse;

  @override
  State<SnippetsView> createState() => _SnippetsViewState();
}

final class _SnippetsViewState extends State<SnippetsView> {
  String query = '';
  SnippetCategory selected = SnippetCategory.all;

  @override
  Widget build(BuildContext context) {
    final filtered = snippets.where((snippet) {
      final matchesCategory =
          selected == SnippetCategory.all || snippet.category == selected;
      final q = query.toLowerCase();
      return matchesCategory &&
          (snippet.title.toLowerCase().contains(q) ||
              snippet.description.toLowerCase().contains(q));
    }).toList();
    return _Page(
      title: 'Snippet Library',
      subtitle: 'Accelerate your workflow with curated script templates.',
      children: [
        _SearchField(onChanged: (value) => setState(() => query = value)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final category in SnippetCategory.values)
              ChoiceChip(
                label: Text(category.label),
                selected: selected == category,
                onSelected: (_) => setState(() => selected = category),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final snippet in filtered)
              SizedBox(
                width: 330,
                child: Card(
                  color: surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Badge(text: snippet.icon),
                        const SizedBox(height: 12),
                        Text(
                          snippet.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          snippet.description,
                          style: const TextStyle(color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () => widget.onUse(snippet),
                            child: const Text('Use'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

final class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) => _Page(
      title: 'Settings',
      subtitle: 'Configure local scripting preferences.',
      children: [
        _SettingSwitch(
          title: 'Default Script Headers',
          subtitle: 'Include common boilerplate in new scripts.',
          value: state.settings.defaultScriptHeaders,
          onChanged: (value) => state.updateSettings(
            (settings) => settings.defaultScriptHeaders = value,
          ),
        ),
        _SettingSwitch(
          title: 'Auto-Versioning',
          subtitle: 'Create local backups when scripts are generated.',
          value: state.settings.autoVersioning,
          onChanged: (value) => state.updateSettings(
            (settings) => settings.autoVersioning = value,
          ),
        ),
        Card(
          color: surfaceContainer,
          child: ListTile(
            title: const Text('Default Proxy Port'),
            subtitle: const Text('Local scripting engine port.'),
            trailing: SizedBox(
              width: 90,
              child: TextFormField(
                initialValue: state.settings.defaultProxyPort,
                onChanged: (value) => state.updateSettings(
                  (settings) => settings.defaultProxyPort = value,
                ),
              ),
            ),
          ),
        ),
        Card(
          color: surfaceContainer,
          child: ListTile(
            title: const Text('Editor Font Size'),
            trailing: SizedBox(
              width: 280,
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: state.settings.editorFontSize,
                      min: 10,
                      max: 24,
                      divisions: 14,
                      onChanged: (value) => state.updateSettings(
                        (settings) => settings.editorFontSize = value,
                      ),
                    ),
                  ),
                  Text('${state.settings.editorFontSize.round()}pt'),
                ],
              ),
            ),
          ),
        ),
        const Card(
          color: surfaceContainer,
          child: ListTile(
            leading: Icon(Icons.info_outline, color: primaryBlue),
            title: Text('Proxyman Scripting Utility'),
            subtitle: Text('Flutter desktop edition 1.0.0'),
          ),
        ),
      ],
    ),
  );
}

final class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    color: surfaceContainer,
    child: SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    ),
  );
}

final class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

final class _FeedbackViewState extends State<FeedbackView> {
  final subject = TextEditingController();
  final description = TextEditingController();
  bool submitted = false;

  @override
  Widget build(BuildContext context) => _Page(
    title: 'Feedback',
    subtitle: 'Share product feedback, bugs, or feature suggestions.',
    children: [
      TextField(
        controller: subject,
        decoration: const InputDecoration(labelText: 'Subject'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: description,
        minLines: 8,
        maxLines: 12,
        decoration: const InputDecoration(labelText: 'Description'),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () => setState(() => submitted = true),
        icon: const Icon(Icons.send),
        label: const Text('Submit Feedback'),
      ),
      if (submitted)
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Feedback submitted successfully.',
            style: TextStyle(color: primaryBlue),
          ),
        ),
    ],
  );
}

final class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.subtitle,
    required this.children,
    this.action,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: surface,
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: onSurfaceVariant)),
              ],
            ),
            const Spacer(),
            ?action,
          ],
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    ),
  );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.search),
      hintText: 'Search...',
      filled: true,
      fillColor: surfaceLow,
      border: OutlineInputBorder(),
    ),
  );
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(80),
    child: Center(
      child: Text(
        message,
        style: const TextStyle(color: onSurfaceVariant, fontSize: 16),
      ),
    ),
  );
}

final class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: surfaceHigh,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      text,
      style: const TextStyle(color: onSurfaceVariant, fontSize: 10),
    ),
  );
}

final class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    color: Color(0xFF0B0E16),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: onSurfaceVariant,
          size: 13,
        ),
        const SizedBox(width: 6),
        Text(
          message,
          style: const TextStyle(color: onSurfaceVariant, fontSize: 11),
        ),
        const Spacer(),
        const Text(
          'UTF-8   JavaScript',
          style: TextStyle(color: onSurfaceVariant, fontSize: 11),
        ),
      ],
    ),
  );
}
