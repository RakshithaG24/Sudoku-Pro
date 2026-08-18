import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../themes/app_theme.dart';

/// Row of game action buttons: Undo, Redo, Hint, Pause, Reset, Solve.
class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isPlaying = game.isPlaying || game.isPaused;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.undo,
          label: 'Undo',
          onTap: game.canUndo ? game.undo : null,
          color: AppTheme.primary,
        ),
        _ControlButton(
          icon: Icons.redo,
          label: 'Redo',
          onTap: game.canRedo ? game.redo : null,
          color: AppTheme.primary,
        ),
        _ControlButton(
          icon: Icons.lightbulb_outline,
          label: 'Hint',
          onTap: isPlaying && !game.isPaused ? game.useHint : null,
          color: AppTheme.warning,
        ),
        _ControlButton(
          icon: game.isPaused ? Icons.play_arrow : Icons.pause,
          label: game.isPaused ? 'Resume' : 'Pause',
          onTap: isPlaying ? game.pauseResume : null,
          color: AppTheme.accent,
        ),
        _ControlButton(
          icon: Icons.refresh,
          label: 'Reset',
          onTap: isPlaying
              ? () => _confirmReset(context, game)
              : null,
          color: AppTheme.warning,
        ),
        _ControlButton(
          icon: Icons.auto_fix_high,
          label: 'Solve',
          onTap: isPlaying && !game.isPaused
              ? () => _confirmSolve(context, game)
              : null,
          color: AppTheme.error,
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Reset Board?',
            style: TextStyle(color: context.textColor)),
        content: Text('All your progress will be lost.',
            style: TextStyle(color: context.subtextColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning),
            onPressed: () {
              Navigator.pop(context);
              game.resetGame();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmSolve(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardColor,
        title:
            Text('Solve Puzzle?', style: TextStyle(color: context.textColor)),
        content: Text('The board will be filled automatically.',
            style: TextStyle(color: context.subtextColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              game.solvePuzzle();
            },
            child: const Text('Solve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
