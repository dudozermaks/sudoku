import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sudoku/tools/app_settings.dart';
import 'package:sudoku/tools/stats.dart';

import 'package:flutter/foundation.dart' as foundation;

class SettingsPage extends StatefulWidget {
  static const routeName = "/settings";
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("settings".i18n())),
      body: SafeArea(
        child: SettingsList(
          lightTheme: buildTheme(context),
          darkTheme: buildTheme(context),
          sections: [
            buildThemeSection(),
            if (foundation.kDebugMode) buildDevelopmentSection()
          ],
        ),
      ),
    );
  }

  SettingsSection buildThemeSection() {
    var themeBox = Hive.box(AppGlobals.themeBoxName);
    return SettingsSection(
      title: Text("theme".i18n()),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.color_lens),
          title: Text("theme-base-color".i18n()),
          trailing: Icon(Icons.circle, color: themeBox.get("color")),
          onPressed: (context) => pickColor(context, themeBox, "color"),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.dark_mode),
          title: Text("theme-mode".i18n()),
          value: Text(
              "theme-mode-${(themeBox.get("themeMode") as ThemeMode).name}"
                  .i18n()),
          onPressed: (context) {
            showDialog(
              context: context,
              builder: (context) {
                return _PickFromEnum(
                  title: Text("theme-mode".i18n()),
                  i18nPrefix: "theme-mode",
                  values: ThemeMode.values,
                  initialValue: themeBox.get("themeMode") as ThemeMode,
                  onSelected: (ThemeMode value) =>
                      themeBox.put("themeMode", value),
                );
              },
            ).then((value) => setState(() {}));
          },
        ),
      ],
    );
  }

  SettingsThemeData buildTheme(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SettingsThemeData(
      settingsListBackground: colorScheme.background,
      titleTextColor: colorScheme.onBackground,
    );
  }

  void pickColor(BuildContext context, Box box, String name) {
    Color pickerColor = box.get(name, defaultValue: const Color(0xFF000000));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("theme-base-color".i18n()),
            content: SingleChildScrollView(
              child: ColorPicker(
                labelTypes: const [],
                pickerColor: pickerColor,
                onColorChanged: (Color color) => pickerColor = color,
                enableAlpha: false,
                hexInputBar: true,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() => pickerColor =
                        Color((Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1.0));
                  },
                  child: Text("theme-random-color".i18n())),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("cancel".i18n()),
              ),
              TextButton(
                child: Text("select".i18n()),
                onPressed: () {
                  box.put(name, pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  SettingsSection buildDevelopmentSection() {
    deleteStats(BuildContext context) {
      debugPrint("Deleting statistics");
      var stats = Provider.of<Stats>(context, listen: false);
      stats.saveBox.clear();
      stats.stats.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("done".i18n())));
    }

    generateStats(BuildContext context) {
      int rgSeed = DateTime.now().millisecondsSinceEpoch;
      Random rg = Random(rgSeed);
      deleteStats(context);
      debugPrint("Generating fake statistics. Rg seed: $rgSeed");
      var stats = Provider.of<Stats>(context, listen: false);

      List<StatPiece> statPieces = List.empty(growable: true);
      for (int i = 0; i < 200; i++) {
        var s = StatPiece(
          difficulty: rg.nextInt(800) + 700,
          // 60 * 30 * 1000 ms = 30 mins
          timeToSolve: rg.nextInt(60 * 30 * 1000),
          clues: "0" * 81,
          // from 01.01.2022 to 01.01.2023
          finished: DateTime(2023).add(Duration(days: rg.nextInt(365))),
        );

        statPieces.add(s);
      }

      statPieces.sort((a, b) => a.finished.compareTo(b.finished));

      for (var s in statPieces) {
        stats.addStatPiece(s, checkIfAlreadyAdded: false);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("done".i18n())));
    }

    return SettingsSection(
      title: const Text("Development"),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.delete_forever_outlined),
          title: Text("development-delete-stats".i18n()),
          onPressed: deleteStats,
        ),
        SettingsTile(
          leading: const Icon(Icons.analytics_outlined),
          title: Text("development-fake-stats".i18n()),
          onPressed: generateStats,
        ),
      ],
    );
  }
}

class _PickFromEnum<T extends Enum> extends StatelessWidget {
  final List<T> values;
  final T initialValue;
  final Function(T) onSelected;
  final String i18nPrefix;
  final Widget title;

  const _PickFromEnum({
    super.key,
    required this.values,
    required this.initialValue,
    required this.onSelected,
    required this.i18nPrefix,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("cancel".i18n()),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var value in values)
            RadioListTile<T>(
              title: Text("$i18nPrefix-${value.name}".i18n()),
              value: value,
              groupValue: initialValue,
              onChanged: (value) {
                onSelected(value ?? values[0]);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
