class LevelRecord {
  const LevelRecord({required this.bestScore, required this.bestTimeSeconds});
  final int bestScore;
  final int bestTimeSeconds;
  bool isBetterThan(LevelRecord? previous) {
    if (previous == null) return true;
    if (bestScore > previous.bestScore) return true;
    if (bestScore < previous.bestScore) return false;
    return bestTimeSeconds < previous.bestTimeSeconds;
  }
}
