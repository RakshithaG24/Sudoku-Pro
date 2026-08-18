import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';

/// Full-screen completion overlay with confetti celebration.
class CompletionDialog extends StatefulWidget {
  final int elapsedSeconds;
  final int score;
  final Difficulty difficulty;
  final int moves;
  final VoidCallback onNewGame;

  const CompletionDialog({
    super.key,
    required this.elapsedSeconds,
    required this.score,
    required this.difficulty,
    required this.moves,
    required this.onNewGame,
  });

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4))
      ..play();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _anim.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = (widget.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (widget.elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _rating {
    if (widget.score > 400) return '★★★';
    if (widget.score > 200) return '★★☆';
    return '★☆☆';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti at top-center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  AppTheme.primary,
                  AppTheme.accent,
                  AppTheme.warning,
                  Colors.pink,
                  Colors.greenAccent,
                ],
                emissionFrequency: 0.08,
                numberOfParticles: 20,
                gravity: 0.2,
              ),
            ),

            // Dialog card
            ScaleTransition(
              scale: _scale,
              child: Container(
                margin: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy emoji
                      const Text('🏆',
                          style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),

                      Text(
                        'Puzzle Solved!',
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _rating,
                        style: const TextStyle(
                            fontSize: 28, letterSpacing: 4),
                      ),
                      const SizedBox(height: 24),

                      // Stats grid
                      Row(
                        children: [
                          _StatCard(
                              label: 'Time',
                              value: _formattedTime,
                              icon: Icons.timer,
                              color: AppTheme.accent),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Score',
                              value: '${widget.score}',
                              icon: Icons.star,
                              color: AppTheme.warning),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatCard(
                              label: 'Moves',
                              value: '${widget.moves}',
                              icon: Icons.touch_app,
                              color: AppTheme.primary),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Difficulty',
                              value: widget.difficulty.name,
                              icon: Icons.bar_chart,
                              color: Color(widget.difficulty.color)),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // New game button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onNewGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Play Again',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: context.textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text(label,
                    style: TextStyle(
                        color: context.subtextColor, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
