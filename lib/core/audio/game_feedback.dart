import 'package:flutter/services.dart';

import '../storage/settings_repository.dart';

/// Lightweight feedback: system sounds + haptics.
/// Respects [SettingsRepository] sound preference.
class GameFeedback {
  GameFeedback(this._settings);

  final SettingsRepository _settings;
  bool _soundEnabled = true;
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _soundEnabled = await _settings.getSoundEnabled();
    _loaded = true;
  }

  Future<void> refreshFromSettings() async {
    _soundEnabled = await _settings.getSoundEnabled();
    _loaded = true;
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _loaded = true;
  }

  Future<void> validSelection() async {
    await ensureLoaded();
    await HapticFeedback.lightImpact();
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> invalidSelection() async {
    await ensureLoaded();
    await HapticFeedback.mediumImpact();
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> hintUsed() async {
    await ensureLoaded();
    await HapticFeedback.selectionClick();
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> levelComplete() async {
    await ensureLoaded();
    await HapticFeedback.heavyImpact();
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await SystemSound.play(SystemSoundType.click);
    }
  }
}
