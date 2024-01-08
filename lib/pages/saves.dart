import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/logic/sudoku.dart';
import 'package:sudoku/tools/app_settings.dart';
import 'package:sudoku/widgets/saves_viewer.dart';

class Saves extends StatefulWidget {
  static const routeName = "/saves";
  const Saves({super.key});

  @override
  State<Saves> createState() => _SavesState();
}

class _SavesState extends State<Saves> {
  final _files = List<File>.empty(growable: true);
  bool loaded = false;
  void _getFiles() {
    final savesDir = Directory(context.read<AppGlobals>().savesPath);

    if (savesDir.existsSync()) {
      for (var file in savesDir.listSync()) {
        _files.add(file as File);
      }
    }

    _files.sort((a, b) {
      final aM = a.statSync().modified;
      final bM = b.statSync().modified;
      return bM.compareTo(aM);
    });

    setState(() {
      loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("saves".i18n())),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(context) {
    if (loaded) {
      if (_files.isEmpty) {
        return Center(
          child: Text(
            "no-saved-files".i18n(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }
      return ListView.separated(
        itemCount: _files.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return SavesViewer(
            file: _files[index],
            onDelete: _deleteSave,
          );
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  void _deleteSave(File f) {
    SudokuField.deleteFromDB(f).then(
      (value) => setState(
        () {
          _files.remove(f);
          f.deleteSync();
        },
      ),
    );
  }
}
