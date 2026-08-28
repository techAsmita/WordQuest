import 'dart:math';

import 'level_catalog.dart';
import 'level_config.dart';
import 'puzzle.dart';
import 'puzzle_generator.dart';
import 'word_bank.dart';

class LevelProgress {
  LevelProgress({int startIndex = 0, Random? random})
      : _index = startIndex.clamp(0, LevelCatalog.count - 1),
        _random = random ?? Random();

  int _index;
  final Random _random;

  int get currentIndex => _index;
  LevelConfig get current => LevelCatalog.byIndex(_index);
  bool get hasNext => LevelCatalog.hasNext(_index);
  LevelConfig? get nextLevel => LevelCatalog.nextAfter(_index);
  bool get isOnLastLevel => !hasNext;

  bool advance() {
    if (!hasNext) return false;
    _index++;
    return true;
  }

  void resetToFirst() {
    _index = 0;
  }

  Puzzle generatePuzzle({PuzzleGenerator? generator}) {
    final config = current;
    final pool = WordBank.filter(
      minLength: config.minWordLength,
      maxLength: config.maxWordLength,
    );
    if (pool.isEmpty) {
      throw StateError(
        'No words for level ${config.levelNumber} '
        '(len ${config.minWordLength}-${config.maxWordLength})',
      );
    }

    final shuffled = List<String>.from(pool)..shuffle(_random);
    final words = shuffled.take(config.wordCount).toList();

    final gen = generator ?? PuzzleGenerator(random: _random);
    return gen.generate(
      words,
      config: PuzzleConfig(
        size: config.gridSize,
        allowReverse: config.allowReverse,
        allowDiagonal: config.allowDiagonal,
      ),
    );
  }
}
