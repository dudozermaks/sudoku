import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/other_logic/statistics.dart';

// TODO: Refactor UI
class StatisticsPage extends StatelessWidget {
  static const routeName = "/statistics";
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var stats = context.read<Stats>();
    return Scaffold(
      appBar: AppBar(title: Text("statistics.name".i18n())),
      body: Padding(
        padding: AppGlobals.padding.copyWith(top: 0),
        child: ListView(
          children: buildBody(stats, context),
        ),
      ),
    );
  }

  List<Widget> buildBody(Stats stats, BuildContext context) {
    return [
      Text(
        "statistics.rating".i18n([stats.rating.toString()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Text(
        "statistics.ratingAverage".i18n([stats.averagePuzzleRating.toString()]),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const Divider(),
      Text(
        "statistics.timeSolving".i18n([stats.timeSolving.format()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Text(
        "statistics.timeAverage".i18n([stats.averageTimeSolving.format()]),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        "statistics.longestStreak"
            .i18n([Duration(days: stats.longestStreak).format()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const Divider(),
      Text(
        "statistics.puzzlesSolved".i18n([stats.solvedCount.toString()]),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const Divider(),
      Text(
        "statistics.activityChart".i18n(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const ActivityChart(),
      const Divider(),
    ];
  }
}

class ActivityChart extends StatefulWidget {
  const ActivityChart({
    super.key,
  });

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var stats = context.read<Stats>();
    var activity = stats.getActivityMap(selectedDate.year);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 53;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () => pickYear(context, stats),
              child: Text("statistics.year".i18n([selectedDate.year.toString()])),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < activity.length; i += 7)
                  Column(
                    children: [
                      for (int j = 0; (j < 7 && i + j < activity.length); j++)
                        buildCell(cellSize, getColor(activity[i + j], context))
                    ],
                  ),
              ],
            ),
            const SizedBox.square(dimension: 10),
            Row(
              children: [
                Text(
                  "statistics.less".i18n(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox.square(dimension: 10),
                for (int i = 0; i < 5; i++)
                  buildCell(cellSize, getColor(i, context)),
                const SizedBox.square(dimension: 10),
                Text(
                  "statistics.more".i18n(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void pickYear(BuildContext context, Stats stats) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("statistics.pickYear".i18n()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("general.cancel".i18n()),
            ),
          ],
          content: SizedBox.square(
            dimension: 200,
            child: YearPicker(
              lastDate: DateTime.now(),
              firstDate: stats.lastAvalibleDate,
              selectedDate: selectedDate,
              onChanged: (DateTime dateTime) {
                setState(() {
                  selectedDate = dateTime;
                  Navigator.pop(context);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Color getColor(int numberOfActivities, BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    switch (numberOfActivities) {
      case 0:
        return primaryColor.withOpacity(0.05);
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

  Widget buildCell(double cellSize, Color c) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(cellSize * 0.2),
      ),
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

    String days = formatWithWords(inDays.abs(), "general.day");
    String hours = formatWithWords(inHours.remainder(24).abs(), "general.hour");
    String minutes = formatWithWords(inMinutes.remainder(60).abs(), "general.minute");
    String seconds = formatWithWords(inSeconds.remainder(60).abs(), "general.second");
    return "$days$hours$minutes$seconds".trimRight();
  }
}
