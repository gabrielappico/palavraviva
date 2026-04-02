import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppFontSize { small, medium, large }

class SettingsState {
  final bool devotionalNotifications;
  final AppFontSize fontSize;

  const SettingsState({
    this.devotionalNotifications = false,
    this.fontSize = AppFontSize.medium,
  });

  SettingsState copyWith({
    bool? devotionalNotifications,
    AppFontSize? fontSize,
  }) {
    return SettingsState(
      devotionalNotifications: devotionalNotifications ?? this.devotionalNotifications,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _boxName = 'settingsBox';
  static const _notifKey = 'devotionalNotifications';
  static const _fontKey = 'fontSize';

  @override
  SettingsState build() {
    final box = Hive.box(_boxName);
    final notifs = box.get(_notifKey, defaultValue: false);
    final fontString = box.get(_fontKey, defaultValue: AppFontSize.medium.name);
    
    AppFontSize font = AppFontSize.medium;
    try {
      font = AppFontSize.values.byName(fontString);
    } catch (_) {}

    return SettingsState(
      devotionalNotifications: notifs,
      fontSize: font,
    );
  }

  void toggleDevotionalNotifications(bool value) {
    state = state.copyWith(devotionalNotifications: value);
    Hive.box(_boxName).put(_notifKey, value);
  }

  void setFontSize(AppFontSize fontSize) {
    state = state.copyWith(fontSize: fontSize);
    Hive.box(_boxName).put(_fontKey, fontSize.name);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
