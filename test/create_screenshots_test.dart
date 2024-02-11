import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:sudoku/main.dart';
import 'package:sudoku/other_logic/app_globals.dart';

void main() async {
	// TODO: remove golden_toolkit as a dependecie (only needed for this one line)
	await loadAppFonts();
  var appGlobals = AppGlobals();
  await appGlobals.loadForScreenshots();

  await appGlobals.themeBox.put("themeMode", ThemeMode.dark);
  await appGlobals.themeBox.put("color", const Color(0xFF79E579));

  // TODO: make rust initialize (see integration test)
  testWidgets('Home page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);

    await tester.pumpWidget(SudokuApp(
      appGlobals: appGlobals,
    ));

    // Without this line the whole method does not work.
    // main.png is just a blank screenshot.
    await tester.pumpAndSettle();

    await expectLater(
        find.byType(SudokuApp), matchesGoldenFile('screenshots/home_page.png'));
  });
}