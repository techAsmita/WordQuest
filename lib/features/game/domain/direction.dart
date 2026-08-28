enum Direction {
  horizontal(0, 1),
  horizontalReverse(0, -1),
  vertical(1, 0),
  verticalReverse(-1, 0),
  diagonalDownRight(1, 1),
  diagonalDownLeft(1, -1),
  diagonalUpRight(-1, 1),
  diagonalUpLeft(-1, -1);
  const Direction(this.dRow, this.dCol);
  final int dRow;
  final int dCol;
  bool get isReversed =>
      this == Direction.horizontalReverse ||
      this == Direction.verticalReverse ||
      this == Direction.diagonalUpLeft ||
      this == Direction.diagonalUpRight;
  static const List<Direction> forward = [
    Direction.horizontal, Direction.vertical,
    Direction.diagonalDownRight, Direction.diagonalDownLeft,
  ];
  static const List<Direction> all = Direction.values;
}
