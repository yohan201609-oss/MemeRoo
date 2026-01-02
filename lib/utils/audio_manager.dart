import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Inicializar y cargar preferencias
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
    _isSfxEnabled = prefs.getBool('sfx_enabled') ?? true;
    _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
    _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.7;

    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  // Música de fondo
  Future<void> playMusic(String filename) async {
    if (!_isMusicEnabled) return;
    
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource('music/$filename'));
    } catch (e) {
      // Silenciar errores si los archivos no existen aún
      // print('Error playing music: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_isMusicEnabled) {
      await _musicPlayer.resume();
    }
  }

  // Efectos de sonido
  Future<void> playSfx(String filename) async {
    if (!_isSfxEnabled) return;
    
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$filename'));
    } catch (e) {
      // Silenciar errores si los archivos no existen aún
      // print('Error playing sound: $e');
    }
  }

  // Sonidos específicos
  Future<void> playTap() => playSfx('tap.wav');
  Future<void> playSuccess() => playSfx('success.wav');
  Future<void> playError() => playSfx('error.wav');
  Future<void> playWin() => playSfx('win.wav');
  Future<void> playFlip() => playSfx('flip.wav');
  Future<void> playMatch() => playSfx('match.wav');

  // Toggle música
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', _isMusicEnabled);

    if (!_isMusicEnabled) {
      await stopMusic();
    } else {
      await playMusic('menu.wav');
    }
  }

  // Toggle efectos de sonido
  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', _isSfxEnabled);
  }

  // Ajustar volumen de música
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', _musicVolume);
  }

  // Ajustar volumen de efectos
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfx_volume', _sfxVolume);
  }

  // Limpiar recursos
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

