import 'package:flutter/material.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/sudoku_logic/pos.dart';
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
    var colorScheme = Theme.of(context).colorScheme;

    return HeroMode(
      // If the field is saved, then turn on animation (for animating from saves screen)
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

    VoidCallback? onTap;
    bool isSelected = false;
    bool isError = false;

    if (setSelected != null) {
      onTap = () => setSelected!(position);
      isSelected = position == field.selected;
      isError = !field.isRightPlaced(index);
    }

    return Cell(
      position: position,
      onTap: onTap,
      isSelected: isSelected,
      isError: isError,
      isUserPlaced: field.isUserPlaced(index),
      clue: field.getClue(index),
      pencilmarks: field.getPencilmarks(index),
    );
  }
}
