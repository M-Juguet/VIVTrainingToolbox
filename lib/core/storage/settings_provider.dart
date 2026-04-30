import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'app_settings.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<AppSettings> {
  static const _settingsKey = 'viv_formation_settings';

  @override
  AppSettings build() {
    _loadSettings();
    return AppSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      AppSettings current = AppSettings();
      if (settingsJson != null) {
        current = AppSettings.fromJson(settingsJson);
      }
      
      state = current;

      if (state.isFullScreen) {
        await windowManager.setFullScreen(true);
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, state.toJson());
    
    await windowManager.setFullScreen(state.isFullScreen);
  }

  Future<void> setFullScreen(bool value) async {
    state = state.copyWith(isFullScreen: value);
    await updateSettings(state);
  }
}
