/// Difficulty settings for a single level. Pure data — no UI.
class LevelConfig {
  const LevelConfig({
    required this.levelNumber,
    required this.name,
    required this.gridSize,
    required this.wordCount,
    required this.minWordLength,
    required this.maxWordLength,
    required this.allowDiagonal,
    required this.allowReverse,
  });

  final int levelNumber;
  final String name;
  final int gridSize;
  final int wordCount;
  final int minWordLength;
  final int maxWordLength;
  final bool allowDiagonal;
  final bool allowReverse;

  @override
  String toString() =>
      'Level $levelNumber ($name): ${gridSize}x$gridSize, '
      '$wordCount words, len $minWordLength-$maxWordLength, '
      'diag=$allowDiagonal, rev=$allowReverse';
}
