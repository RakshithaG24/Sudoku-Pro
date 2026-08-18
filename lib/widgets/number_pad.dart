import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../themes/app_theme.dart';

/// 1–9 number pad + erase button + notes toggle.
class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();

    return Column(
      children: [
        // Notes mode toggle
        GestureDetector(
          onTap: settings.toggleNotesMode,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: settings.notesMode
                  ? AppTheme.accent.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: settings.notesMode
                    ? AppTheme.accent
                    : context.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_note,
                  size: 18,
                  color: settings.notesMode
                      ? AppTheme.accent
                      : context.subtextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Notes',
                  style: TextStyle(
                    color: settings.notesMode
                        ? AppTheme.accent
                        : context.subtextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (settings.notesMode) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Number buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(9, (i) {
              final num = i + 1;
              return _NumberButton(
                number: num,
                onTap: () => game.inputNumber(num),
                isNotesMode: settings.notesMode,
              );
            }),
            const SizedBox(width: 8),
            _EraseButton(onTap: game.eraseCell),
          ],
        ),
      ],
    );
  }
}

class _NumberButton extends StatefulWidget {
  final int number;
  final VoidCallback onTap;
  final bool isNotesMode;

  const _NumberButton({
    required this.number,
    required this.onTap,
    required this.isNotesMode,
  });

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: 36,
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.isNotesMode
                ? AppTheme.accent.withOpacity(0.1)
                : AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isNotesMode
                  ? AppTheme.accent.withOpacity(0.4)
                  : AppTheme.primary.withOpacity(0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.number.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.isNotesMode ? AppTheme.accent : AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EraseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EraseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined,
            size: 18, color: AppTheme.error),
      ),
    );
  }
}
