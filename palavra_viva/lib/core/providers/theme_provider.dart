import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _boxName = 'settingsBox';
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final box = Hive.box(_boxName);
    final isDark = box.get(_key, defaultValue: true); // Default is Dark Mode
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    final newState = isDark ? ThemeMode.light : ThemeMode.dark;
    state = newState;
    
    final box = Hive.box(_boxName);
    box.put(_key, !isDark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
