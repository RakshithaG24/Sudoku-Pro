import 'dart:math';
import '../models/game_state.dart';

/// Core Sudoku logic: generation, solving, and validation.
/// Uses backtracking algorithm for both solving and generation.
class SudokuService {
  final Random _random = Random();

  // ─────────────────────────────────────────────
  //  PUBLIC API
  // ─────────────────────────────────────────────

  /// Generates a new puzzle. Returns [puzzle, solution] pair.
  /// Both are 9x9 grids where 0 = empty.
  (List<List<int>>, List<List<int>>) generatePuzzle(Difficulty difficulty) {
    // 1. Build a solved board
    final solution = _createEmptyGrid();
    _fillGrid(solution);

    // 2. Copy solution
    final puzzle = _copyGrid(solution);

    // 3. Remove cells to create puzzle
    _removeCells(puzzle, difficulty.cellsToRemove);

    return (puzzle, solution);
  }

  /// Solves the given board in-place. Returns true if solvable.
  bool solve(List<List<int>> board) {
    return _backtrack(board);
  }

  /// Validates a completed board is correct.
  bool isValidBoard(List<List<int>> board) {
    for (int i = 0; i < 9; i++) {
      if (!_isValidGroup(_getRow(board, i))) return false;
      if (!_isValidGroup(_getCol(board, i))) return false;
      if (!_isValidGroup(_getBox(board, (i ~/ 3) * 3, (i % 3) * 3))) {
        return false;
      }
    }
    return true;
  }

  /// Checks if placing [value] at [row],[col] violates Sudoku rules.
  bool isValidPlacement(List<List<int>> board, int row, int col, int value) {
    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && board[row][c] == value) return false;
    }
    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != row && board[r][col] == value) return false;
    }
    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == value) return false;
      }
    }
    return true;
  }

  /// Returns a hint: the row, col, and value for one empty cell.
  /// Returns null if board is already complete.
  (int, int, int)? getHint(
      List<List<int>> board, List<List<int>> solution) {
    final empties = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) empties.add((r, c));
      }
    }
    if (empties.isEmpty) return null;
    empties.shuffle(_random);
    final (r, c) = empties.first;
    return (r, c, solution[r][c]);
  }

  /// Counts how many cells are incorrect (non-zero and != solution)
  int countErrors(List<List<int>> board, List<List<int>> solution) {
    int errors = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != 0 && board[r][c] != solution[r][c]) errors++;
      }
    }
    return errors;
  }

  // ─────────────────────────────────────────────
  //  PRIVATE HELPERS
  // ─────────────────────────────────────────────

  List<List<int>> _createEmptyGrid() =>
      List.generate(9, (_) => List.filled(9, 0));

  List<List<int>> _copyGrid(List<List<int>> grid) =>
      grid.map((row) => List<int>.from(row)).toList();

  /// Fills the grid with a valid Sudoku solution using backtracking + randomisation
  bool _fillGrid(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (final num in nums) {
            if (isValidPlacement(grid, r, c, num)) {
              grid[r][c] = num;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false; // trigger backtrack
        }
      }
    }
    return true; // all cells filled
  }

  /// Backtracking solver (non-randomised, for solving puzzles)
  bool _backtrack(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (_backtrack(board)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Removes [count] cells from the grid while keeping a unique solution
  void _removeCells(List<List<int>> grid, int count) {
    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(_random);

    int removed = 0;
    for (final (r, c) in positions) {
      if (removed >= count) break;
      final backup = grid[r][c];
      grid[r][c] = 0;

      // Verify puzzle still has unique solution
      final testGrid = _copyGrid(grid);
      if (_countSolutions(testGrid) == 1) {
        removed++;
      } else {
        grid[r][c] = backup; // revert
      }
    }
  }

  /// Counts number of solutions (stops at 2 for efficiency)
  int _countSolutions(List<List<int>> board, {int limit = 2}) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          int count = 0;
          for (int num = 1; num <= 9; num++) {
            if (isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              count += _countSolutions(board, limit: limit);
              board[r][c] = 0;
              if (count >= limit) return count;
            }
          }
          return count;
        }
      }
    }
    return 1; // solved
  }

  // ─── Validation helpers ───

  List<int> _getRow(List<List<int>> b, int row) => b[row];
  List<int> _getCol(List<List<int>> b, int col) =>
      List.generate(9, (r) => b[r][col]);
  List<int> _getBox(List<List<int>> b, int startRow, int startCol) {
    final box = <int>[];
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        box.add(b[r][c]);
      }
    }
    return box;
  }

  bool _isValidGroup(List<int> group) {
    final nonZero = group.where((v) => v != 0).toList();
    return nonZero.toSet().length == nonZero.length &&
        nonZero.every((v) => v >= 1 && v <= 9);
  }
}
