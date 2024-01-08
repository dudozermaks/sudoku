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

	void _sortFiles(){
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
		
		return ListView.separated(
			itemCount: _files.length,

			separatorBuilder: (context, index) => const Divider(),
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
