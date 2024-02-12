import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/main.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:integration_test/integration_test.dart';

void makeScreenshot(
    Widget w, String testName, String fileName, Function(WidgetTester) later) {
  testWidgets(testName, (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080 / 2, 1920 / 2);

    await tester.pumpWidget(w);

    // Without this line the whole method does not work.
    // main.png is just a blank screenshot.
    await tester.pumpAndSettle();

    await later(tester);

    await expectLater(
      find.byType(SudokuApp),
      matchesGoldenFile('screenshots/$fileName.png'),
    );
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  var appGlobals = AppGlobals();
  setUpAll(() async {
    await appGlobals.load();
  });

  makeScreenshot(
    SudokuApp(
      appGlobals: appGlobals,
      showDebugBanner: false,
    ),
    "Home page",
    "home_page",
    (t) {},
  );

  makeScreenshot(
    SudokuApp(
      appGlobals: appGlobals,
      showDebugBanner: false,
    ),
    "Solving page",
    "solving_page",
    (t) async {
      await t.tap(find.byIcon(Icons.send));
      await t.pumpAndSettle();
    },
  );
}
