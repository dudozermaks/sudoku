import 'dart:math';

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
        child: LayoutBuilder(builder: (context, constraints) {
          double sideSize = min(constraints.maxWidth, constraints.maxHeight);
          double separatorSize = sideSize * 0.008;
          double cellSize = (sideSize - separatorSize * 2) / 9;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 9; i++)
                ...buildRowWithSeparator(
                  i,
                  separatorSize,
                  colorScheme.outline,
                  cellSize,
                  sideSize,
                )
            ],
          );
        }),
      ),
    );
  }

  List<Widget> buildRowWithSeparator(
    int rowCount,
    double separatorSize,
    Color separatorColor,
    double cellSize,
    double sideSize,
  ) {
    var cells = List<Widget>.empty(growable: true);

    for (int i = 0; i < 9; i++) {
      cells.add(
        buildCell(
          Pos(i, rowCount),
          cellSize,
        ),
      );

      if (i == 2 || i == 5) {
        cells.add(SizedBox(
          width: separatorSize,
          height: cellSize,
          child: ColoredBox(color: separatorColor),
        ));
      }
    }

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cells,
      ),
      if (rowCount == 2 || rowCount == 5)
        SizedBox(
          width: sideSize,
          height: separatorSize,
          child: ColoredBox(color: separatorColor),
        )
    ];
  }

  Cell buildCell(Pos position, double size) {
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
      size: size,
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
