import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

/// Handles local persistence of game state using SharedPreferences (Web-compatible).
class StorageService {
  static const _keyBoard = 'sudoku_board';
  static const _keySolution = 'sudoku_solution';
  static const _keyFixed = 'sudoku_fixed';
  static const _keyNotes = 'sudoku_notes';
  static const _keyDifficulty = 'sudoku_difficulty';
  static const _keyElapsed = 'sudoku_elapsed';
  static const _keyMoves = 'sudoku_moves';
  static const _keyScore = 'sudoku_score';
  static const _keyBestTimes = 'sudoku_best_times';

  /// Save current game state
  Future<void> saveGame({
    required List<List<int>> board,
    required List<List<int>> solution,
    required List<List<bool>> fixed,
    required List<List<int?>> notes,
    required Difficulty difficulty,
    required int elapsedSeconds,
    required int moves,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBoard, jsonEncode(board));
    await prefs.setString(_keySolution, jsonEncode(solution));
    await prefs.setString(_keyFixed, jsonEncode(fixed));
    await prefs.setString(_keyNotes, jsonEncode(notes));
    await prefs.setString(_keyDifficulty, difficulty.name);
    await prefs.setInt(_keyElapsed, elapsedSeconds);
    await prefs.setInt(_keyMoves, moves);
    await prefs.setInt(_keyScore, score);
  }

  /// Load saved game state. Returns null if none exists.
  Future<Map<String, dynamic>?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final boardJson = prefs.getString(_keyBoard);
    if (boardJson == null) return null;

    return {
      'board': (jsonDecode(boardJson) as List)
          .map((row) => (row as List).map((v) => v as int).toList())
          .toList(),
      'solution': (jsonDecode(prefs.getString(_keySolution)!) as List)
          .map((row) => (row as List).map((v) => v as int).toList())
          .toList(),
      'fixed': (jsonDecode(prefs.getString(_keyFixed)!) as List)
          .map((row) => (row as List).map((v) => v as bool).toList())
          .toList(),
      'notes': (jsonDecode(prefs.getString(_keyNotes)!) as List)
          .map((row) => (row as List).map((v) => v as int?).toList())
          .toList(),
      'difficulty': prefs.getString(_keyDifficulty),
      'elapsed': prefs.getInt(_keyElapsed) ?? 0,
      'moves': prefs.getInt(_keyMoves) ?? 0,
      'score': prefs.getInt(_keyScore) ?? 0,
    };
  }

  /// Clear saved game
  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBoard);
    await prefs.remove(_keySolution);
    await prefs.remove(_keyFixed);
    await prefs.remove(_keyNotes);
    await prefs.remove(_keyElapsed);
    await prefs.remove(_keyMoves);
    await prefs.remove(_keyScore);
  }

  /// Save best time for a difficulty
  Future<void> saveBestTime(Difficulty difficulty, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getInt('${_keyBestTimes}_${difficulty.name}');
    if (existing == null || seconds < existing) {
      await prefs.setInt('${_keyBestTimes}_${difficulty.name}', seconds);
    }
  }

  /// Load best time for a difficulty
  Future<int?> loadBestTime(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_keyBestTimes}_${difficulty.name}');
  }
}

