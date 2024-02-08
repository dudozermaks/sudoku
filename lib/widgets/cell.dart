import 'package:flutter/material.dart';
import 'package:sudoku/sudoku_logic/pos.dart';

class Cell extends StatelessWidget {
  final Pos position;
  final VoidCallback? onTap;
  final bool isUserPlaced;
  final bool isSelected;
  final bool isError;
  final String clue;
  final String pencilmarks;

  const Cell({
    super.key,
    required this.position,
    required this.onTap,
    required this.isUserPlaced,
    required this.isSelected,
    required this.isError,
    required this.clue,
    required this.pencilmarks,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Color? bg;
    Color? fg;

    if (isSelected && isError) {
      bg = colorScheme.error;
      fg = colorScheme.onError;
    } else if (isSelected) {
      bg = colorScheme.primary;
      fg = colorScheme.onPrimary;
    } else if (isError) {
      bg = colorScheme.errorContainer;
      fg = colorScheme.onErrorContainer;
    }

    FontWeight fontWeight = FontWeight.w900;
    if (isUserPlaced) {
      if (clue == "") {
        fontWeight = FontWeight.w100;
      } else {
        fontWeight = FontWeight.w300;
      }
    }

    return SizedBox.square(
      dimension: 66,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(color: bg),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            textStyle: TextStyle(
              fontWeight: fontWeight,
              fontSize: clue != "" ? 30 : 18,
            ),
            foregroundColor: fg,
            disabledForegroundColor: colorScheme.primary,
          ),
          child: clue != "" ? Text(clue) : Text(pencilmarks),
        ),
      ),
    );
  }
}
