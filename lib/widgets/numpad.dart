import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final Function(int) onPressed;
  const Numpad({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
