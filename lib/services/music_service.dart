import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAsset;

  Future<void> playMusic(String assetPath) async {
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
}
