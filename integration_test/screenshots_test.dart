import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/main.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:integration_test/integration_test.dart';

void makeScreenshot(
    Widget w, String testName, String fileName, Function(WidgetTester) later) {
  testWidgets(testName, (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080 / 2, 1920 / 2);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(w);

    // Without this line the whole method does not work.
    // main.png is just a blank screenshot.
    await tester.pumpAndSettle();

    await later(tester);

    await expectLater(
      find.byType(SudokuApp),
      matchesGoldenFile('screenshots/$fileName.png'),
    );
    debugDefaultTargetPlatformOverride = null;
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  var appGlobals = AppGlobals();
  setUpAll(() async {
    await appGlobals.load();
		await appGlobals.themeBox.put("themeMode", ThemeMode.dark);
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

  // TODO: remove this Done thing at the bottom
  makeScreenshot(
    SudokuApp(
      appGlobals: appGlobals,
      showDebugBanner: false,
    ),
    "Statistics",
    "statistics_page",
    (t) async {
      // Generaing fake stats
      await t.tap(find.byIcon(Icons.settings));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.analytics_outlined));
      await t.pumpAndSettle();
      // Going back
      await t.tap(find.byIcon(Icons.arrow_back));
      await t.pumpAndSettle();
      // Going to statistics page
      await t.tap(find.byIcon(Icons.analytics));
      await t.pumpAndSettle();
      await t.tap(find.byType(TextButton));
      await t.pumpAndSettle();
      // Choosing year
      await t.tap(find.bySemanticsLabel("2023"));
      await t.pumpAndSettle(const Duration(seconds: 1));
    },
  );
}
