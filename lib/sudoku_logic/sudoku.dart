import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/adapters.dart';
import 'package:sudoku/sudoku_logic/sudoku_info.dart';
import 'package:sudoku/sudoku_logic/pos.dart';
import 'package:sudoku/src/rust/api/sudoku.dart';

class SudokuField {
  final List<int> _clues;
  final List<List<int>> _pencilmarks;
  final List<bool> _isUserPlaced;
  Function(SudokuField)? onCompleted;
  bool pencilmarkMode = false;
	// In milliseconds
  int time;
  Pos _selected;
  File? _saveFile;
  bool _hasBeenModified = false;

  SudokuInfo info = SudokuInfo.empty();

  Box infoBox;

  int get difficulty => info.difficulty;
  String get difficultyString =>
      difficulty.toString() + (info.humanEngineSolved ? "" : "+");

  SudokuField(this.infoBox, {String? clues})
      : _pencilmarks = List.generate(81, (index) => List.empty(growable: true),
            growable: false),
        _clues = List.filled(81, 0, growable: false),
        _isUserPlaced = List.filled(81, true, growable: false),
        time = 0,
        _selected = Pos(-1, -1){
    if (clues != null) {
      _setClues(clues);
      _getPuzzleInfo();
    }
  }

  factory SudokuField.fromFile(File file, Box infoBox) {
    var field = SudokuField.fromJson(jsonDecode(file.readAsStringSync()), infoBox);
    field._saveFile = file;
    return field;
  }

  SudokuField.fromJson(Map<String, dynamic> json, this.infoBox)
      : _clues = List<int>.from(json["clues"], growable: false),
        _pencilmarks = List<List<int>>.generate(
            81, (index) => List<int>.from(json["pencilmarks"][index]),
            growable: false),
        _isUserPlaced = List<bool>.from(json["isUserPlaced"], growable: false),
        time = json["time"] as int,
        _selected = Pos.fromJson(json["selected"]) {
    _getPuzzleInfo();
  }

  SudokuField.generate(Box infoBox) : this(infoBox, clues: generateSudoku());

  get hasBeenModified => _hasBeenModified;

  bool get _isCompleted {
    String clues = cluesToString(nonUser: true, user: true);
    if (info.uniqueSolution != null) {
      return info.uniqueSolution == clues;
    } else {
      return !clues.contains("0");
    }
  }

  // TODO: getter for file
  FileStat? get saveFileStat => _saveFile?.statSync();
  String? get saveFileName =>
      _saveFile?.path.split(Platform.pathSeparator).last;

  Pos get selected => _selected;

  set selected(Pos pos) {
    if (_selected == pos) {
      _selected = Pos(-1, -1);
    } else {
      _selected = pos;
    }
  }

  String cluesToString({bool user = false, bool nonUser = true}) {
    String res = "";
    for (int i = 0; i < 81; i++) {
      if ((user && isUserPlaced(i)) || (nonUser && !isUserPlaced(i))) {
        res += _clues[i].toString();
      } else {
        res += "0";
      }
    }
    return res;
  }

  /// Make all clues and pencilmarks not user placed
  void fix() {
    for (int i = 0; i < 81; i++) {
      if (_clues[i] != 0) {
        _isUserPlaced[i] = false;
      }
    }
    _getPuzzleInfo();
  }

  String getClue(int index) {
    var res = _clues[index];

    if (res == 0) return "";

    return res.toString();
  }

  String getPencilmarks(int index) {
    String res = "";

    for (int i in _pencilmarks[index]) {
      res += "$i ";
    }
    res = res.trim();

    return res;
  }

  bool isRightPlaced(int index) {
    if (info.uniqueSolution == null ||
        !_isUserPlaced[index] ||
        _clues[index] == 0) {
      return true;
    }
    return _clues[index] == int.tryParse(info.uniqueSolution![index]);
  }

  bool isUserPlaced(int index) => _isUserPlaced[index];

	/// Call deleteFromDB when deleting saved file.
  Future<void> save(String savePath, {File? file}) async {
    if (file != null) _saveFile = file;

    _saveFile ??= File(
      // ignore: prefer_interpolation_to_compose_strings
      savePath +
          Platform.pathSeparator +
          DateTime.now().microsecondsSinceEpoch.toString(),
    );

    if (!await _saveFile!.exists()) {
      await _saveFile!.create(recursive: true);
    }

    await _saveFile!.writeAsString(jsonEncode(this));

    final clues = cluesToString(nonUser: true, user: false);

		if (infoBox.get(clues) == null){
			await infoBox.put(clues, info);
		}

    _hasBeenModified = false;
  }

  void toggleNumber(int number) {
    _hasBeenModified = true;
    if (!_selected.isValidIndex()) return;

    int index = _selected.toIndex();

    if (!pencilmarkMode) {
      _toggleClue(index, number);
    } else {
      _togglePencilmark(index, number);
    }

    if (_isCompleted && onCompleted != null) onCompleted!(this);
  }

  Map<String, dynamic> toJson() => {
        "clues": _clues,
        "pencilmarks": _pencilmarks,
        "isUserPlaced": _isUserPlaced,
        "time": time,
        "selected": _selected,
      };

  void _getPuzzleInfo() {
    final clues = cluesToString(nonUser: true, user: false);

    info = infoBox.get(clues) ?? SudokuInfo.fromSudoku(clues);

    SudokuInfo? dbInfo = infoBox.get(clues);
    if (dbInfo == null) {
      info = SudokuInfo.fromSudoku(clues);
    } else {
      info = dbInfo;
    }
  }

  void _setClues(String clues) {
    for (var i = 0; i < 81; i++) {
      int clue = int.tryParse(clues[i]) ?? 0;

      _clues[i] = clue;
      _isUserPlaced[i] = clue == 0;
    }
  }

  void _toggleClue(int index, int clue) {
    if (_isUserPlaced[index]) {
      if (_clues[index] == clue) {
        _clues[index] = 0;
      } else {
        _clues[index] = clue;
      }
    }
  }

  void _togglePencilmark(int index, int pencilmark) {
    if (_isUserPlaced[index]) {
      if (_pencilmarks[index].contains(pencilmark)) {
        _pencilmarks[index].remove(pencilmark);
      } else {
        _pencilmarks[index].add(pencilmark);
      }

      _pencilmarks[index].sort();
    }
  }

	/// Call this function before deleting saved file.
	static Future<void> deleteFromDB(File file, Box infoBox) async {
    var field = SudokuField.fromFile(file, infoBox);
    final clues = field.cluesToString(nonUser: true, user: false);
		await field.infoBox.delete(clues);

		// TODO: Replace with something better
		// Why I think it is okay to do that:
		// Let's imagine that user has maybe 100 saved Sudoku
		// I do not think that this would really slow down his workflow (but I'm not sure)
		// But, this will reduce memory used by application
		// If you have any other strategy to remove deleted cache from disk, please share!
		field.infoBox.compact();
	}
}

extension IsValidClues on String {
  bool isValidClues() {
    return length == 81;
  }
}
