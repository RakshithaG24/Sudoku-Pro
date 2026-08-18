import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

/// Manages user preferences: difficulty, sound, notes mode.
class SettingsProvider extends ChangeNotifier {
  Difficulty _difficulty = Difficulty.easy;
  bool _soundEnabled = true;
  bool _notesMode = false;
  bool _showErrors = true;
  bool _autoCheck = true;

  Difficulty get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;
  bool get notesMode => _notesMode;
  bool get showErrors => _showErrors;
  bool get autoCheck => _autoCheck;

  SettingsProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _difficulty = Difficulty.values.firstWhere(
      (d) => d.name == prefs.getString('difficulty'),
      orElse: () => Difficulty.easy,
    );
    _soundEnabled = prefs.getBool('sound') ?? true;
    _showErrors = prefs.getBool('showErrors') ?? true;
    _autoCheck = prefs.getBool('autoCheck') ?? true;
    notifyListeners();
  }

  Future<void> setDifficulty(Difficulty d) async {
    _difficulty = d;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', d.name);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool v) async {
    _soundEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', v);
    notifyListeners();
  }

  void toggleNotesMode() {
    _notesMode = !_notesMode;
    notifyListeners();
  }

  Future<void> setShowErrors(bool v) async {
    _showErrors = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showErrors', v);
    notifyListeners();
  }

  Future<void> setAutoCheck(bool v) async {
    _autoCheck = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoCheck', v);
    notifyListeners();
  }
}
