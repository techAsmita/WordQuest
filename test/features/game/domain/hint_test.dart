import 'package:flutter_test/flutter_test.dart';
import 'package:wordquest/features/game/domain/domain.dart';

Puzzle _puzzle() {
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
  return Puzzle(grid: grid, placements: placements, words: ['CAT', 'DOG']);
}

void main() {
  test('starts with 3 hints', () {
    final c = GameController(_puzzle());
    expect(c.hintsRemaining, HintConfig.hintsPerLevel);
    expect(c.canUseHint, isTrue);
  });

  test('reveals unfound cells without marking found', () {
    final c = GameController(_puzzle());
    final r = c.useHint();
    expect(r.status, HintStatus.revealed);
    expect(r.cells, isNotEmpty);
    expect(c.state.foundWords.contains(r.word), isFalse);
    expect(c.hintsRemaining, 2);
  });

  test('deducts points floored at 0', () {
    final c = GameController(_puzzle());
    c.useHint();
    expect(c.state.score, 0);
    c.select(const Position(0, 0), const Position(0, 2));
    expect(c.state.score, 30);
    final r = c.useHint();
    expect(r.pointsDeducted, HintConfig.pointsCost);
    expect(c.state.score, 30 - HintConfig.pointsCost);
  });

  test('only unfound words', () {
    final c = GameController(_puzzle());
    c.select(const Position(0, 0), const Position(0, 2));
    expect(c.useHint().word, 'DOG');
  });

  test('no hints left', () {
    final c = GameController(_puzzle(), initialHints: 1);
    c.useHint();
    expect(c.useHint().status, HintStatus.noHintsLeft);
    expect(c.canUseHint, isFalse);
  });

  test('disabled when complete', () {
    final c = GameController(_puzzle());
    c.select(const Position(0, 0), const Position(0, 2));
    c.select(const Position(2, 0), const Position(2, 2));
    expect(c.useHint().status, HintStatus.puzzleComplete);
  });

  test('reset refills hints', () {
    final c = GameController(_puzzle());
    c.useHint();
    c.useHint();
    c.reset(_puzzle());
    expect(c.hintsRemaining, HintConfig.hintsPerLevel);
  });
}
