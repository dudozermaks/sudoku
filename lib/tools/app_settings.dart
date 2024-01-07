import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class AppGlobals {
  var isLoaded = false;
  static const String themeBoxName = "themeBox";
  static const String infoBoxName = "infoBox";
  late String applicationPath;
  late String savesPath;
  late File statFile;

  Future<void> load() async {
    if (isLoaded) return;
    await Hive.openBox(themeBoxName);
    await Hive.openBox(infoBoxName);

    var themeBox = Hive.box(themeBoxName);

    if (themeBox.isEmpty) {
      await themeBox.put("themeMode", ThemeMode.system);
      await themeBox.put("color", const Color(0xFF79E579));
    }

    // ignore: prefer_interpolation_to_compose_strings
    applicationPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        "SudokuApp";
    // ignore: prefer_interpolation_to_compose_strings
    savesPath = applicationPath + Platform.pathSeparator + "Puzzles";

    statFile =
        // ignore: prefer_interpolation_to_compose_strings
        File(applicationPath + Platform.pathSeparator + "statistics.json");

    isLoaded = true;
  }

  AppGlobals();
}
