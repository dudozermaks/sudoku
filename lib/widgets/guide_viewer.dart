import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/widgets/sudoku.dart';

class GuideViewer extends StatelessWidget {
  final String path;
  final String title;
  const GuideViewer({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(path),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildGuide(
                context,
                snapshot.data?.split("\n") ?? ["guides.noContent".i18n()],
              );
            } else if (snapshot.hasError) {
              return Text("general.error".i18n([snapshot.error.toString()]));
            } else {
              return Text("general.loading".i18n());
            }
          },
        ),
      ),
    );
  }

  Widget buildGuide(BuildContext context, List<String> data) {
    return ListView(
      children: [for (var line in data) _parseLine(line, context)],
    );
  }

  Widget _parseLine(String line, BuildContext context) {
    if (line.startsWith("-sudoku=")) {
      return SudokuWidget(
        field: SudokuField(context.read<AppGlobals>().infoBox, clues: line.substring(8)),
        setSelected: null,
      );
    }
    return Text(line, style: Theme.of(context).textTheme.bodyLarge);
  }
}
