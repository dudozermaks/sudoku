import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/logic/sudoku.dart';
import 'package:sudoku/tools/app_settings.dart';

class Stats {
  var stats = List<StatPiece>.empty(growable: true);
  File saveFile;

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

  Stats(BuildContext context)
      : saveFile = context.read<AppSettings>().statFile {
    load();
  }

  fromJson(Map<String, dynamic> json) {
    for (var statJson in json["stats"]) {
      stats.add(StatPiece.fromJson(statJson));
    }
  }

  Map<String, dynamic> toJson() => {
        "stats": stats,
      };

  void save() {
    saveFile.writeAsString(
      jsonEncode(this),
    );
  }

  void load() {
    if (!saveFile.existsSync()) {
      return;
    }

    fromJson(
      jsonDecode(
        saveFile.readAsStringSync(),
      ),
    );
  }

  void addPuzzle(SudokuField f) {
    stats.add(StatPiece(f.difficulty, f.time));
    save();
  }
}

class StatPiece {
  final int timeFinished;
  final int timeToSolve;
  final int difficulty;

  StatPiece(this.difficulty, this.timeToSolve)
      : timeFinished = DateTime.now().millisecondsSinceEpoch;

  StatPiece.fromJson(Map<String, dynamic> json)
      // TODO: remove this questionmarks
      : timeFinished = json["timeFinished"] as int? ?? 0,
        timeToSolve = json["timeToSolve"] as int? ?? 0,
        difficulty = json["rating"] as int? ?? 0;

  Map<String, dynamic> toJson() => {
        "rating": difficulty,
        "timeFinished": timeFinished,
        "timeToSolve": timeToSolve,
      };
}
