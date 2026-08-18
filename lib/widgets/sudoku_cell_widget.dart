import 'package:flutter/material.dart';
import '../models/sudoku_cell.dart';
import '../themes/app_theme.dart';

/// Renders a single Sudoku cell with all its visual states.
class SudokuCellWidget extends StatelessWidget {
  final SudokuCell cell;
  final int row;
  final int col;
  final bool sameValue;
  final VoidCallback onTap;

  const SudokuCellWidget({
    super.key,
    required this.cell,
    required this.row,
    required this.col,
    required this.sameValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = _backgroundColor(isDark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bg,
        ),
        child: cell.value != 0
            ? _buildValue(context, isDark)
            : _buildNotes(context, isDark),
      ),
    );
  }

  Color _backgroundColor(bool isDark) {
    if (cell.isSelected) {
      return AppTheme.primary.withOpacity(isDark ? 0.5 : 0.35);
    }
    if (cell.isError && !cell.isFixed) {
      return AppTheme.error.withOpacity(0.25);
    }
    if (sameValue) {
      return AppTheme.primary.withOpacity(isDark ? 0.25 : 0.18);
    }
    if (cell.isHighlighted) {
      return isDark
          ? AppTheme.darkCard.withOpacity(0.8)
          : AppTheme.primary.withOpacity(0.07);
    }
    return isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
  }

  Widget _buildValue(BuildContext context, bool isDark) {
    Color textColor;
    if (cell.isError) {
      textColor = AppTheme.error;
    } else if (cell.isFixed) {
      textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    } else {
      textColor = AppTheme.primary;
    }

    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: cell.isFixed ? FontWeight.w700 : FontWeight.w500,
        ),
        child: Text(cell.value.toString()),
      ),
    );
  }

  /// Renders pencil notes as a 3×3 mini-grid inside the cell
  Widget _buildNotes(BuildContext context, bool isDark) {
    final noteColor =
        (isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext).withOpacity(0.7);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (_, i) {
        final num = i + 1;
        final hasNote = cell.hasNote(num);
        return Center(
          child: Text(
            hasNote ? num.toString() : '',
            style: TextStyle(
              fontSize: 8,
              color: noteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
