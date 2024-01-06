import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';

import 'package:provider/provider.dart';

import 'package:sudoku/logic/sudoku.dart';

import 'package:sudoku/pages/guides.dart';
import 'package:sudoku/pages/home.dart';
import 'package:sudoku/pages/loading.dart';
import 'package:sudoku/pages/saves.dart';
import 'package:sudoku/pages/settings.dart';
import 'package:sudoku/pages/solving.dart';
import 'package:sudoku/pages/statistics.dart';

import 'package:sudoku/tools/app_settings.dart';
import 'package:sudoku/tools/stats.dart';

import 'package:sudoku/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>(create: (_) => AppSettings()),
        Provider<Stats>(create: (context) => Stats(context)),
      ],
      child: Builder(
        builder: (BuildContext context) => buildMaterialApp(context),
      ),
    );
  }

  MaterialApp buildMaterialApp(BuildContext context) {
		LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    var settings = context.watch<AppSettings>();

    return MaterialApp(
      title: "app-name".i18n(),

      home: FutureBuilder(
        future: Future.wait([settings.load()]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          }
          return const LoadingPage();
        },
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: settings.color,
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: settings.color,
      ),
			// TODO: this does not change
      themeAnimationDuration:
          settings.isLoaded ? Duration.zero : kThemeAnimationDuration,
      themeMode: settings.themeMode,

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
  }

  SudokuField _getField(BuildContext context) {
    return (ModalRoute.of(context)?.settings.arguments ?? SudokuField())
        as SudokuField;
  }
}
