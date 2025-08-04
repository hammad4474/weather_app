import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeType { system, light, dark }

class ThemeNotifier extends Notifier<ThemeType> {
  @override
  ThemeType build() => ThemeType.system;

  void setTheme(ThemeType themeType) {
    state = themeType;
  }

  void toggleTheme() {
    switch (state) {
      case ThemeType.system:
        state = ThemeType.light;
        break;
      case ThemeType.light:
        state = ThemeType.dark;
        break;
      case ThemeType.dark:
        state = ThemeType.system;
        break;
    }
  }

  ThemeMode getThemeMode(BuildContext context) {
    switch (state) {
      case ThemeType.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
    }
  }

  String getThemeName() {
    switch (state) {
      case ThemeType.system:
        return 'System';
      case ThemeType.light:
        return 'Light';
      case ThemeType.dark:
        return 'Dark';
    }
  }

  IconData getThemeIcon() {
    switch (state) {
      case ThemeType.system:
        return Icons.brightness_auto;
      case ThemeType.light:
        return Icons.light_mode;
      case ThemeType.dark:
        return Icons.dark_mode;
    }
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeType>(
  () => ThemeNotifier(),
);
