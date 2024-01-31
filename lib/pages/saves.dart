import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/widgets/saves_viewer.dart';

// TODO: Refactor UI
class SavesPage extends StatefulWidget {
  static const routeName = "/saves";
  const SavesPage({super.key});

  @override
  State<SavesPage> createState() => _SavesPageState();
}

class _SavesPageState extends State<SavesPage> {
  final _files = List<File>.empty(growable: true);

  void _sortFiles() {
    _files.sort((a, b) {
      final aM = a.statSync().modified;
      final bM = b.statSync().modified;
      return bM.compareTo(aM);
    });
  }

  @override
  void initState() {
    super.initState();
    final savesDir = Directory(context.read<AppGlobals>().savesPath);

    if (savesDir.existsSync()) {
      for (var file in savesDir.listSync()) {
        _files.add(file as File);
      }
    }
    _sortFiles();
  }

  @override
  Widget build(BuildContext context) {
    _sortFiles();
    return Scaffold(
      appBar: AppBar(title: Text("saves".i18n())),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(context) {
    if (_files.isEmpty) {
      return Center(
        child: Text(
          "no-saved-files".i18n(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    // TODO: fix padding in portrait mode
    // TODO: maybe add 3, 4, 5... cross axis counts somehow
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        // https://api.flutter.dev/flutter/foundation/Key-class.html
        // https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        // In short, when you remove element from list, ListView is not aware of that
        // For it to determine that you have removed something, you have to provide an optional key parameter
        // that every widget has
        return SavesViewer(
          key: ValueKey(_files[index].path),
          file: _files[index],
          onDelete: _deleteSave,
        );
      },
    );
  }

  void _deleteSave(File f) {
    SudokuField.deleteFromDB(f).then(
      (value) => setState(
        () {
          f.deleteSync();
          _files.remove(f);
        },
      ),
    );
  }
}
