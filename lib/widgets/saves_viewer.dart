import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/pages/solving.dart';
import 'package:sudoku/widgets/sudoku.dart';

class SavesViewer extends StatefulWidget {
  const SavesViewer({
    super.key,
    required this.file,
    required this.onDelete,
  });

  final File file;
  final Function(File) onDelete;

  @override
  State<SavesViewer> createState() => _SavesViewerState();
}

class _SavesViewerState extends State<SavesViewer> {
  late SudokuField field;
  @override
  void initState() {
    super.initState();
    field = SudokuField.fromFile(widget.file, context.read<AppGlobals>().infoBox);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _loadPuzzle(context),
            child: SudokuWidget(
              field: field,
              setSelected: null,
            ),
          ),
        ),
        Column(
          children: [
            const Icon(Icons.timer),
            Text(StopWatchTimer.getDisplayTime(field.time, milliSecond: false)),
            // add info of date into separator
            Text("saves-last-saved".i18n()),
            Text(_formatDate(field.saveFileStat!.modified)),
            Text("puzzle-rating".i18n()),
            Text(field.difficultyString),
            ElevatedButton.icon(
              onPressed: () async {
                if (await _showDeleteDialog()) widget.onDelete(widget.file);
              },
              icon: const Icon(Icons.delete),
              label: Text("delete".i18n()),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    // TODO: Use intl pacakge (localaze)
    String res = "";
    twoDecimalPlaces(int d) => d.toString().padLeft(2, "0");
    res +=
        "${dt.year}-${twoDecimalPlaces(dt.month)}-${twoDecimalPlaces(dt.day)} ${twoDecimalPlaces(dt.hour)}:${twoDecimalPlaces(dt.minute)}";
    return res;
  }

  void _loadPuzzle(BuildContext context) async {
    Navigator.of(context)
        .pushNamed(SolvingPage.routeName, arguments: field)
				// Updating this save tile
        .then(
          (value) => setState(
            () => field = SudokuField.fromFile(widget.file, context.read<AppGlobals>().infoBox),
          ),
        );
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("saves-delete".i18n()),
              content: Text("saves-delete-ask".i18n()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("yes".i18n()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("no".i18n()),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
