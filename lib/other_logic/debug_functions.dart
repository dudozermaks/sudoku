import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/other_logic/statistics.dart';

deleteStats(BuildContext context) {
  debugPrint("Deleting statistics");
  var stats = Provider.of<Stats>(context, listen: false);
  stats.saveBox.clear();
  stats.stats.clear();
}

generateStats(BuildContext context, int year) {
  int rgSeed = DateTime.now().millisecondsSinceEpoch;
  Random rg = Random(rgSeed);
  deleteStats(context);
  debugPrint("Generating fake statistics. Rg seed: $rgSeed");
  var stats = Provider.of<Stats>(context, listen: false);

  List<StatPiece> statPieces = List.empty(growable: true);
  for (int i = 0; i < 200; i++) {
    var s = StatPiece(
      difficulty: rg.nextInt(800) + 700,
      // 60 * 30s = 30 mins
      timeToSolve: Duration(seconds: rg.nextInt(60 * 30)),
      clues: "0" * 81,
      finished: DateTime(year).add(Duration(days: rg.nextInt(365))),
    );

    statPieces.add(s);
  }

  statPieces.sort((a, b) => a.finished.compareTo(b.finished));

  for (var s in statPieces) {
    stats.addStatPiece(s, checkIfAlreadyAdded: false);
  }
}
