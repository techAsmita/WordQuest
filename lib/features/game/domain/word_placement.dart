import 'direction.dart';
import 'position.dart';

class WordPlacement {
  const WordPlacement({required this.word, required this.start, required this.direction});
  final String word;
  final Position start;
  final Direction direction;
  List<Position> get cells {
    final result = <Position>[];
    for (var i = 0; i < word.length; i++) {
      result.add(start.offset(direction.dRow * i, direction.dCol * i));
    }
    return result;
  }
  @override
  String toString() => 'WordPlacement($word @ $start → ${direction.name})';
}
