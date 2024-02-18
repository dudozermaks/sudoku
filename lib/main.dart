import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localization/localization.dart';

import 'package:provider/provider.dart';

import 'package:sudoku/sudoku_logic/sudoku.dart';

import 'package:sudoku/pages/guides.dart';
import 'package:sudoku/pages/home.dart';
import 'package:sudoku/pages/saves.dart';
import 'package:sudoku/pages/settings.dart';
import 'package:sudoku/pages/solving.dart';
import 'package:sudoku/pages/statistics.dart';

import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/other_logic/statistics.dart';

Future<void> main() async {
  var appGlobals = AppGlobals();
  await appGlobals.load();

  runApp(SudokuApp(
    appGlobals: appGlobals,
		showDebugBanner: kDebugMode,
  ));
}

class SudokuApp extends StatelessWidget {
  final AppGlobals appGlobals;
	final bool showDebugBanner;
  const SudokuApp({
    super.key,
    required this.appGlobals, required this.showDebugBanner,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppGlobals>.value(value: appGlobals),
        Provider<Stats>(
            create: (context) => Stats(saveBox: appGlobals.statisticsBox)),
      ],
      child: Builder(
        builder: (BuildContext context) => buildMaterialApp(context),
      ),
    );
  }

  Widget buildMaterialApp(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    return ValueListenableBuilder(
      valueListenable: appGlobals.themeBox.listenable(),
      builder: (context, box, widget) {
        var themeMode = box.get("themeMode");
        var color = box.get("color");
        return MaterialApp(
          title: "general.appName".i18n(),
          home: const HomePage(),
					debugShowCheckedModeBanner: showDebugBanner,
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
                  field:
                      SudokuField.generate(context.read<AppGlobals>().infoBox),
                  generated: true,
                ),
            SavesPage.routeName: (context) => const SavesPage(),
            StatisticsPage.routeName: (context) => const StatisticsPage(),
            GuidesPage.routeName: (context) => const GuidesPage(),
            SettingsPage.routeName: (context) => const SettingsPage(),
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
    return (ModalRoute.of(context)?.settings.arguments ??
        SudokuField(context.read<AppGlobals>().infoBox)) as SudokuField;
  }
}
