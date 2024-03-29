import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/other_logic/debug_functions.dart';

import 'package:flutter/foundation.dart' as foundation;

// TODO: Refactor UI
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
      appBar: AppBar(title: Text("settings.name".i18n())),
      body: SafeArea(
        child: SettingsList(
          lightTheme: buildTheme(context),
          darkTheme: buildTheme(context),
          sections: [
            buildThemeSection(context),
            buildAboutSection(context),
            if (foundation.kDebugMode) buildDevelopmentSection()
          ],
        ),
      ),
    );
  }

  SettingsSection buildThemeSection(BuildContext context) {
    var themeBox = context.read<AppGlobals>().themeBox;
    return SettingsSection(
      title: Text("settings.theme.name".i18n()),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.color_lens),
          title: Text("settings.theme.baseColor".i18n()),
          trailing: Icon(Icons.circle, color: themeBox.get("color")),
          onPressed: (context) => pickColor(context, themeBox, "color"),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.dark_mode),
          title: Text("settings.theme.mode".i18n()),
          value: Text(
              "settings.theme.mode-${(themeBox.get("themeMode") as ThemeMode).name}"
                  .i18n()),
          onPressed: (context) {
            showDialog(
              context: context,
              builder: (context) {
                return _PickFromEnum(
                  title: Text("settings.theme.mode".i18n()),
                  i18nPrefix: "settings.theme.mode",
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
            title: Text("settings.theme.baseColor".i18n()),
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
                  child: Text("settings.theme.randomColor".i18n())),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("general.cancel".i18n()),
              ),
              TextButton(
                child: Text("settings.theme.selectColor".i18n()),
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

  buildAboutSection(BuildContext context) {
    return SettingsSection(
      title: Text("settings.about.name".i18n()),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.description_outlined),
          title: Text("settings.about.license".i18n()),
          // TODO: fix i18n duplicated key warning
          // NOTE: with useRootNavigator set to true, after hot-reload all warnings stop
          onPressed: (context) => showLicensePage(
            context: context,
            useRootNavigator: true,
						applicationVersion: "0.0.1"
          ),
        ),
				
      ],
    );
  }

  SettingsSection buildDevelopmentSection() {
    return SettingsSection(
      title: Text("settings.development.name".i18n()),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.delete_forever_outlined),
          title: Text("settings.development.deleteStats".i18n()),
          onPressed: (c) {
            deleteStats(c);

            ScaffoldMessenger.of(c)
                .showSnackBar(SnackBar(content: Text("general.done".i18n())));
          },
        ),
        SettingsTile(
          leading: const Icon(Icons.analytics_outlined),
          title: Text("settings.development.fakeStats".i18n()),
          onPressed: (c) {
            // TODO: add year-picker
            // TODO: do not delete previous stats
            generateStats(c, 2023, DateTime.now().millisecondsSinceEpoch);

            ScaffoldMessenger.of(c)
                .showSnackBar(SnackBar(content: Text("general.done".i18n())));
          },
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
          child: Text("general.cancel".i18n()),
        )
      ],
      content: RawScrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
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
        ),
      ),
    );
  }
}
