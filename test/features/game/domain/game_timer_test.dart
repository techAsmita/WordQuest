import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordquest/features/game/domain/domain.dart';

Puzzle _tinyPuzzle() {
  final grid = [
    ['C', 'A', 'T'],
    ['X', 'Y', 'Z'],
    ['D', 'O', 'G'],
  ];
  final placements = [
    const WordPlacement(
      word: 'CAT', start: Position(0, 0), direction: Direction.horizontal),
    const WordPlacement(
      word: 'DOG', start: Position(2, 0), direction: Direction.horizontal),
  ];
  return Puzzle(
    grid: grid,
    placements: placements,
    words: placements.map((p) => p.word).toList(),
  );
}

void main() {
  group('Game timer', () {
    test('starts at zero', () {
      var now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final c = GameController(_tinyPuzzle(), clock: () => now);
      expect(c.elapsedSeconds, 0);
      expect(c.state.isTimerRunning, isTrue);
    });

    test('elapsed advances with clock', () {
      var now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final c = GameController(_tinyPuzzle(), clock: () => now);
      now = now.add(const Duration(seconds: 5));
      expect(c.elapsedSeconds, 5);
      now = now.add(const Duration(seconds: 10));
      expect(c.elapsedSeconds, 15);
    });

    test('timer freezes on completion', () {
      var now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final c = GameController(_tinyPuzzle(), clock: () => now);
      now = now.add(const Duration(seconds: 8));
      c.select(const Position(0, 0), const Position(0, 2));
      c.select(const Position(2, 0), const Position(2, 2));
      expect(c.state.isComplete, isTrue);
      expect(c.elapsedSeconds, 8);
      now = now.add(const Duration(seconds: 30));
      expect(c.elapsedSeconds, 8);
    });

    test('reset restarts timer', () {
      var now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final c = GameController(_tinyPuzzle(), clock: () => now);
      now = now.add(const Duration(seconds: 20));
      c.reset(_tinyPuzzle());
      expect(c.elapsedSeconds, 0);
      expect(c.state.score, 0);
      now = now.add(const Duration(seconds: 3));
      expect(c.elapsedSeconds, 3);
    });
  });

  group('Randomized puzzles', () {
    test('unseeded generations can differ', () {
      final grids = <String>{};
      for (var i = 0; i < 10; i++) {
        final p = PuzzleGenerator(random: Random()).generate(
          kDemoWords, config: const PuzzleConfig(size: 8));
        grids.add(p.grid.map((r) => r.join()).join('|'));
      }
      expect(grids.length, greaterThan(1));
    });

    test('seeded config is deterministic', () {
      final p1 = PuzzleGenerator(random: Random(99)).generate(
        ['CAT', 'DOG'], config: const PuzzleConfig(size: 8, seed: 99));
      final p2 = PuzzleGenerator(random: Random(99)).generate(
        ['CAT', 'DOG'], config: const PuzzleConfig(size: 8, seed: 99));
      expect(p1.grid, p2.grid);
    });
  });
}
