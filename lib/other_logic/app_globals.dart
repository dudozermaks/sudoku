import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku/sudoku_logic/sudoku_info.dart';
import 'package:sudoku/other_logic/adapters.dart';
import 'package:sudoku/other_logic/statistics.dart';

class AppGlobals {
  static const String themeBoxName = "themeBox";
  static const String infoBoxName = "infoBox";
  static const String statisticBoxName = "statisticsBox";
	static const EdgeInsets padding = EdgeInsets.all(5);
  late String applicationPath;
  late String savesPath;

  Future<void> load() async {
    // ignore: prefer_interpolation_to_compose_strings
    applicationPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        "SudokuApp";
    // ignore: prefer_interpolation_to_compose_strings
    savesPath = applicationPath + Platform.pathSeparator + "Puzzles";


		await Hive.initFlutter(applicationPath);

		// Custom adapters
		Hive.registerAdapter(ThemeModeAdapter());
		Hive.registerAdapter(DurationAdapter());
		// Generated adapters
		Hive.registerAdapter(SudokuInfoAdapter());
		Hive.registerAdapter(StatPieceAdapter());
		// Built-in adapters
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
