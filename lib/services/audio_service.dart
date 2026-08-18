import 'package:audioplayers/audioplayers.dart';

/// Manages sound effects for the Sudoku game.
/// Uses audioplayers package which is Flutter Web compatible.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  Future<void> playTap() async {
    if (!_enabled) return;
    // Uses a simple tone asset; replace with real .mp3 files in assets/sounds/
    await _safePlay('tap.mp3');
  }

  Future<void> playSuccess() async {
    if (!_enabled) return;
    await _safePlay('success.mp3');
  }

  Future<void> playError() async {
    if (!_enabled) return;
    await _safePlay('error.mp3');
  }

  Future<void> playComplete() async {
    if (!_enabled) return;
    await _safePlay('complete.mp3');
  }

  Future<void> playUndo() async {
    if (!_enabled) return;
    await _safePlay('undo.mp3');
  }

  Future<void> _safePlay(String asset) async {
    try {
      // Silently fail if asset not found (placeholder for real sounds)
      await _player.play(AssetSource('sounds/$asset'));
    } catch (_) {
      // Sound file not present — game continues without audio
    }
  }

  void dispose() {
    _player.dispose();
  }
}
