import 'package:flutter_test/flutter_test.dart';
import 'package:wordquest/core/storage/level_record.dart';
import 'package:wordquest/core/storage/progress_repository.dart';

void main() {
  test('higher score is better', () {
    const a = LevelRecord(bestScore: 50, bestTimeSeconds: 40);
    const b = LevelRecord(bestScore: 40, bestTimeSeconds: 10);
    expect(a.isBetterThan(b), isTrue);
  });
  test('same score lower time is better', () {
    const a = LevelRecord(bestScore: 50, bestTimeSeconds: 20);
    const b = LevelRecord(bestScore: 50, bestTimeSeconds: 30);
    expect(a.isBetterThan(b), isTrue);
  });
  test('merge and in-memory reset', () async {
    final repo = InMemoryProgressRepository();
    await repo.saveIfBetter(levelNumber: 1, score: 40, timeSeconds: 30);
    await repo.saveIfBetter(levelNumber: 1, score: 30, timeSeconds: 5);
    expect((await repo.recordForLevel(1))!.bestScore, 40);
    await repo.saveIfBetter(levelNumber: 1, score: 50, timeSeconds: 40);
    expect((await repo.recordForLevel(1))!.bestScore, 50);
    await repo.resetAll();
    expect(await repo.recordForLevel(1), isNull);
  });
}

class InMemoryProgressRepository implements ProgressRepository {
  final Map<int, LevelRecord> _data = {};
  @override
  Future<LevelRecord?> recordForLevel(int levelNumber) async => _data[levelNumber];
  @override
  Future<Map<int, LevelRecord>> allRecords() async => Map.of(_data);
  @override
  Future<LevelRecord> saveIfBetter({
    required int levelNumber, required int score, required int timeSeconds,
  }) async {
    final merged = ProgressLogic.merge(
      existing: _data[levelNumber], score: score, timeSeconds: timeSeconds);
    _data[levelNumber] = merged;
    return merged;
  }
  @override
  Future<void> resetAll() async => _data.clear();
}
