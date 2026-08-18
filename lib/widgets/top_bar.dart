import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';
import '../screens/home_screen.dart';
import 'package:sudoku_game/widgets/difficulty_selector.dart';
/// App bar: logo, title, theme toggle, sound toggle, new game.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final game = context.watch<GameProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(color: context.borderColor),
        ),
      ),
      child: Row(
        children: [
          // Logo + title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sudoku',
                    style: TextStyle(
                      color: context.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Master',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Difficulty badge
          const SizedBox(width: 12),
          _DifficultyBadge(difficulty: game.difficulty),

          const Spacer(),

          // Action icons
          _IconBtn(
            icon: settings.soundEnabled
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
            onTap: () => settings.setSoundEnabled(!settings.soundEnabled),
            tooltip: 'Toggle Sound',
          ),
          _IconBtn(
            icon: theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: theme.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
          _NewGameButton(
            onTap: () => _showNewGameDialog(context),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DifficultyBottomSheet(
        onSelected: (d) {
          Navigator.pop(context);
          context.read<GameProvider>().newGame(difficulty: d);
        },
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = Color(difficulty.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        difficulty.name,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconBtn(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 22, color: context.subtextColor),
        onPressed: onTap,
      ),
    );
  }
}

class _NewGameButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewGameButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryLight],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          '+ New Game',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
