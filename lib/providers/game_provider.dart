import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sudoku_cell.dart';
import '../models/game_state.dart';
import '../services/sudoku_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import 'settings_provider.dart';

/// Central game state manager.
/// Uses Provider (ChangeNotifier) for simplicity and scalability.
/// All game logic is delegated to SudokuService; this class owns UI state.
class GameProvider extends ChangeNotifier {
  final SettingsProvider _settings;
  final SudokuService _sudokuService = SudokuService();
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();

  // ── Board State ──────────────────────────────────────────────────────────
  late List<List<SudokuCell>> _cells; // 9×9 grid of cells
  late List<List<int>> _solution;     // Ground truth solution
  late List<List<int>> _originalPuzzle; // Immutable starting state

  // ── Selection ────────────────────────────────────────────────────────────
  int? _selectedRow;
  int? _selectedCol;

  // ── Game Status ──────────────────────────────────────────────────────────
  GameStatus _status = GameStatus.idle;
  Difficulty _difficulty = Difficulty.easy;
  int _mistakes = 0;
  int _maxMistakes = 3;
  int _moves = 0;
  int _score = 0;
  int _hintsUsed = 0;

  // ── Timer ────────────────────────────────────────────────────────────────
  Timer? _timer;
  int _elapsedSeconds = 0;

  // ── Undo/Redo ────────────────────────────────────────────────────────────
  final List<BoardSnapshot> _undoStack = [];
  final List<BoardSnapshot> _redoStack = [];

  // ── Completion ───────────────────────────────────────────────────────────
  bool _showCompletionDialog = false;
  int? _bestTime;

  // ─── Getters ─────────────────────────────────────────────────────────────
  List<List<SudokuCell>> get cells => _cells;
  GameStatus get status => _status;
  Difficulty get difficulty => _difficulty;
  int get mistakes => _mistakes;
  int get maxMistakes => _maxMistakes;
  int get moves => _moves;
  int get score => _score;
  int get hintsUsed => _hintsUsed;
  int get elapsedSeconds => _elapsedSeconds;
  bool get showCompletionDialog => _showCompletionDialog;
  int? get bestTime => _bestTime;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isPaused => _status == GameStatus.paused;
  bool get isPlaying => _status == GameStatus.playing;

  String get formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  GameProvider(this._settings) {
    _cells = _emptyGrid();
    _solution = List.generate(9, (_) => List.filled(9, 0));
    _originalPuzzle = List.generate(9, (_) => List.filled(9, 0));
    _tryLoadSavedGame();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GAME LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  /// Starts a new game with selected difficulty
  Future<void> newGame({Difficulty? difficulty}) async {
    _stopTimer();
    _difficulty = difficulty ?? _settings.difficulty;

    final (puzzle, solution) = _sudokuService.generatePuzzle(_difficulty);
    _solution = solution;
    _originalPuzzle = puzzle.map((r) => List<int>.from(r)).toList();

    // Build cell grid
    _cells = List.generate(9, (r) {
      return List.generate(9, (c) {
        return SudokuCell(
          value: puzzle[r][c],
          isFixed: puzzle[r][c] != 0,
        );
      });
    });

    // Reset state
    _selectedRow = null;
    _selectedCol = null;
    _mistakes = 0;
    _moves = 0;
    _score = 0;
    _hintsUsed = 0;
    _elapsedSeconds = 0;
    _undoStack.clear();
    _redoStack.clear();
    _showCompletionDialog = false;
    _bestTime = await _storageService.loadBestTime(_difficulty);

    _status = GameStatus.playing;
    _startTimer();
    await _storageService.clearGame();
    notifyListeners();
  }

  /// Resets the board to the original puzzle state
  void resetGame() {
    _stopTimer();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!_cells[r][c].isFixed) {
          _cells[r][c].value = 0;
          _cells[r][c].isError = false;
          _cells[r][c].noteValues = null;
        }
      }
    }
    _elapsedSeconds = 0;
    _mistakes = 0;
    _moves = 0;
    _score = 0;
    _undoStack.clear();
    _redoStack.clear();
    _selectedRow = null;
    _selectedCol = null;
    _status = GameStatus.playing;
    _startTimer();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SELECTION & INPUT
  // ─────────────────────────────────────────────────────────────────────────

  void selectCell(int row, int col) {
  // Do not allow selecting fixed cells
  if (_cells[row][col].isFixed) {
    return;
  }

  _selectedRow = row;
  _selectedCol = col;

  _updateHighlights();
  _audioService.playTap();

  notifyListeners();
}

  void inputNumber(int number) {
  if (_selectedRow == null || _selectedCol == null) {
    return;
  }

  if (_status != GameStatus.playing) {
    return;
  }

  final cell = _cells[_selectedRow!][_selectedCol!];

  // Prevent editing fixed cells
  if (cell.isFixed) {
    return;
  }

  _pushUndoSnapshot();

  // Notes mode
  if (_settings.notesMode) {
    cell.toggleNote(number);
    _moves++;
    notifyListeners();
    return;
  }

  // Clear notes
  cell.noteValues = null;

  // Set number
  cell.value = number;

  // Validation
  if (_settings.autoCheck &&
      number != _solution[_selectedRow!][_selectedCol!]) {
    cell.isError = true;
    _mistakes++;

    _audioService.playError();

    if (_mistakes >= _maxMistakes) {
      _endGame(won: false);
      return;
    }
  } else {
    cell.isError = false;

    _audioService.playSuccess();

    _score += _calculateScore();

    _clearNotesFor(_selectedRow!, _selectedCol!, number);
  }

  _moves++;

  _redoStack.clear();

  _checkCompletion();

  notifyListeners();
}

  void eraseCell() {
    if (_selectedRow == null || _selectedCol == null) return;
    final cell = _cells[_selectedRow!][_selectedCol!];
    if (cell.isFixed) return;
    _pushUndoSnapshot();
    cell.value = 0;
    cell.isError = false;
    cell.noteValues = null;
    _moves++;
    _redoStack.clear();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  UNDO / REDO
  // ─────────────────────────────────────────────────────────────────────────

  void undo() {
    if (_undoStack.isEmpty) return;
    _pushRedoSnapshot();
    final snap = _undoStack.removeLast();
    _applySnapshot(snap);
    _audioService.playUndo();
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _pushUndoSnapshot(skipClear: true);
    final snap = _redoStack.removeLast();
    _applySnapshot(snap);
    notifyListeners();
  }

  void _pushUndoSnapshot({bool skipClear = false}) {
    _undoStack.add(_currentSnapshot());
    if (_undoStack.length > 50) _undoStack.removeAt(0); // cap history
    if (!skipClear) _redoStack.clear();
  }

  void _pushRedoSnapshot() {
    _redoStack.add(_currentSnapshot());
    if (_redoStack.length > 50) _redoStack.removeAt(0);
  }

  BoardSnapshot _currentSnapshot() {
    return BoardSnapshot(
      values: List.generate(
          9, (r) => List.generate(9, (c) => _cells[r][c].value)),
      notes: List.generate(
          9, (r) => List.generate(9, (c) => _cells[r][c].noteValues)),
    );
  }

  void _applySnapshot(BoardSnapshot snap) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!_cells[r][c].isFixed) {
          _cells[r][c].value = snap.values[r][c];
          _cells[r][c].noteValues = snap.notes[r][c];
          // Re-validate errors
          final v = snap.values[r][c];
          _cells[r][c].isError =
              v != 0 && _settings.autoCheck && v != _solution[r][c];
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HINT & SOLVE
  // ─────────────────────────────────────────────────────────────────────────

  void useHint() {
    if (_status != GameStatus.playing) return;
    final boardValues = List.generate(
        9, (r) => List.generate(9, (c) => _cells[r][c].value));
    final hint = _sudokuService.getHint(boardValues, _solution);
    if (hint == null) return;

    final (row, col, value) = hint;
    _pushUndoSnapshot();
    _cells[row][col].value = value;
    _cells[row][col].isError = false;
    _cells[row][col].noteValues = null;
    _hintsUsed++;
    _score = (_score - 50).clamp(0, 999999);
    _selectAndHighlight(row, col);
    _checkCompletion();
    notifyListeners();
  }

  void solvePuzzle() {
    if (_status != GameStatus.playing) return;
    _stopTimer();
    // Fill all cells from solution
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        _cells[r][c].value = _solution[r][c];
        _cells[r][c].isError = false;
        _cells[r][c].noteValues = null;
      }
    }
    _status = GameStatus.completed;
    _showCompletionDialog = false; // auto-solve = no celebration
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TIMER
  // ─────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() => _timer?.cancel();

  void pauseResume() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      _stopTimer();
    } else if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      _startTimer();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  COMPLETION
  // ─────────────────────────────────────────────────────────────────────────

  void _checkCompletion() {
    final boardValues = List.generate(
        9, (r) => List.generate(9, (c) => _cells[r][c].value));
    // Check if all cells filled with no errors
    bool allFilled = true;
    bool hasErrors = false;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (boardValues[r][c] == 0) allFilled = false;
        if (_cells[r][c].isError) hasErrors = true;
      }
    }
    if (allFilled && !hasErrors) {
      _endGame(won: true);
    }
  }

  void _endGame({required bool won}) {
    _stopTimer();
    _status = GameStatus.completed;
    if (won) {
      _showCompletionDialog = true;
      _audioService.playComplete();
      _storageService.saveBestTime(_difficulty, _elapsedSeconds);
    }
    notifyListeners();
  }

  void dismissCompletionDialog() {
    _showCompletionDialog = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HIGHLIGHTING
  // ─────────────────────────────────────────────────────────────────────────

  void _updateHighlights() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        _cells[r][c].isSelected = (r == _selectedRow && c == _selectedCol);
        _cells[r][c].isHighlighted = _shouldHighlight(r, c);
      }
    }
  }

  bool _shouldHighlight(int row, int col) {
    if (_selectedRow == null || _selectedCol == null) return false;
    if (row == _selectedRow || col == _selectedCol) return true;
    // Same 3×3 box
    final boxR = (_selectedRow! ~/ 3) * 3;
    final boxC = (_selectedCol! ~/ 3) * 3;
    return row >= boxR && row < boxR + 3 && col >= boxC && col < boxC + 3;
  }

  void _selectAndHighlight(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    _updateHighlights();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  int _calculateScore() {
    // Time-based scoring: faster = higher score
    final timeBonus = (300 - _elapsedSeconds).clamp(0, 300);
    final diffBonus = _difficulty == Difficulty.easy
        ? 10
        : _difficulty == Difficulty.medium
            ? 20
            : 30;
    return diffBonus + timeBonus ~/ 10;
  }

  /// Removes pencil marks for [value] in the same row, col, and box as [row],[col]
  void _clearNotesFor(int row, int col, int value) {
    final boxR = (row ~/ 3) * 3;
    final boxC = (col ~/ 3) * 3;
    for (int i = 0; i < 9; i++) {
      _cells[row][i].noteValues = _cells[row][i].noteValues != null
          ? _cells[row][i].noteValues! & ~(1 << value)
          : null;
      _cells[i][col].noteValues = _cells[i][col].noteValues != null
          ? _cells[i][col].noteValues! & ~(1 << value)
          : null;
    }
    for (int r = boxR; r < boxR + 3; r++) {
      for (int c = boxC; c < boxC + 3; c++) {
        _cells[r][c].noteValues = _cells[r][c].noteValues != null
            ? _cells[r][c].noteValues! & ~(1 << value)
            : null;
      }
    }
  }

  List<List<SudokuCell>> _emptyGrid() {
    return List.generate(9, (_) => List.generate(9, (_) => SudokuCell()));
  }

  Future<void> _tryLoadSavedGame() async {
    try {
      final saved = await _storageService.loadGame();
      if (saved == null) return;

      final board = saved['board'] as List<List<int>>;
      _solution = saved['solution'] as List<List<int>>;
      final fixed = saved['fixed'] as List<List<bool>>;
      final notes = saved['notes'] as List<List<int?>>;
      _difficulty = Difficulty.values.firstWhere(
        (d) => d.name == saved['difficulty'],
        orElse: () => Difficulty.easy,
      );
      _elapsedSeconds = saved['elapsed'] as int;
      _moves = saved['moves'] as int;
      _score = saved['score'] as int;

      _cells = List.generate(9, (r) {
        return List.generate(9, (c) {
          return SudokuCell(
            value: board[r][c],
            isFixed: fixed[r][c],
            noteValues: notes[r][c],
          );
        });
      });

      _bestTime = await _storageService.loadBestTime(_difficulty);
      _status = GameStatus.playing;
      _startTimer();
      notifyListeners();
    } catch (_) {
      // Corrupt save — ignore
    }
  }

  Future<void> saveCurrentGame() async {
    if (_status == GameStatus.idle || _status == GameStatus.completed) return;
    final board =
        List.generate(9, (r) => List.generate(9, (c) => _cells[r][c].value));
    final fixed = List.generate(
        9, (r) => List.generate(9, (c) => _cells[r][c].isFixed));
    final notes = List.generate(
        9, (r) => List.generate(9, (c) => _cells[r][c].noteValues));
    await _storageService.saveGame(
      board: board,
      solution: _solution,
      fixed: fixed,
      notes: notes,
      difficulty: _difficulty,
      elapsedSeconds: _elapsedSeconds,
      moves: _moves,
      score: _score,
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _audioService.dispose();
    super.dispose();
  }
}
