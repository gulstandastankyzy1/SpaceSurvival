# Space Survival

Space Survival is a polished, beginner-friendly Flutter mobile game created for
a college or school project fair. The player controls a spaceship, dodges
falling asteroids, collects energy crystals, and tries to survive as long as
possible.

## Features

- Animated intro screen with logo and smooth page transition
- Futuristic home menu with neon cards, gradient buttons, and press animations
- Drag/touch spaceship controls
- Falling asteroids and energy crystals
- Score over time plus crystal bonus points
- Three lives, collision detection, countdown, pause, restart, and game over UI
- Moving star background, particle bursts, and animated explosion effects
- Settings for sound, music, theme, and difficulty
- Generated background music and sound effects for tap, crystal, explosion, and game over
- Local top 5 leaderboard with `shared_preferences`
- Clear folders: `screens/`, `widgets/`, `models/`, `services/`, and `utils/`

## Project Structure

```text
lib/
  main.dart
  models/
    game_object.dart
    game_settings.dart
  screens/
    intro_screen.dart
    home_screen.dart
    game_screen.dart
    settings_screen.dart
    leaderboard_screen.dart
  services/
    storage_service.dart
  utils/
    app_colors.dart
    page_transitions.dart
  widgets/
    game_painters.dart
    neon_button.dart
    neon_card.dart
    space_logo.dart
    star_field.dart
assets/
  audio/
  images/
```

## How To Run

1. Install Flutter.
2. Open this folder in a terminal:

```bash
cd "game"
flutter pub get
flutter run
```

For browser testing:

```bash
flutter run -d chrome
```

## Important Code Ideas

- `GameScreen` contains the simple game loop. A Flutter `Ticker` runs every
  frame, calculates `dt`, moves objects, adds score, spawns new objects, and
  checks collisions.
- `GamePainter` draws the spaceship, asteroids, crystals, particles, and
  explosions. This keeps the game fast because many objects are painted on one
  canvas.
- Collision detection uses rectangles with `Rect.overlaps`, which is easy to
  explain in a presentation.
- `GameSettings` is a small `ChangeNotifier`. It stores sound, music, theme,
  and difficulty without needing advanced architecture.
- `StorageService` saves the leaderboard and settings locally using
  `shared_preferences`.
- `AudioService` plays background music and short sound effects. It checks the
  saved settings first, so the Settings toggles really control audio.

## Presentation Tip

Explain the game as four beginner-friendly steps:

1. The player drags the ship left or right.
2. The game loop moves asteroids and crystals downward.
3. The score increases over time and crystals add bonus points.
4. If an asteroid rectangle overlaps the ship rectangle, the player loses a life.
5. Sound effects are triggered at the same simple moments: tap a button, collect
   a crystal, hit an asteroid, or finish the game.
