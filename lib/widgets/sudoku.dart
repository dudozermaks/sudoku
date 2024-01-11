import 'package:flutter/material.dart';
import 'package:sudoku/logic/sudoku.dart';
import 'package:sudoku/tools/pos.dart';
import 'package:sudoku/widgets/cell.dart';

class SudokuWidget extends StatelessWidget {
  final SudokuField field;
  final Function(Pos)? setSelected;

  const SudokuWidget({
    super.key,
    required this.field,
    required this.setSelected,
  });

  @override
  Widget build(BuildContext context) {
    // return AspectRatio(
    //   aspectRatio: 1 / 1,
    //   child: LayoutGrid(
    //     // Set the cols and rows to be equal sizes
    //     columnSizes: List<TrackSize>.generate(9, (index) => 1.fr),
    //     rowSizes: List<TrackSize>.generate(9, (index) => 1.fr),
    //     children: [
    //       for (var j = 0; j < 9; j++)
    //         for (var i = 0; i < 9; i++) buildCell(Pos(i, j))
    //     ],
    //   ),
    // );
    // return Table(
    //   children: [
    //     for (var y = 0; y < 9; y++)
    //       TableRow(
    //         children: [
    //           for (var x = 0; x < 9; x++)
    // 				buildCell(Pos(x, y))
    //             // FittedBox(
    //             //   child: Container(
    //             //     width: 20,
    //             //     height: 20,
    //             //     color: Colors.red,
    //             //     child: Center(child: Text("9")),
    //             //   ),
    //             // )
    //           // SizedBox.square(
    //           // 	dimension: 10,
    //           // 	// width: 10,
    //           // 	// height: 10,
    //           // 	// child: FittedBox(child: ColoredBox(color: Colors.red)),
    //           // 	// color: Colors.red,
    //           // )
    //         ],
    //       )
    //   ],
    // );
    var colorScheme = Theme.of(context).colorScheme;
    return HeroMode(
      enabled: field.saveFileName != null,
      child: Hero(
        tag: field.saveFileName ?? "",
        child: FittedBox(
          child: Column(
            children: buildColumn(colorScheme.outline),
          ),
        ),
      ),
    );
  }

  List<Widget> buildColumn(Color borderColor) {
    var res = List<Widget>.empty(growable: true);
    for (var y = 0; y < 3; y++) {
      res.add(Row(
        children: buildRow(borderColor, y),
      ));
      res.add(SizedBox(
        width: 198 * 3 + 10,
        height: 5,
        child: ColoredBox(color: borderColor),
      ));
    }
    res.removeLast();
    return res;
  }

  List<Widget> buildRow(Color borderColor, int y) {
    var res = List<Widget>.empty(growable: true);

    for (var x = 0; x < 3; x++) {
      res.add(build3x3Grid(Pos(x, y)));
      res.add(SizedBox(
        width: 5,
        height: 198,
        child: ColoredBox(color: borderColor),
      ));
    }
    res.removeLast();
    return res;
  }

  Widget build3x3Grid(Pos position) {
    return Column(
      children: [
        for (var y = 0; y < 3; y++)
          Row(
            children: [
              for (var x = 0; x < 3; x++) buildCell(Pos(x, y) + position * 3)
            ],
          ),
      ],
    );
  }

  Cell buildCell(Pos position) {
		int index = position.toIndex();

    if (setSelected != null) {
			return Cell(
				position: position,
				onTap: () => setSelected!(position),
				isSelected: position == field.selected,
				isError: !field.isRightPlaced(index),
				isUserPlaced: field.isUserPlaced(index),
				clue: field.getClue(index),
				pencilmarks: field.getPencilmarks(index),
			);
    }
		else {
			return Cell(
				position: position,
				onTap: null,
				isSelected: false,
				isError: false,
				isUserPlaced: field.isUserPlaced(index),
				clue: field.getClue(index),
				pencilmarks: field.getPencilmarks(index),
			);
		}
  }
}
