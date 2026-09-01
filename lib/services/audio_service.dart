import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../models/game_settings.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = List.generate(4, (_) => AudioPlayer());
  int _nextSfxPlayer = 0;
  bool _soundOn = true;
  bool _musicOn = true;

  Future<void> init(GameSettings settings) async {
    _soundOn = settings.soundOn;
    _musicOn = settings.musicOn;
    await _safe(() => _musicPlayer.setReleaseMode(ReleaseMode.loop));
    await _safe(() => _musicPlayer.setVolume(0.34));
    unawaited(startMusic());
  }

  Future<void> updateFromSettings(GameSettings settings) async {
    _soundOn = settings.soundOn;
    _musicOn = settings.musicOn;
    if (_musicOn) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  Future<void> startMusic() async {
    if (!_musicOn) {
      return;
    }
    await _safe(
      () =>
          _musicPlayer.play(AssetSource('audio/space_loop.wav'), volume: 0.34),
    );
  }

  Future<void> stopMusic() async {
    await _safe(_musicPlayer.stop);
  }

  Future<void> playTap() => _playSfx('audio/tap.wav', volume: 0.38);

  Future<void> playCrystal() => _playSfx('audio/crystal.wav', volume: 0.52);

  Future<void> playExplosion() => _playSfx('audio/explosion.wav', volume: 0.62);

  Future<void> playGameOver() => _playSfx('audio/game_over.wav', volume: 0.58);

  Future<void> _playSfx(String asset, {required double volume}) async {
    if (!_soundOn) {
      return;
    }

    // A tiny pool lets sounds overlap. For example, a crystal sound can play
    // right after an explosion without cutting it off.
    final player = _sfxPlayers[_nextSfxPlayer];
    _nextSfxPlayer = (_nextSfxPlayer + 1) % _sfxPlayers.length;
    await _safe(() => player.stop());
    await _safe(() => player.play(AssetSource(asset), volume: volume));
  }

  Future<void> dispose() async {
    await _safe(_musicPlayer.dispose);
    for (final player in _sfxPlayers) {
      await _safe(player.dispose);
    }
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Audio can be unavailable in some test or preview environments. The game
      // should keep running even if a device refuses to play a sound.
    }
  }
}
