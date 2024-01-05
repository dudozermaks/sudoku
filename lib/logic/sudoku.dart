import 'dart:convert';
import 'dart:io';

import 'package:sudoku/tools/pos.dart';
import 'package:sudoku/src/rust/api/sudoku.dart';

class SudokuField {
  // TODO: add isCompleted
  final List<int> _clues;
  final List<List<int>> _pencilmarks;
  final List<bool> _isUserPlaced;
  Function(SudokuField)? onCompleted;
  bool pencilmarkMode = false;
  int time;
  Pos _selected;
  File? _saveFile;
  bool _hasBeenModified = false;

  String? _uniqueSolution;
	bool _isRatingComplete = false;
  int _difficulty = 0;

	String get difficultyString => difficulty.toString() + (_isRatingComplete ? "" : "+");

  SudokuField({String? clues})
      : _pencilmarks = List.generate(81, (index) => List.empty(growable: true),
            growable: false),
        _clues = List.filled(81, 0, growable: false),
        _isUserPlaced = List.filled(81, true, growable: false),
        time = 0,
        _selected = Pos(-1, -1) {
    if (clues != null) {
      _setClues(clues);
      _getPuzzleInfo();
    }
  }

  factory SudokuField.fromFile(File file) {
    var field = SudokuField.fromJson(jsonDecode(file.readAsStringSync()));
    field._saveFile = file;
    return field;
  }

  SudokuField.fromJson(Map<String, dynamic> json)
      : _clues = List<int>.from(json["clues"], growable: false),
        _pencilmarks = List<List<int>>.generate(
            81, (index) => List<int>.from(json["pencilmarks"][index]),
            growable: false),
        _isUserPlaced = List<bool>.from(json["isUserPlaced"], growable: false),
        time = json["time"] as int,
        _selected = Pos.fromJson(json["selected"]),
				_isRatingComplete = json["isRatingComplete"] as bool,
        _difficulty = json["rating"] as int,
        _uniqueSolution = json["uniqueSolution"] as String {
    if (_uniqueSolution == "") {
      _uniqueSolution = null;
    }
  }

  SudokuField.generate() : this(clues: generateSudoku());

  get hasBeenModified => _hasBeenModified;

  bool get _isCompleted {
    String clues = cluesToString(nonUser: true, user: true);
    if (_uniqueSolution != null) {
      return _uniqueSolution == clues;
    } else {
      return !clues.contains("0");
    }
  }

  int get difficulty => _difficulty;

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
    if (_uniqueSolution == null ||
        !_isUserPlaced[index] ||
        _clues[index] == 0) {
      return true;
    }
    return _clues[index] == int.tryParse(_uniqueSolution![index]);
  }

  bool isUserPlaced(int index) => _isUserPlaced[index];

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
        "rating": _difficulty,
        "isRatingComplete": _isRatingComplete,
        "uniqueSolution": _uniqueSolution ?? "",
      };

  void _getPuzzleInfo() {
    final puzzleClues = cluesToString(nonUser: true, user: false);

    _uniqueSolution = uniqueSolution(sudokuString: puzzleClues);

    if (_uniqueSolution != null) {
			(int, bool) rating = getRating(sudokuString: puzzleClues);
      _difficulty = rating.$1;
			_isRatingComplete  = rating.$2;
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
}

extension IsValidClues on String {
  bool isValidClues() {
    return length == 81;
  }
}
