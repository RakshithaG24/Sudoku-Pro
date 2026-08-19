# Sudoku Flutter Web Game

A production-quality Sudoku game built with Flutter, playable in the browser via Flutter Web. Features multiple difficulty levels, local progress storage, animations, and sound effects.

## Tech Stack

- **Framework:** Flutter (Web target)
- **State Management:** Provider
- **Local Storage:** shared_preferences
- **Animations:** animate_do, confetti
- **Audio:** audioplayers
- **Fonts/Icons:** google_fonts, cupertino_icons

## Project Structure

```
lib/
  main.dart               # App entry point
  models/                 # Sudoku cell & game state models
  providers/               # Game, settings, and theme state (Provider)
  services/                # Sudoku generation/solving, storage, audio
  screens/                 # App screens (home_screen.dart)
  widgets/                 # UI components (board, number pad, controls, etc.)
  themes/                  # App theming
assets/
  images/
  sounds/
web/                        # Flutter web shell (index.html, manifest, icons)
```

## Running Locally

Prerequisites: [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel) with web support enabled.

```bash
flutter pub get
flutter config --enable-web
flutter run -d chrome
```

## Building for Web

```bash
flutter build web --release
```

This outputs static files to `build/web/`, which can be served by any static host.

---

