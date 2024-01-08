import 'package:hive_flutter/adapters.dart';
import 'package:sudoku/logic/sudoku.dart';
import 'package:sudoku/tools/app_settings.dart';

part 'stats.g.dart';

class Stats {
  Box saveBox;
  var stats = List<StatPiece>.empty(growable: true);

  /// Sum of every puzzle's rating user solved
  int get rating {
    int sum = 0;
    for (var stat in stats) {
      sum += stat.difficulty;
    }
    return sum;
  }

  /// Milliseconds spend solving puzzles
  Duration get timeSolving {
    int sum = 0;
    for (var stat in stats) {
      sum += stat.timeToSolve;
    }
    return Duration(milliseconds: sum);
  }

  int get averagePuzzleRating => rating ~/ _divisionSafeSolvedCount;
  Duration get averageTimeSolving => Duration(
      milliseconds: timeSolving.inMilliseconds ~/ _divisionSafeSolvedCount);

  int get solvedCount => stats.length;
  int get _divisionSafeSolvedCount => solvedCount == 0 ? 1 : solvedCount;

  Stats() : saveBox = Hive.box(AppGlobals.statisticBoxName) {
    for (int i = 0; i < saveBox.length; i++) {
			stats.add(saveBox.getAt(i));
		}
  }

  void addPuzzle(SudokuField f) {
    stats.add(StatPiece.fromDifficultyAndTime(f.difficulty, f.time));

    saveBox.add(stats.last);
  }
}

@HiveType(typeId: 1)
class StatPiece {
  @HiveField(0)
  final int timeFinished;
  @HiveField(1)
  final int timeToSolve;
  @HiveField(2)
  final int difficulty;

  StatPiece(
      {required this.timeFinished,
      required this.timeToSolve,
      required this.difficulty});

  StatPiece.fromDifficultyAndTime(this.difficulty, this.timeToSolve)
      : timeFinished = DateTime.now().millisecondsSinceEpoch;
}
