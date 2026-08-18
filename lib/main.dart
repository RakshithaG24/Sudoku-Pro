import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ThemeProvider: manages dark/light mode
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // SettingsProvider: manages sound, difficulty, etc.
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // GameProvider: central game state — depends on settings
        ChangeNotifierProxyProvider<SettingsProvider, GameProvider>(
          create: (ctx) => GameProvider(ctx.read<SettingsProvider>()),
          update: (ctx, settings, previous) =>
              previous ?? GameProvider(settings),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Sudoku Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
