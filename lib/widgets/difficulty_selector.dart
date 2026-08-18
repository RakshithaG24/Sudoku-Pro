import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';

/// Inline difficulty selector card used in wide layout.
class DifficultySelector extends StatelessWidget {
  final ValueChanged<Difficulty> onSelected;
  const DifficultySelector({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Difficulty',
              style: TextStyle(
                  color: context.subtextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          ...Difficulty.values.map(
            (d) => _DifficultyTile(difficulty: d, onTap: () => onSelected(d)),
          ),
        ],
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final Difficulty difficulty;
  final VoidCallback onTap;

  const _DifficultyTile({required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(difficulty.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                difficulty.name,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Text(
              '${81 - difficulty.cellsToRemove} given',
              style: TextStyle(color: color.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet difficulty picker shown on mobile / New Game
class DifficultyBottomSheet extends StatelessWidget {
  final ValueChanged<Difficulty> onSelected;
  const DifficultyBottomSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose Difficulty',
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          ...Difficulty.values.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BigDifficultyButton(
                  difficulty: d, onTap: () => onSelected(d)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BigDifficultyButton extends StatelessWidget {
  final Difficulty difficulty;
  final VoidCallback onTap;

  const _BigDifficultyButton(
      {required this.difficulty, required this.onTap});

  static const _descriptions = {
    Difficulty.easy: 'More givens, great for beginners',
    Difficulty.medium: 'Balanced challenge for casual players',
    Difficulty.hard: 'Few givens, requires deep logic',
  };

  @override
  Widget build(BuildContext context) {
    final color = Color(difficulty.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon(difficulty), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(difficulty.name,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text(_descriptions[difficulty]!,
                      style: TextStyle(
                          color: color.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  IconData _icon(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_alt;
      case Difficulty.medium:
        return Icons.psychology_outlined;
      case Difficulty.hard:
        return Icons.whatshot;
    }
  }
}
