import 'package:flutter/material.dart';
import 'package:sudoku/tools/pos.dart';

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

    // return Focus(
    //   onKey: (node, event) {
    //     if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
    //       onTap();
    //       return KeyEventResult.handled;
    //     }
    //     return KeyEventResult.ignored;
    //   },
    //   child: GestureDetector(
    //     onTap: onTap,
    //     child: Container(
    //       alignment: Alignment.center,
    //       decoration: BoxDecoration(
    //         color: isSelected ? colorScheme.onPrimary : colorScheme.onSecondary,
    //         border: Border(
    //           // Conditionally set the border thickness
    //           top: BorderSide(
    //               color: colorScheme.outline,
    //               width: position.y >= 0 && position.y % 3 == 0 ? 2 : 1),
    //           right: BorderSide(
    //               color: colorScheme.outline,
    //               width: position.x >= 0 && position.x % 3 == 2 ? 2 : 1),
    //           bottom: BorderSide(
    //               color: colorScheme.outline,
    //               width: position.y <= 8 && position.y % 3 == 2 ? 2 : 1),
    //           left: BorderSide(
    //               color: colorScheme.outline,
    //               width: position.x <= 8 && position.x % 3 == 0 ? 2 : 1),
    //         ),
    //       ),
    //       child: Text(
    //         clue,
    //         style: TextStyle(
    //             color: isSelected ? colorScheme.primary : colorScheme.secondary,
    //             // Responsive text size
    //             fontSize: min(MediaQuery.of(context).size.width,
    //                     MediaQuery.of(context).size.height) /
    //                 25,
    //             fontWeight: isUserPlaced ? FontWeight.normal : FontWeight.bold),
    //       ),
    //     ),
    //   ),
    // );
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
