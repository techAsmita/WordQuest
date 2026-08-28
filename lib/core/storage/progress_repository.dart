import 'level_record.dart';

abstract class ProgressRepository {
  Future<LevelRecord?> recordForLevel(int levelNumber);
  Future<Map<int, LevelRecord>> allRecords();
  Future<LevelRecord> saveIfBetter({
    required int levelNumber,
    required int score,
    required int timeSeconds,
  });
  Future<void> resetAll();
}

class ProgressLogic {
  ProgressLogic._();
  static LevelRecord merge({
    required LevelRecord? existing,
    required int score,
    required int timeSeconds,
  }) {
    final candidate =
        LevelRecord(bestScore: score, bestTimeSeconds: timeSeconds);
    if (candidate.isBetterThan(existing)) return candidate;
    return existing!;
  }
}
