import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<bool> getSoundEnabled();
  Future<void> setSoundEnabled(bool enabled);
}

class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;
  static const _soundKey = 'settings_sound_enabled';

  Future<SharedPreferences> _prefs() async {
    return _prefsOverride ?? await SharedPreferences.getInstance();
  }

  @override
  Future<bool> getSoundEnabled() async {
    final p = await _prefs();
    return p.getBool(_soundKey) ?? true;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    final p = await _prefs();
    await p.setBool(_soundKey, enabled);
  }
}
