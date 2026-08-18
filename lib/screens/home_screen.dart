import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../widgets/game_controls.dart';
import '../widgets/stats_bar.dart';
import '../widgets/completion_dialog.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/top_bar.dart';

/// Main game screen. Handles responsive layout for wide (desktop) and
/// narrow (mobile) viewports.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Auto-save when app goes to background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<GameProvider>().saveCurrentGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          // Background gradient
          _buildBackground(context),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                const TopBar(),

                Expanded(
                  child: isWide
                      ? _buildWideLayout(context, gameProvider)
                      : _buildNarrowLayout(context, gameProvider),
                ),
              ],
            ),
          ),

          // Completion dialog
          if (gameProvider.showCompletionDialog)
            CompletionDialog(
              elapsedSeconds: gameProvider.elapsedSeconds,
              score: gameProvider.score,
              difficulty: gameProvider.difficulty,
              moves: gameProvider.moves,
              onNewGame: () {
                gameProvider.dismissCompletionDialog();
                _showDifficultySelector(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.7, -0.5),
          radius: 1.2,
          colors: isDark
              ? [
                  const Color(0xFF1A1D2E),
                  const Color(0xFF0F1117),
                ]
              : [
                  const Color(0xFFEEEEFF),
                  const Color(0xFFF5F5F7),
                ],
        ),
      ),
    );
  }

  // ---------------- WIDE LAYOUT ----------------

  Widget _buildWideLayout(BuildContext context, GameProvider game) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel
            SizedBox(
              width: 240,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const StatsBar(),
                    const SizedBox(height: 16),
                    const GameControls(),
                    const SizedBox(height: 16),
                    DifficultySelector(
                      onSelected: (d) => game.newGame(difficulty: d),
                    ),
                  ],
                ),
              ),
            ),

            // Board Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SudokuBoard(),
                  const SizedBox(height: 20),
                  const NumberPad(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MOBILE LAYOUT ----------------

  Widget _buildNarrowLayout(BuildContext context, GameProvider game) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const StatsBar(),
            const SizedBox(height: 12),
            const SudokuBoard(),
            const SizedBox(height: 12),
            const NumberPad(),
            const SizedBox(height: 12),
            const GameControls(),
            const SizedBox(height: 12),
            DifficultySelector(
              onSelected: (d) => game.newGame(difficulty: d),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------- DIFFICULTY SELECTOR ----------------

  void _showDifficultySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DifficultySelector(
          onSelected: (d) {
            Navigator.pop(context);
            context.read<GameProvider>().newGame(difficulty: d);
          },
        );
      },
    );
  }
}