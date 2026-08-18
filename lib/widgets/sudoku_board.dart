import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';
import 'sudoku_cell_widget.dart';

/// Renders the 9×9 Sudoku grid with thick borders on 3×3 sections.
/// Handles keyboard input and tap selection.
class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Board is square; use smaller of width/height
        final screenWidth = MediaQuery.of(context).size.width;

      final size = screenWidth > 900
        ? 650.0
        : screenWidth > 600
          ? 500.0
          : screenWidth * 0.92;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: _buildBoard(context, game, size),
          ),
        );
      },
    );
  }

  Widget _buildBoard(BuildContext context, GameProvider game, double size) {
    final cellSize = size / 9;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Cells grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final cell = game.cells[row][col];
                return GestureDetector(
                  onTap: () {
                    game.selectCell(row, col);
                },
                child: SudokuCellWidget(
                  cell: cell,
                  row: row,
                  col: col,
                  sameValue: _isSameValue(game, row, col),
                  onTap: () => game.selectCell(row, col),
                ),
              );
              },
            ),

            // Thick borders for 3×3 boxes (drawn as overlay lines)
            IgnorePointer(
              child: CustomPaint(
                size: Size(size, size),
                painter: _GridPainter(
                  isDark: context.isDark,
                  cellSize: cellSize,
                ),
              ),
            ),
            // Pause overlay
            if (game.isPaused)
              _PauseOverlay(size: size),
          ],
        ),
      ),
    );
  }

  /// Returns true if cell at (row,col) has same non-zero value as selected cell
  bool _isSameValue(GameProvider game, int row, int col) {
    if (game.selectedRow == null || game.selectedCol == null) return false;
    final selVal = game.cells[game.selectedRow!][game.selectedCol!].value;
    if (selVal == 0) return false;
    return game.cells[row][col].value == selVal &&
        !(row == game.selectedRow && col == game.selectedCol);
  }
}

/// Custom painter for drawing Sudoku grid lines with thick 3×3 borders
class _GridPainter extends CustomPainter {
  final bool isDark;
  final double cellSize;

  _GridPainter({required this.isDark, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
          .withOpacity(0.6)
      ..strokeWidth = 0.5;

    final thickPaint = Paint()
      ..color = isDark ? AppTheme.primary.withOpacity(0.5) : AppTheme.primary.withOpacity(0.4)
      ..strokeWidth = 2.0;

    // Draw thin lines
    for (int i = 1; i < 9; i++) {
      if (i % 3 == 0) continue; // skip thick lines
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thinPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thinPaint);
    }

    // Draw thick box borders
    for (int i = 3; i < 9; i += 3) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), thickPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), thickPaint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.isDark != isDark || old.cellSize != cellSize;
}

class _PauseOverlay extends StatelessWidget {
  final double size;
  const _PauseOverlay({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle_filled,
              size: 64, color: Colors.white.withOpacity(0.8)),
          const SizedBox(height: 12),
          Text(
            'PAUSED',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap ▶ to continue',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
