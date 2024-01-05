import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final Function(int) onPressed;
  const Numpad({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // return LayoutGrid(
    // Set the cols and rows to be equal sizes
    //   columnSizes: List<TrackSize>.generate(3, (index) => 1.fr),
    //   rowSizes: List<TrackSize>.generate(3, (index) => 1.fr),
    //   children: [
    //     for (int i = 1; i < 10; i++)
    //       ElevatedButton(
    //         onPressed: () => onPressed(i),
    //         style: ElevatedButton.styleFrom(
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(15)),
    //         ),
    //         child: Text(i.toString()),
    //       )
    //   ],
    // );

    return FittedBox(
      child: Column(
        children: [
          for (var y = 0; y < 3; y++)
            Row(
              children: [
                for (var x = 1; x < 4; x++) buildButton(x, y),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildButton(int x, int y) {
    return ElevatedButton(
      onPressed: () => onPressed(x + y * 3),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text((x + y * 3).toString()),
    );
  }
}
