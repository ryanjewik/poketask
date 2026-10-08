import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'music_service.dart';

/// Short UI sound effects. Uses its own [AudioPlayer] so it never interferes
/// with [MusicService]'s background track.
class SfxService {
  static final SfxService _instance = SfxService._internal();
  factory SfxService() => _instance;
  // Warm up on first access so the first chime plays without load latency.
  SfxService._internal() {
    unawaited(preload());
  }

  static const String _taskCompleteAsset = 'sounds/task_complete.wav';

  final AudioPlayer _player = AudioPlayer();
  Future<bool>? _ready;

  /// On Android a second player requests audio focus by default, which makes
  /// the music player pause. Requesting no focus lets the chime mix over the
  /// menu music. iOS only has a global (app-wide) audio session and players in
  /// the same app already mix, so the context is left untouched there.
  static final AudioContext _mixingContext = AudioContext(
    android: const AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
    ),
  );

  /// Configures the player and preloads the chime. Safe to call repeatedly;
  /// [playTaskComplete] calls it lazily if nobody did earlier.
  Future<bool> preload() => _ready ??= _init();

  Future<bool> _init() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _player.setAudioContext(_mixingContext);
      }
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(AssetSource(_taskCompleteAsset));
      return true;
    } catch (e) {
      debugPrint('SfxService: preload failed: $e');
      _ready = null; // allow a retry on the next play
      return false;
    }
  }

  /// Plays the task-complete chime. Never throws; skipped when muted.
  Future<void> playTaskComplete() async {
    try {
      if (MusicService().isMuted) return;
      if (!await preload()) return;
      // Rewind (ReleaseMode.stop keeps the prepared source) and play again.
      await _player.stop();
      await _player.resume();
    } catch (e) {
      debugPrint('SfxService: playTaskComplete failed: $e');
    }
  }
}
