import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localization/localization.dart';

import 'package:provider/provider.dart';

import 'package:sudoku/logic/sudoku.dart';
import 'package:sudoku/logic/sudoku_info.dart';

import 'package:sudoku/pages/guides.dart';
import 'package:sudoku/pages/home.dart';
import 'package:sudoku/pages/saves.dart';
import 'package:sudoku/pages/settings.dart';
import 'package:sudoku/pages/solving.dart';
import 'package:sudoku/pages/statistics.dart';
import 'package:sudoku/tools/adapters.dart';

import 'package:sudoku/tools/app_settings.dart';
import 'package:sudoku/tools/stats.dart';

import 'package:sudoku/src/rust/frb_generated.dart';

var globals = AppGlobals();

Future<void> main() async {
  // Without this line path provider might not work on Android.
  // Also (I did not tested it) removing this line might break Hive and Rust Bridge
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();

  await Hive.initFlutter();
  Hive.registerAdapter(ThemeModeAdapter());
  Hive.registerAdapter(SudokuInfoAdapter());
  Hive.registerAdapter(ColorAdapter());

  await globals.load();

  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppGlobals>.value(value: globals),
        Provider<Stats>(create: (context) => Stats(context)),
      ],
      child: Builder(
        builder: (BuildContext context) => buildMaterialApp(context),
      ),
    );
  }

  Widget buildMaterialApp(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    return ValueListenableBuilder(
      valueListenable: Hive.box(AppGlobals.themeBoxName).listenable(),
      builder: (context, box, widget) {
        var themeMode = box.get("themeMode");
        var color = box.get("color");
        return MaterialApp(
          title: "app-name".i18n(),
          home: const HomePage(),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: color,
          ),
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: color,
          ),
          themeMode: themeMode,
          routes: <String, WidgetBuilder>{
            SolvingPage.routeName: (context) => SolvingPage(
                  field: _getField(context),
                ),
            SolvingPage.userSettingRouteName: (context) => SolvingPage(
                  field: _getField(context),
                  userSetting: true,
                ),
            SolvingPage.generatingRouteName: (context) => SolvingPage(
                  // TODO: when hot-reloading puzzle is generated again
                  field: SudokuField.generate(),
                  generated: true,
                ),
            Saves.routeName: (context) => const Saves(),
            StatisticsPage.routeName: (context) => const StatisticsPage(),
            Guides.routeName: (context) => const Guides(),
            Settings.routeName: (context) => const Settings(),
          },
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            LocalJsonLocalization.delegate,
          ],
        );
      },
    );
  }

  SudokuField _getField(BuildContext context) {
    return (ModalRoute.of(context)?.settings.arguments ?? SudokuField())
        as SudokuField;
  }
}
