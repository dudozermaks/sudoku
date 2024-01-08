import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku/logic/sudoku_info.dart';
import 'package:sudoku/tools/adapters.dart';
import 'package:sudoku/tools/stats.dart';

class AppGlobals {
  static const String themeBoxName = "themeBox";
  static const String infoBoxName = "infoBox";
  static const String statisticBoxName = "statisticsBox";
  late String applicationPath;
  late String savesPath;
  late File statFile;

  Future<void> load() async {
    // ignore: prefer_interpolation_to_compose_strings
    applicationPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        "SudokuApp";
    // ignore: prefer_interpolation_to_compose_strings
    savesPath = applicationPath + Platform.pathSeparator + "Puzzles";

    statFile =
        // ignore: prefer_interpolation_to_compose_strings
        File(applicationPath + Platform.pathSeparator + "statistics.json");

		await Hive.initFlutter(applicationPath);

		Hive.registerAdapter(ThemeModeAdapter());
		Hive.registerAdapter(SudokuInfoAdapter());
		Hive.registerAdapter(StatPieceAdapter());
		Hive.registerAdapter(ColorAdapter());

    await Hive.openBox(themeBoxName);
    await Hive.openBox(infoBoxName);
    await Hive.openBox(statisticBoxName);

    var themeBox = Hive.box(themeBoxName);

    if (themeBox.isEmpty) {
      await themeBox.put("themeMode", ThemeMode.system);
      await themeBox.put("color", const Color(0xFF79E579));
    }
  }

  AppGlobals();
}
