import 'package:hive_flutter/adapters.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/other_logic/app_globals.dart';

part 'statistics.g.dart';

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

  int get longestStreak {
    if (stats.isEmpty) return 0;

    int biggestStreak = 1;
    int currentStreak = 1;
    DateTime lastDate = stats[0].finished;

    for (var s in stats.skip(1)) {
      var daysBetween = lastDate.daysBetween(s.finished);
      lastDate = s.finished;

      if (daysBetween == 1) {
        currentStreak += 1;
      } else if (daysBetween > 1) {
        if (biggestStreak < currentStreak) {
          biggestStreak = currentStreak;
        }
        currentStreak = 1;
      }
    }

    return biggestStreak;
  }

  Stats() : saveBox = Hive.box(AppGlobals.statisticBoxName) {
    for (int i = 0; i < saveBox.length; i++) {
      stats.add(saveBox.getAt(i));
    }
  }

  void addStatPiece(StatPiece s, {bool checkIfAlreadyAdded = true}) {
    if (!checkIfAlreadyAdded || !_isStatsAlreadyAdded(s)) {
      stats.add(s);
      saveBox.add(s);
    }
  }

  List<int> getActivityMap(int year) {
    // Source: https://pub.dev/documentation/quiver/latest/quiver.time/isLeapYear.html#:~:text=Returns%20true%20if%20year%20is,including%20years%20divisible%20by%20400.
    bool isLeap = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

    var res = List<int>.filled(isLeap ? 366 : 365, 0, growable: false);

    var yearStart = DateTime(year);

    for (var stat in stats) {
      var currentDate = stat.finished;

      if (currentDate.year == year) {
        int diff = -yearStart.difference(currentDate).inDays;
        res[diff] += 1;
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

  DateTime get lastAvalibleDate => saveBox.length == 0
      ? DateTime.now()
      : (saveBox.getAt(0) as StatPiece).finished;
}

@HiveType(typeId: 1)
class StatPiece {
  /// Milliseconds since epoch
  @HiveField(0)
  final DateTime finished;

  // TODO: convert this to Duration
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
    required this.finished,
    required this.timeToSolve,
    required this.difficulty,
    required this.clues,
  });

  StatPiece.fromSudoku(SudokuField f)
      : difficulty = f.difficulty,
        timeToSolve = f.time,
        clues = f.cluesToString(),
        finished = DateTime.now();
}

extension _DaysBetween on DateTime {
  int daysBetween(DateTime to) {
    DateTime from = DateTime(year, month, day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
