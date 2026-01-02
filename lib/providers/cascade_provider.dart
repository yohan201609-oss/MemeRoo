import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/falling_animal_model.dart';
import '../utils/constants.dart';
import '../utils/colors.dart';

enum CascadeGameState { playing, won, lost }

class CascadeProvider extends ChangeNotifier {
  List<FallingAnimal> _animals = [];
  int _score = 0;
  int _targetScore = 100;
  String _currentLevel = 'easy';
  CascadeGameState _gameState = CascadeGameState.playing;
  Timer? _spawnTimer;
  double _gameAreaWidth = 0;
  double _gameAreaHeight = 0;
  FallingAnimal? _draggedAnimal;
  int _comboMultiplier = 1;
  double _spawnInterval = 2.0; // segundos
  List<String> _availableAnimals = [];
  int _movesLeft = 20;
  int _timeLeft = 60;
  Timer? _gameTimer;

  List<FallingAnimal> get animals => _animals;
  int get score => _score;
  int get targetScore => _targetScore;
  String get currentLevel => _currentLevel;
  CascadeGameState get gameState => _gameState;
  FallingAnimal? get draggedAnimal => _draggedAnimal;
  int get movesLeft => _movesLeft;
  int get timeLeft => _timeLeft;

  // Obtener mejor puntuación de estrellas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cascade_stars_$level') ?? 0;
  }

  // Guardar mejor puntuación de estrellas
  Future<void> _saveBestStars(String level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(level);
    if (stars > currentBest) {
      await prefs.setInt('cascade_stars_$level', stars);
    }
  }

  void initializeGame(String level) {
    _currentLevel = level;
    _animals.clear();
    _score = 0;
    _gameState = CascadeGameState.playing;
    _draggedAnimal = null;
    _comboMultiplier = 1;
    _spawnTimer?.cancel();
    _gameTimer?.cancel();

    switch (level) {
      case 'easy':
        _targetScore = 100;
        _spawnInterval = 3.5;
        _movesLeft = 20;
        _timeLeft = 60;
        _availableAnimals = GameConstants.easyAnimals.take(4).toList();
        break;
      case 'medium':
        _targetScore = 200;
        _spawnInterval = 3.0;
        _movesLeft = 25;
        _timeLeft = 90;
        _availableAnimals = GameConstants.mediumAnimals.take(6).toList();
        break;
      case 'hard':
        _targetScore = 300;
        _spawnInterval = 2.5;
        _movesLeft = 30;
        _timeLeft = 120;
        _availableAnimals = GameConstants.hardAnimals.take(8).toList();
        break;
    }

    _startGame();
    notifyListeners();
  }

  void setGameAreaSize(double width, double height) {
    _gameAreaWidth = width;
    _gameAreaHeight = height;
  }

  void _startGame() {
    // Spawn inicial de 8 animales
    for (int i = 0; i < 8; i++) {
      _spawnAnimal();
    }
    
    // Timer de spawn cada 3 segundos
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: (_spawnInterval * 1000).round()),
      (timer) {
        if (_gameState != CascadeGameState.playing) {
          timer.cancel();
          return;
        }
        // Solo spawn si hay menos de 12 animales
        if (_animals.length < 12) {
          _spawnAnimal();
        }
      },
    );
    
    // Iniciar timer de juego
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState != CascadeGameState.playing) {
        timer.cancel();
        return;
      }
      
      _timeLeft--;
      
      if (_timeLeft <= 0) {
        _gameState = CascadeGameState.lost;
        _gameTimer?.cancel();
        _spawnTimer?.cancel();
      }
      
      notifyListeners();
    });
  }

  void _spawnAnimal() {
    final random = Random();
    final emoji = _availableAnimals[random.nextInt(_availableAnimals.length)];
    final color = AppColors.cardColors[random.nextInt(AppColors.cardColors.length)];
    
    // Posiciones fijas en grid invisible
    final gridX = (random.nextInt(4) * 0.25) + 0.125; // 0.125, 0.375, 0.625, 0.875
    final gridY = (random.nextInt(6) * 0.15) + 0.15;  // Distribuido en altura
    
    _animals.add(FallingAnimal(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
      emoji: emoji,
      color: color,
      x: gridX,
      y: gridY,
    ));
    
    notifyListeners();
  }

  double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }

  void _checkMatches() {
    final matchedGroups = <List<FallingAnimal>>[];

    for (int i = 0; i < _animals.length; i++) {
      if (_animals[i].isMatched) continue;

      final group = <FallingAnimal>[_animals[i]];
      final emoji = _animals[i].emoji;

      for (int j = i + 1; j < _animals.length; j++) {
        if (_animals[j].isMatched) continue;
        if (_animals[j].emoji != emoji) continue;

        final distance = _calculateDistance(
          _animals[i].x,
          _animals[i].y,
          _animals[j].x,
          _animals[j].y,
        );

        if (distance < 0.15) {
          group.add(_animals[j]);
        }
      }

      if (group.length >= 2) {
        matchedGroups.add(group);
      }
    }

    // Procesar matches
    for (final group in matchedGroups) {
      if (group.any((a) => a.isMatched)) continue;

      // Marcar como matched
      for (final animal in group) {
        final index = _animals.indexWhere((a) => a.id == animal.id);
        if (index != -1) {
          _animals[index] = animal.copyWith(isMatched: true);
        }
      }

      // Calcular puntos
      final points = _calculatePoints(group.length);
      _score += points * _comboMultiplier;
      _comboMultiplier++;

      // Remover animales matched después de un delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_gameState == CascadeGameState.playing) {
          _animals.removeWhere((a) => a.isMatched);
          _checkWin();
          Future.microtask(() => notifyListeners());
        }
      });
    }

    // Reset combo si no hay matches
    if (matchedGroups.isEmpty) {
      _comboMultiplier = 1;
    }
  }

  int _calculatePoints(int count) {
    if (count == 2) return 10;
    if (count == 3) return 30;
    if (count >= 4) return 50;
    return 0;
  }

  void _checkWin() {
    if (_score >= _targetScore && _gameState == CascadeGameState.playing) {
      _gameState = CascadeGameState.won;
      _spawnTimer?.cancel();
      _gameTimer?.cancel();
      _calculateAndSaveStars();
      Future.microtask(() => notifyListeners());
    }
  }

  void _calculateAndSaveStars() {
    // Calcular estrellas basado en tiempo restante y movimientos
    int stars = 1;
    
    // Obtener valores iniciales según el nivel
    int initialTime = 60;
    int initialMoves = 20;
    switch (_currentLevel) {
      case 'easy':
        initialTime = 60;
        initialMoves = 20;
        break;
      case 'medium':
        initialTime = 90;
        initialMoves = 25;
        break;
      case 'hard':
        initialTime = 120;
        initialMoves = 30;
        break;
    }
    
    final timeRatio = _timeLeft / initialTime;
    final movesRatio = _movesLeft / initialMoves;
    final averageRatio = (timeRatio + movesRatio) / 2.0;
    
    if (averageRatio >= 0.8) {
      stars = 3;
    } else if (averageRatio >= 0.5) {
      stars = 2;
    }
    
    _saveBestStars(_currentLevel, stars);
  }

  int getStars() {
    if (_gameState != CascadeGameState.won) return 0;

    // Obtener valores iniciales según el nivel
    int initialTime = 60;
    int initialMoves = 20;
    switch (_currentLevel) {
      case 'easy':
        initialTime = 60;
        initialMoves = 20;
        break;
      case 'medium':
        initialTime = 90;
        initialMoves = 25;
        break;
      case 'hard':
        initialTime = 120;
        initialMoves = 30;
        break;
    }
    
    final timeRatio = _timeLeft / initialTime;
    final movesRatio = _movesLeft / initialMoves;
    final averageRatio = (timeRatio + movesRatio) / 2.0;
    
    if (averageRatio >= 0.8) {
      return 3;
    } else if (averageRatio >= 0.5) {
      return 2;
    } else {
      return 1;
    }
  }

  void startDrag(String animalId, double x, double y) {
    final index = _animals.indexWhere((a) => a.id == animalId);
    if (index != -1) {
      _draggedAnimal = _animals[index];
      _animals[index] = _animals[index].copyWith(isDragging: true);
      notifyListeners();
    }
  }

  void updateDrag(double x, double y) {
    if (_draggedAnimal != null && _gameAreaWidth > 0 && _gameAreaHeight > 0) {
      final normalizedX = (x / _gameAreaWidth).clamp(0.05, 0.95);
      final normalizedY = (y / _gameAreaHeight).clamp(0.1, 0.9);
      final index = _animals.indexWhere((a) => a.id == _draggedAnimal!.id);
      if (index != -1) {
        _animals[index] = _animals[index].copyWith(x: normalizedX, y: normalizedY);
        notifyListeners();
      }
    }
  }

  void endDrag() {
    if (_draggedAnimal != null) {
      final index = _animals.indexWhere((a) => a.id == _draggedAnimal!.id);
      if (index != -1) {
        _animals[index] = _animals[index].copyWith(isDragging: false);
      }
      _draggedAnimal = null;
      
      _movesLeft--;
      
      // Verificar matches después de soltar
      _checkMatches();
      
      // Game over si no quedan movimientos
      if (_movesLeft <= 0 && _gameState == CascadeGameState.playing) {
        _gameState = CascadeGameState.lost;
        _spawnTimer?.cancel();
        _gameTimer?.cancel();
      }
      
      notifyListeners();
    }
  }

  void resetGame() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    initializeGame(_currentLevel);
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }
}
