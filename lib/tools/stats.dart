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

  void addStatPiece(StatPiece s, {bool checkIfAlreadyAdded=true}) {
    if (!checkIfAlreadyAdded || !_isStatsAlreadyAdded(s)) {
      stats.add(s);
      saveBox.add(s);
    }
  }

  List<DateTime> getActivityMap(int year) {
    var res = List<DateTime>.empty(growable: true);

    for (var stat in stats) {
      var statDateTime =
          DateTime.fromMillisecondsSinceEpoch(stat.millisecondsFinished);

      if (statDateTime.year == year) {
        res.add(statDateTime);
      }
    }

    return res;
  }

  bool _isStatsAlreadyAdded(StatPiece s) {
    for (var stat in stats) {
      if (stat.clues == s.clues) {
        return true;
      }
    }

    return false;
  }
}

@HiveType(typeId: 1)
class StatPiece {
  /// Milliseconds since epoch
  @HiveField(0)
  final int millisecondsFinished;

  /// Milliseconds
  @HiveField(1)
  final int timeToSolve;

  /// Usually between 700 and 1400
  @HiveField(2)
  final int difficulty;

  /// Only non-user clues
  @HiveField(3)
  final String clues;

  StatPiece({
    required this.millisecondsFinished,
    required this.timeToSolve,
    required this.difficulty,
    required this.clues,
  });

  StatPiece.fromSudoku(SudokuField f)
      : difficulty = f.difficulty,
        timeToSolve = f.time,
        clues = f.cluesToString(),
        millisecondsFinished = DateTime.now().millisecondsSinceEpoch;
}
