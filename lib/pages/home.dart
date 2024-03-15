import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
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
                  "general.appName".i18n(),
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
                    _loadPuzzle(SudokuField(context.read<AppGlobals>().infoBox,
                        clues: _controller.text));
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
                        ? () => _loadPuzzle(SudokuField(
                            context.read<AppGlobals>().infoBox,
                            clues: _controller.text))
                        : null,
                    child: const Icon(Icons.send),
                  ),
                  labelText: "home.loadFromString".i18n(),
                  helperText: _controller.text.isNotEmpty
                      ? "home.canBeLoaded".i18n([], [canBeLoaded])
                      : null,
                  helperStyle:
                      TextStyle(color: canBeLoaded ? Colors.green : Colors.red),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              (MediaQuery.of(context).orientation == Orientation.portrait)
                  ? Column(
                      children: buildButtons(),
                    )
                  : Wrap(
                      spacing: 6,
                      alignment: WrapAlignment.center,
                      children: buildButtons(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildButtons() {
    return [
      buildButton(SavesPage.routeName, "saves.name".i18n(), Icons.save),
      buildButton(SolvingPage.userSettingRouteName, "home.setFieldYourself".i18n(),
          Icons.edit),
      buildButton(SolvingPage.generatingRouteName, "general.generateField".i18n(),
          Icons.computer),
      buildButton(
          StatisticsPage.routeName, "statistics.name".i18n(), Icons.analytics),
      buildButton(GuidesPage.routeName, "guides.name".i18n(), Icons.book),
      buildButton(SettingsPage.routeName, "settings.name".i18n(), Icons.settings),
    ];
  }

  Widget buildButton(String routeName, String text, IconData icon) {
    return SizedBox(
      width: 200,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(routeName),
        label: Text(text),
        icon: Icon(icon),
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
