import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';

/// Displays live game stats: timer, mistakes, moves, score.
class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.timer_outlined,
            label: 'Time',
            value: game.formattedTime,
            color: AppTheme.accent,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.favorite,
            label: 'Lives',
            value: '${game.maxMistakes - game.mistakes}/${game.maxMistakes}',
            color: AppTheme.error,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.touch_app_outlined,
            label: 'Moves',
            value: '${game.moves}',
            color: AppTheme.warning,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.star_outline,
            label: 'Score',
            value: '${game.score}',
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.subtextColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.borderColor,
    );
  }
}
