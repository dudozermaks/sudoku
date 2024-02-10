import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku/other_logic/fake_boxes.dart';
import 'package:sudoku/src/rust/frb_generated.dart';
import 'package:sudoku/sudoku_logic/sudoku_info.dart';
import 'package:sudoku/other_logic/adapters.dart';
import 'package:sudoku/other_logic/statistics.dart';

class AppGlobals {
  late Box themeBox;
  late Box infoBox;
  late Box statisticsBox;

  static const EdgeInsets padding = EdgeInsets.all(5);
  late String applicationPath;
  late String savesPath;

  /// This function loads some async stuff (like RustLib, PathProvider and Hive).
  /// Also it setups everything needed for SudokuApp.
  /// You need to make sure to call this function before passing globals anywhere else.
  Future<void> load() async {
    const String themeBoxName = "themeBox";
    const String infoBoxName = "infoBox";
    const String statisticsBoxName = "statisticsBox";
    // Without this line path provider might not work on Android.
    // Also (I did not tested it) removing this line might break Hive and Rust Bridge
    WidgetsFlutterBinding.ensureInitialized();

    await RustLib.init();
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
    themeBox = Hive.box(themeBoxName);
    await Hive.openBox(infoBoxName);
    infoBox = Hive.box(infoBoxName);
    await Hive.openBox(statisticsBoxName);
    statisticsBox = Hive.box(statisticsBoxName);

    if (themeBox.isEmpty) {
      await themeBox.put("themeMode", ThemeMode.system);
      await themeBox.put("color", const Color(0xFF79E579));
    }
  }

  AppGlobals();
}
