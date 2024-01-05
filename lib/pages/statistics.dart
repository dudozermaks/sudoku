import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/tools/stats.dart';

class StatisticsPage extends StatelessWidget {
  static const routeName = "/statistics";
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var stats = context.read<Stats>();
    return Scaffold(
      appBar: AppBar(title: Text("statistics".i18n())),
      body: ListView(
        children: buildBody(stats, context),
      ),
    );
  }

  List<Widget> buildBody(Stats stats, BuildContext context) {
    return [
      Row(
        children: [
          Text(
            "stat-rating".i18n([stats.rating.toString()]),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: 10),
          Text(
            "stat-rating-average".i18n([stats.averagePuzzleRating.toString()]),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      Row(
        children: [
          Text(
            "stat-time-solving".i18n([stats.timeSolving.format()]),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              "stat-time-average".i18n([stats.averageTimeSolving.format()]),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      Text(
        "stat-puzzles-solved".i18n([stats.solvedCount.toString()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ];
  }
}

extension on Duration {
  String format() {
    String negativeSign = isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
