import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/other_logic/statistics.dart';

// TODO: Refactor UI
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
      Text(
        "stat-rating".i18n([stats.rating.toString()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Text(
        "stat-rating-average".i18n([stats.averagePuzzleRating.toString()]),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const Divider(),
      Text(
        "stat-time-solving".i18n([stats.timeSolving.format()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Text(
        "stat-time-average".i18n([stats.averageTimeSolving.format()]),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        "stat-longest-streak"
            .i18n([Duration(days: stats.longestStreak).format()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const Divider(),
      Text(
        "stat-puzzles-solved".i18n([stats.solvedCount.toString()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const Divider(),
      Text(
        "activity-chart".i18n(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      // TODO: Make year-chooser
      // TODO: Add two timestemps between which data is shown
      ActivityChart(
        activity: stats.getActivityMap(2023),
      ),
      const Divider(),
    ];
  }
}

class ActivityChart extends StatelessWidget {
  final List<int> activity;
  const ActivityChart({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color getColor(int numberOfActivities) {
      switch (numberOfActivities) {
        case 0:
          return primaryColor.withOpacity(0.0);
        case 1:
          return primaryColor.withOpacity(0.2);
        case 2:
          return primaryColor.withOpacity(0.4);
        case 3:
          return primaryColor.withOpacity(0.6);
        case 4:
          return primaryColor.withOpacity(0.8);
        default:
          return primaryColor.withOpacity(1);
      }
    }

    // TODO: Add timestampts
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 53;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < activity.length; i += 7)
              Column(
                children: [
                  for (int j = 0; (j < 7 && i + j < activity.length); j++)
                    Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: getColor(activity[i + j]),
                        borderRadius: BorderRadius.circular(cellSize * 0.0),
                      ),
                    )
                ],
              )
          ],
        );
      },
    );
  }
}

// TODO: Replace with even better formating
extension on Duration {
  String format() {
    String formatWithWords(int n, String s) {
      if (n == 0) return "";

      String formated = n.toString();

      return "$formated ${s.i18n([], [n == 1])} ";
    }

    String days = formatWithWords(inDays.abs(), "day");
    String hours = formatWithWords(inHours.remainder(24).abs(), "hour");
    String minutes = formatWithWords(inMinutes.remainder(60).abs(), "minute");
    String seconds = formatWithWords(inSeconds.remainder(60).abs(), "second");
    return "$days$hours$minutes$seconds".trimRight();
  }
}
