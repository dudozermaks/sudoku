import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/pages/guides.dart';
import 'package:sudoku/pages/saves.dart';
import 'package:sudoku/pages/settings.dart';
import 'package:sudoku/pages/solving.dart';
import 'package:sudoku/pages/statistics.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: foundation.kDebugMode
          ? "000000010400000000020000000000050407008000300001090000300400200050100000000806000"
          : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    bool canBeLoaded = _controller.text.isValidClues();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppGlobals.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "app-name".i18n(),
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                onChanged: (String text) {
                  setState(() {});
                },
                onSubmitted: (String value) {
                  if (canBeLoaded) {
                    _loadPuzzle(SudokuField(clues: _controller.text));
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: TextButton(
                    child: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _controller.clear();
                    }),
                  ),
                  suffixIcon: TextButton(
                    onPressed: canBeLoaded
                        ? () =>
                            _loadPuzzle(SudokuField(clues: _controller.text))
                        : null,
                    child: const Icon(Icons.send),
                  ),
                  labelText: "load-from-string".i18n(),
                  helperText: _controller.text.isNotEmpty
                      ? "can-be-loaded".i18n([], [canBeLoaded])
                      : null,
                  helperStyle:
                      TextStyle(color: canBeLoaded ? Colors.green : Colors.red),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
							// TODO: Does not work on Android when changing orientaiton:(
              OrientationBuilder(builder: (context, orientation) {
                List<Widget> buttons = buildButtons();
                if (orientation == Orientation.portrait) {
                  return Column(
                    children: [...buttons],
                  );
                }
                return Wrap(
                  children: [...buttons],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildButtons() {
    return [
      buildButton(SavesPage.routeName, "saves".i18n()),
      buildButton(
          SolvingPage.userSettingRouteName, "set-field-yourself".i18n()),
      buildButton(SolvingPage.generatingRouteName, "generate-field".i18n()),
      buildButton(StatisticsPage.routeName, "statistics".i18n()),
      buildButton(GuidesPage.routeName, "guides".i18n()),
      buildButton(SettingsPage.routeName, "settings".i18n()),
    ];
  }

  Widget buildButton(String routeName, String text) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pushNamed(routeName),
        child: Text(text),
      ),
    );
  }

  void _loadPuzzle(SudokuField field) {
    Navigator.of(context).pushNamed(
      SolvingPage.routeName,
      arguments: field,
    );
  }
}
