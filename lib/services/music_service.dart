import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAsset;
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> playMusic(String assetPath) async {
    if (_isMuted) return; // Don't play if muted
    if (_isPlaying && _currentAsset == assetPath) return;
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(assetPath));
    _isPlaying = true;
    _currentAsset = assetPath;
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _isPlaying = false;
    _currentAsset = null;
  }

  Future<void> pauseMusic() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resumeMusic() async {
    await _player.resume();
    _isPlaying = true;
  }

  Future<void> setMute(bool mute) async {
    _isMuted = mute;
    await _player.setVolume(mute ? 0.0 : 1.0);
  }
}
