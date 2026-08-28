import 'level_config.dart';

class LevelCatalog {
  LevelCatalog._();

  static const List<LevelConfig> levels = [
    LevelConfig(
      levelNumber: 1,
      name: 'Starter',
      gridSize: 6,
      wordCount: 4,
      minWordLength: 3,
      maxWordLength: 4,
      allowDiagonal: false,
      allowReverse: false,
    ),
    LevelConfig(
      levelNumber: 2,
      name: 'Easy',
      gridSize: 7,
      wordCount: 5,
      minWordLength: 3,
      maxWordLength: 5,
      allowDiagonal: false,
      allowReverse: true,
    ),
    LevelConfig(
      levelNumber: 3,
      name: 'Medium',
      gridSize: 8,
      wordCount: 6,
      minWordLength: 4,
      maxWordLength: 6,
      allowDiagonal: true,
      allowReverse: false,
    ),
    LevelConfig(
      levelNumber: 4,
      name: 'Hard',
      gridSize: 8,
      wordCount: 7,
      minWordLength: 4,
      maxWordLength: 7,
      allowDiagonal: true,
      allowReverse: true,
    ),
    LevelConfig(
      levelNumber: 5,
      name: 'Expert',
      gridSize: 9,
      wordCount: 8,
      minWordLength: 5,
      maxWordLength: 8,
      allowDiagonal: true,
      allowReverse: true,
    ),
  ];

  static int get count => levels.length;

  static LevelConfig byIndex(int index) {
    if (index < 0 || index >= levels.length) {
      throw RangeError.index(index, levels, 'levelIndex');
    }
    return levels[index];
  }

  static LevelConfig byNumber(int levelNumber) {
    return levels.firstWhere(
      (l) => l.levelNumber == levelNumber,
      orElse: () => throw ArgumentError('Unknown level $levelNumber'),
    );
  }

  static bool hasNext(int currentIndex) => currentIndex + 1 < levels.length;

  static LevelConfig? nextAfter(int currentIndex) {
    if (!hasNext(currentIndex)) return null;
    return levels[currentIndex + 1];
  }
}
