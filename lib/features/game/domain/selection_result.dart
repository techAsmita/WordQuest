import 'position.dart';

enum SelectionStatus {
  found, alreadyFound, notAWord, notStraight, outOfBounds, tooShort,
}

class SelectionResult {
  const SelectionResult({
    required this.status, required this.cells, this.word, this.pointsAwarded = 0,
  });
  final SelectionStatus status;
  final List<Position> cells;
  final String? word;
  final int pointsAwarded;
  bool get isSuccess => status == SelectionStatus.found;
  @override
  String toString() => 'SelectionResult($status, word: $word, points: $pointsAwarded)';
}
