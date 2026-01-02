import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dot_model.dart';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';

enum DotsGameState { playing, won }

class DotsProvider extends ChangeNotifier {
  bool _isDisposed = false;
  List<Dot> _dots = [];
  int _currentDotIndex = 0;
  String _currentAnimal = '🐶';
  String _currentLevel = 'easy';
  DotsGameState _gameState = DotsGameState.playing;
  int _totalDots = 10;
  int _seconds = 0;
  Timer? _timer;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<Dot> get dots => _dots;
  int get currentDotIndex => _currentDotIndex;
  String get currentAnimal => _currentAnimal;
  String get currentLevel => _currentLevel;
  DotsGameState get gameState => _gameState;
  int get totalDots => _totalDots;
  int get seconds => _seconds;
  int get nextDotNumber => _currentDotIndex + 1;

  // Obtener estrellas guardadas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('dots_stars_$level') ?? 0;
  }

  // Guardar estrellas
  Future<void> _saveBestStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(_currentLevel);
    if (stars > currentBest) {
      await prefs.setInt('dots_stars_$_currentLevel', stars);
    }
  }

  // Obtener mejor tiempo
  Future<int> getBestTime(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('dots_time_$level') ?? 999;
  }

  // Guardar mejor tiempo
  Future<void> _saveBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestTime(_currentLevel);
    if (_seconds < currentBest) {
      await prefs.setInt('dots_time_$_currentLevel', _seconds);
    }
  }

  void initializeGame(String level) {
    _currentLevel = level;
    _currentDotIndex = 0;
    _seconds = 0;
    _gameState = DotsGameState.playing;
    _timer?.cancel();
    _dots.clear();

    // Configurar según nivel
    switch (level) {
      case 'easy':
        _totalDots = 10;
        break;
      case 'medium':
        _totalDots = 15;
        break;
      case 'hard':
        _totalDots = 20;
        break;
    }

    // Seleccionar animal aleatorio
    final random = Random();
    final allAnimals = [...GameConstants.easyAnimals];
    _currentAnimal = allAnimals[random.nextInt(allAnimals.length)];

    _generateDots();
    _startTimer();
    notifyListeners();
  }

  void _generateDots() {
    _dots.clear();
    final random = Random();

    // Generar puntos que forman un patrón circular (simulando un animal)
    for (int i = 0; i < _totalDots; i++) {
      final angle = (2 * pi * i) / _totalDots;
      final radius = 0.3 + (random.nextDouble() * 0.1); // Radio variable
      
      // Convertir coordenadas polares a cartesianas
      final x = 0.5 + (radius * cos(angle));
      final y = 0.5 + (radius * sin(angle));

      _dots.add(Dot(
        number: i + 1,
        position: Offset(x, y),
      ));
    }
  }

  void onDotTapped(int dotNumber) {
    if (_gameState != DotsGameState.playing) return;

    // Buscar el punto
    final dotIndex = _dots.indexWhere((dot) => dot.number == dotNumber);
    if (dotIndex == -1) return;

    // Verificar si ya está conectado
    if (_dots[dotIndex].isConnected) return;

    // Verificar si es el dot correcto (siguiente en secuencia)
    if (dotNumber == nextDotNumber) {
      AudioManager().playSuccess();
      _dots[dotIndex] = _dots[dotIndex].copyWith(
        isConnected: true,
      );
      _currentDotIndex++;

      // Verificar victoria
      if (_currentDotIndex >= _totalDots) {
        _gameState = DotsGameState.won;
        _timer?.cancel();
        AudioManager().playWin();
        _calculateAndSaveStars();
        _saveBestTime();
      }

      notifyListeners();
    } else {
      AudioManager().playError();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == DotsGameState.playing) {
        _seconds++;
        notifyListeners();
      }
    });
  }

  void _calculateAndSaveStars() {
    int stars = 1;

    switch (_currentLevel) {
      case 'easy':
        if (_seconds <= 30) {
          stars = 3;
        } else if (_seconds <= 45) {
          stars = 2;
        }
        break;
      case 'medium':
        if (_seconds <= 45) {
          stars = 3;
        } else if (_seconds <= 70) {
          stars = 2;
        }
        break;
      case 'hard':
        if (_seconds <= 60) {
          stars = 3;
        } else if (_seconds <= 90) {
          stars = 2;
        }
        break;
    }

    _saveBestStars(stars);
  }

  int getStars() {
    if (_gameState != DotsGameState.won) return 0;

    int stars = 1;

    switch (_currentLevel) {
      case 'easy':
        if (_seconds <= 30) stars = 3;
        else if (_seconds <= 45) stars = 2;
        break;
      case 'medium':
        if (_seconds <= 45) stars = 3;
        else if (_seconds <= 70) stars = 2;
        break;
      case 'hard':
        if (_seconds <= 60) stars = 3;
        else if (_seconds <= 90) stars = 2;
        break;
    }

    return stars;
  }

  void resetGame() {
    initializeGame(_currentLevel);
  }

  String getFormattedTime() {
    final minutes = _seconds ~/ 60;
    final secs = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

