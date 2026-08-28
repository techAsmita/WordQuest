import 'package:flutter_test/flutter_test.dart';
import 'package:wordquest/core/storage/settings_repository.dart';

void main() {
  test('sound preference toggles in memory', () async {
    final repo = _MemSettings();
    expect(await repo.getSoundEnabled(), isTrue);
    await repo.setSoundEnabled(false);
    expect(await repo.getSoundEnabled(), isFalse);
  });
}

class _MemSettings implements SettingsRepository {
  bool _sound = true;
  @override
  Future<bool> getSoundEnabled() async => _sound;
  @override
  Future<void> setSoundEnabled(bool enabled) async => _sound = enabled;
}
