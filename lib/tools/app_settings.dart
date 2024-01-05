import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  var isLoaded = false;
  late SharedPreferences preferences;
  late String applicationPath;
  late String savesPath;
  late File statFile;
  var _color = const Color.fromARGB(255, 255, 190, 152);
  var _themeMode = ThemeMode.system;

  Future<void> load() async {
    if (isLoaded) return;
    preferences = await SharedPreferences.getInstance();
    // do not change defined value if no saved found
    _color = Color(preferences.getInt("color") ?? _color.value);
    _themeMode =
        ThemeMode.values[preferences.getInt("themeMode") ?? _themeMode.index];

    // ignore: prefer_interpolation_to_compose_strings
    applicationPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        "SudokuApp";
    // ignore: prefer_interpolation_to_compose_strings
    savesPath = applicationPath + Platform.pathSeparator + "Puzzles";
    // ignore: prefer_interpolation_to_compose_strings
    statFile =
        File(applicationPath + Platform.pathSeparator + "statistics.json");

    isLoaded = true;
    notifyListeners();
  }

  AppSettings();

  Color get color => _color;
  set color(Color c) {
    _color = c;
    preferences.setInt("color", c.value);
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode t) {
    _themeMode = t;
    preferences.setInt("themeMode", t.index);
    notifyListeners();
  }
}
