import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app-wide theme mode. Defaults to following the system setting.
///
/// Kept in memory for this foundation step; persisting it is a small follow-up
/// once a settings store exists.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
  }
}
