# Proxyman Script Gen Flutter

Cross-platform Flutter desktop version of Proxyman Script Generator.

## Platforms

- macOS
- Windows

## Features

- Generate Proxyman JavaScript mock scripts from JSON responses.
- Beautify and copy generated scripts.
- Persist and restore generation history.
- Use built-in script snippets.
- Persist desktop settings.

## About

### Why this app?

As an iOS developer working with APIs daily, I often need to mock server responses for testing. Manually writing JavaScript mock scripts for Proxyman was tedious and error-prone. This tool automates the process - just paste your JSON and get a ready-to-use script instantly.

### Key Features

- **Fast & Simple**: Paste JSON → Get script → Copy to Proxyman
- **Cross-Platform**: Works on macOS and Windows
- **Offline**: No internet required, runs locally
- **Private**: Your data stays on your machine
- **Dark Mode**: Easy on the eyes during long coding sessions

### Version

Current: **1.0.0**

### Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Language | Dart |
| State | Riverpod |
| Storage | SharedPreferences |

### Credits

- [Proxyman](https://proxyman.io/) - The amazing network debugging tool for macOS
- [Flutter](https://flutter.dev/) - UI toolkit for cross-platform apps

### Support

Found a bug or have a feature request? Submit feedback through the app or create an issue on GitHub.

## Development

```bash
flutter analyze
flutter test
flutter run -d macos
```

## Release builds

```bash
flutter build macos
flutter build windows
```

The Windows build command must run on Windows with Visual Studio desktop C++
tooling installed.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
