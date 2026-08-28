import 'package:shared_preferences/shared_preferences.dart';

import 'level_record.dart';
import 'progress_repository.dart';

class PrefsProgressRepository implements ProgressRepository {
  PrefsProgressRepository({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;
  static const _prefix = 'level_record_';

  Future<SharedPreferences> _prefs() async {
    return _prefsOverride ?? await SharedPreferences.getInstance();
  }

  String _key(int level) => '$_prefix$level';

  @override
  Future<LevelRecord?> recordForLevel(int levelNumber) async {
    final p = await _prefs();
    final raw = p.getString(_key(levelNumber));
    if (raw == null) return null;
    final parts = raw.split(':');
    return LevelRecord(
      bestScore: int.parse(parts[0]),
      bestTimeSeconds: int.parse(parts[1]),
    );
  }

  @override
  Future<Map<int, LevelRecord>> allRecords() async {
    final p = await _prefs();
    final result = <int, LevelRecord>{};
    for (final key in p.getKeys()) {
      if (!key.startsWith(_prefix)) continue;
      final n = int.tryParse(key.substring(_prefix.length));
      if (n == null) continue;
      final raw = p.getString(key);
      if (raw == null) continue;
      final parts = raw.split(':');
      result[n] = LevelRecord(
        bestScore: int.parse(parts[0]),
        bestTimeSeconds: int.parse(parts[1]),
      );
    }
    return result;
  }

  @override
  Future<LevelRecord> saveIfBetter({
    required int levelNumber,
    required int score,
    required int timeSeconds,
  }) async {
    final existing = await recordForLevel(levelNumber);
    final merged = ProgressLogic.merge(
      existing: existing,
      score: score,
      timeSeconds: timeSeconds,
    );
    final p = await _prefs();
    await p.setString(
      _key(levelNumber),
      '${merged.bestScore}:${merged.bestTimeSeconds}',
    );
    return merged;
  }

  @override
  Future<void> resetAll() async {
    final p = await _prefs();
    for (final k in p.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await p.remove(k);
    }
  }
}
