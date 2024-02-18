import 'package:hive_flutter/adapters.dart';
import 'package:localization/localization.dart';
import 'package:sudoku/src/rust/api/sudoku.dart';

part 'sudoku_info.g.dart';

@HiveType(typeId: 0)
class SudokuInfo {
  // If sudoku has 0 or more than 1 solution, this variable will be null
  @HiveField(0)
  String? uniqueSolution;

  @HiveField(1)
  int difficulty = 0;

  @HiveField(2)
  Map<String, int> usedMethods = {};

  @HiveField(3)
  bool humanEngineSolved = false;

  SudokuInfo(
      {required this.uniqueSolution,
      required this.difficulty,
      required this.usedMethods,
      required this.humanEngineSolved});

  SudokuInfo.empty()
      : difficulty = 0,
        usedMethods = {},
        humanEngineSolved = false;

  SudokuInfo.fromSudoku(String clues) {
    uniqueSolution = getUniqueSolution(sudokuString: clues);
    if (uniqueSolution != null) {
      var humanEngineRes = getRating(sudokuString: clues);

      difficulty = humanEngineRes.$1;
      usedMethods = humanEngineRes.$2;
      humanEngineSolved = humanEngineRes.$3;
    }
  }

  bool get isInfoAvalible => uniqueSolution != null;

  @override
  String toString() {
    var res =
        // ignore: prefer_interpolation_to_compose_strings
        "engine-info-unique-solution".i18n([(uniqueSolution != null).yesNo]) + "\n";

    if (isInfoAvalible) {
      res += "${"engine-info-difficulty".i18n([difficulty.toString()])}\n";
      res += "${"engine-info-solved".i18n([humanEngineSolved.yesNo])}\n";
      res += "${"engine-info-used-methods".i18n()}\n";

      usedMethods.forEach((key, value) {
        res += "${key.i18n()}: $value\n";
      });
    }

    return res;
  }
}

extension _YesNo on bool {
  String get yesNo => this ? "general.yes" : "general.no";
}
