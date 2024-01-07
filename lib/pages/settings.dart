import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localization/localization.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sudoku/tools/app_settings.dart';

class Settings extends StatelessWidget {
  static const routeName = "/settings";
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("settings".i18n())),
      body: SafeArea(
        child: SettingsList(
          lightTheme: buildTheme(context),
          darkTheme: buildTheme(context),
          sections: [buildThemeSection()],
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
          // value: Text("theme-mode-${themeBox.get("themeMode").name}".i18n()),
          onPressed: (context) {
            showDialog(
              context: context,
              builder: (context) {
                return _PickFromEnum(
                  title: Text("theme-mode".i18n()),
                  i18nPrefix: "theme-mode",
                  values: ThemeMode.values,
                  initialValue: themeBox.get("themeMode") as ThemeMode,
                  onSelected: (ThemeMode value) => themeBox.put("themeMode", value),
                );
              },
            );
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
