import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/sudoku_logic/sudoku.dart';
import 'package:sudoku/other_logic/app_globals.dart';
import 'package:sudoku/sudoku_logic/pos.dart';
import 'package:sudoku/other_logic/statistics.dart';
import 'package:sudoku/widgets/numpad.dart';
import 'package:sudoku/widgets/sudoku.dart';

class SolvingPage extends StatefulWidget {
  static const routeName = "/solving";
  static const userSettingRouteName = "/setting_and_solving";
  static const generatingRouteName = "/generating_and_solving";
  final bool userSetting;
  final SudokuField field;
  final bool generated;

  const SolvingPage({
    super.key,
    required this.field,
    this.userSetting = false,
    this.generated = false,
  });

  @override
  State<SolvingPage> createState() => _SolvingPageState();
}

class _SolvingPageState extends State<SolvingPage> with WidgetsBindingObserver {
  final timer = StopWatchTimer(mode: StopWatchMode.countUp);
  bool fieldIsDone = false;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var orientation = MediaQuery.of(context).orientation;

    // deprecated in future versions of Flutter
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildTimer(colorScheme),
          centerTitle: true,
          leading: BackButton(onPressed: _goBack),
        ),
        body: _buildMain(context, orientation),
      ),
    );
  }

  Widget _buildMain(BuildContext context, Orientation orientation) {
    var buttons = _buildButtons();

    var difficultyWidget = Text(
      widget.field.difficultyString,
      style: Theme.of(context).textTheme.titleLarge,
    );

    var sudokuWidget = SudokuWidget(
      field: widget.field,
      setSelected: (Pos selected) {
        setState(() {
          widget.field.selected = selected;
        });
      },
    );

    var numpadWidget = Numpad(onPressed: (int a) {
      setState(() {
        widget.field.toggleNumber(a);
      });
    });

    List<Widget> children;
    if (orientation == Orientation.portrait) {
      children = [
        difficultyWidget,
        Flexible(
          flex: 9,
          child: sudokuWidget,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: buttons,
        ),
        Expanded(
          flex: 7,
          child: FittedBox(
            child: numpadWidget,
          ),
        )
      ];
    } else {
      children = [
        Flexible(
          flex: 1,
          child: sudokuWidget,
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                widget.field.difficultyString,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Expanded(
                child: FittedBox(
                  child: numpadWidget,
                ),
              )
            ],
          ),
        ),
      ];
    }

    return (orientation == Orientation.portrait)
        ? Column(
            children: children,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          );
  }

  List<Widget> _buildButtons() {
    List<Widget> res = List<Widget>.empty(growable: true);

    buildButton(VoidCallback onPressed, IconData icon) {
      return Expanded(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Icon(icon),
        ),
      );
    }

    res.add(
      buildButton(
        _togglePencilmarkMode,
        widget.field.pencilmarkMode ? Icons.edit_off : Icons.edit,
      ),
    );

    if (fieldIsDone) {
      res.add(
        buildButton(_copyToClipboard, Icons.copy),
      );
      res.add(
        buildButton(_save, Icons.save),
      );
      res.add(
        buildButton(_infoPressed, Icons.info),
      );
      if (!widget.field.hasBeenModified && widget.generated) {
        res.add(
          buildButton(_generateNextField, Icons.skip_next),
        );
      }
    } else {
      res.add(
        buildButton(_finishField, Icons.done),
      );
    }

    return res;
  }

  void _generateNextField() => Navigator.of(context)
      .pushReplacementNamed(SolvingPage.generatingRouteName);

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.field.cluesToString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("clues-copied".i18n()),
        showCloseIcon: true,
      ),
    );
  }

  void _togglePencilmarkMode() => setState(() {
        widget.field.pencilmarkMode = !widget.field.pencilmarkMode;
      });

  StreamBuilder<int> _buildTimer(ColorScheme colorScheme) {
    return StreamBuilder<int>(
      stream: timer.rawTime,
      initialData: timer.rawTime.value,
      builder: (context, snapshot) {
        final value = snapshot.data!;
        final displayTime =
            StopWatchTimer.getDisplayTime(value, milliSecond: false);
        widget.field.time = value;

        return Text(
          displayTime,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w400,
          ),
        );
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await timer.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      timer.onStopTimer();
    } else if (state == AppLifecycleState.resumed) {
      timer.onStartTimer();
    }
  }

  Future<bool> _askUserToGoBack() async {
    if (!widget.field.hasBeenModified) {
      return true;
    }

    bool doExit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("go-back".i18n()),
              content: Text("go-back-ask".i18n()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("no".i18n()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("yes".i18n()),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!doExit) return false;
    if (!context.mounted) return false;
    if (!fieldIsDone) return true;

    bool doSave = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("save".i18n()),
              content: Text("save-before-exit-ask".i18n()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("no".i18n()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("yes".i18n()),
                ),
              ],
            );
          },
        ) ??
        true;

    if (doSave) {
      await _save();
    }

    return true;
  }

  void _goBack() async {
    if (await _askUserToGoBack() && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _finishField() {
    setState(() {
      fieldIsDone = true;
    });
    widget.field.fix();
    timer.onStartTimer();
  }

  void _infoPressed() async {
    var content = "${"engine-info".i18n()}\n${widget.field.info.toString()}";

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("puzzle-info".i18n()),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".i18n()),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    timer.setPresetTime(mSec: widget.field.time);
    widget.field.onCompleted = _onCompleted;
    if (!widget.userSetting) {
      fieldIsDone = true;
      timer.onStartTimer();
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _save() async {
    await widget.field.save(context.read<AppGlobals>().savesPath);

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("file-saved".i18n()),
        showCloseIcon: true,
      ),
    );
  }

  void _onCompleted(SudokuField f) {
    timer.onStopTimer();

    var stats = Provider.of<Stats>(context, listen: false);
    stats.addStatPiece(StatPiece.fromSudoku(f));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("solved".i18n()),
          content: Text("solved-congratulations".i18n()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateNextField();
              },
              child: Text("generate-field".i18n()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("go-back".i18n()),
            ),
          ],
        );
      },
    );
  }
}
