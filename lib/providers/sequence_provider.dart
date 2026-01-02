import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sequence_animal_model.dart';
import '../utils/constants.dart';

enum SequenceGameState { ready, showing, waiting, correct, wrong, won }

class SequenceProvider extends ChangeNotifier {
  List<SequenceAnimal> _availableAnimals = [];
  List<int> _sequence = []; // Índices de la secuencia
  List<int> _playerSequence = [];
  String _currentLevel = 'easy';
  SequenceGameState _gameState = SequenceGameState.ready;
  int _currentRound = 0;
  int _highScore = 0;
  int _animatingIndex = -1; // Índice del animal que se está iluminando

  List<SequenceAnimal> get availableAnimals => _availableAnimals;
  List<int> get sequence => _sequence;
  List<int> get playerSequence => _playerSequence;
  String get currentLevel => _currentLevel;
  SequenceGameState get gameState => _gameState;
  int get currentRound => _currentRound;
  int get highScore => _highScore;
  int get animatingIndex => _animatingIndex;
  int get sequenceLength => _sequence.length;

  // Cargar mejor puntuación
  Future<void> loadHighScore(String level) async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('sequence_highscore_$level') ?? 0;
    notifyListeners();
  }

  // Guardar mejor puntuación
  Future<void> _saveHighScore() async {
    if (_currentRound > _highScore) {
      _highScore = _currentRound;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sequence_highscore_$_currentLevel', _highScore);
    }
  }

  // Obtener estrellas guardadas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('sequence_stars_$level') ?? 0;
  }

  // Guardar estrellas
  Future<void> _saveBestStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(_currentLevel);
    if (stars > currentBest) {
      await prefs.setInt('sequence_stars_$_currentLevel', stars);
    }
  }

  void initializeGame(String level) async {
    _currentLevel = level;
    _sequence.clear();
    _playerSequence.clear();
    _currentRound = 0;
    _gameState = SequenceGameState.ready;
    _animatingIndex = -1;

    await loadHighScore(level);

    // Configurar animales según nivel
    List<String> emojis;
    switch (level) {
      case 'easy':
        emojis = GameConstants.easyAnimals.take(4).toList();
        break;
      case 'medium':
        emojis = GameConstants.mediumAnimals.take(4).toList();
        break;
      case 'hard':
        emojis = GameConstants.hardAnimals.take(4).toList();
        break;
      default:
        emojis = GameConstants.easyAnimals.take(4).toList();
    }

    _availableAnimals = List.generate(
      4,
      (index) => SequenceAnimal(emoji: emojis[index], index: index),
    );

    notifyListeners();
  }

  void startNewRound() {
    _playerSequence.clear();
    _gameState = SequenceGameState.showing;
    _currentRound++;

    // Agregar un nuevo número a la secuencia
    final random = Random();
    _sequence.add(random.nextInt(4));

    notifyListeners();

    // Mostrar la secuencia
    _showSequence();
  }

  Future<void> _showSequence() async {
    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Iluminar animal
      _animatingIndex = _sequence[i];
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 600));

      // Apagar animal
      _animatingIndex = -1;
      notifyListeners();
    }

    // Esperar un poco y cambiar a modo espera
    await Future.delayed(const Duration(milliseconds: 500));
    _gameState = SequenceGameState.waiting;
    notifyListeners();
  }

  void onAnimalTapped(int index) {
    if (_gameState != SequenceGameState.waiting) return;

    _playerSequence.add(index);

    // Verificar si es correcto hasta ahora
    final currentIndex = _playerSequence.length - 1;
    if (_playerSequence[currentIndex] != _sequence[currentIndex]) {
      // ¡Error!
      _gameState = SequenceGameState.wrong;
      _saveHighScore();
      notifyListeners();
      return;
    }

    // Si completó toda la secuencia correctamente
    if (_playerSequence.length == _sequence.length) {
      _gameState = SequenceGameState.correct;
      
      // Verificar si ganó (según nivel)
      int winCondition = 0;
      switch (_currentLevel) {
        case 'easy':
          winCondition = 5;
          break;
        case 'medium':
          winCondition = 7;
          break;
        case 'hard':
          winCondition = 10;
          break;
      }

      if (_currentRound >= winCondition) {
        _gameState = SequenceGameState.won;
        _calculateAndSaveStars();
      }

      _saveHighScore();
      notifyListeners();
    }
  }

  void _calculateAndSaveStars() {
    int stars = 1;
    
    switch (_currentLevel) {
      case 'easy':
        if (_currentRound >= 10) stars = 3;
        else if (_currentRound >= 7) stars = 2;
        break;
      case 'medium':
        if (_currentRound >= 12) stars = 3;
        else if (_currentRound >= 9) stars = 2;
        break;
      case 'hard':
        if (_currentRound >= 15) stars = 3;
        else if (_currentRound >= 12) stars = 2;
        break;
    }

    _saveBestStars(stars);
  }

  int getStars() {
    int stars = 1;
    
    switch (_currentLevel) {
      case 'easy':
        if (_currentRound >= 10) stars = 3;
        else if (_currentRound >= 7) stars = 2;
        break;
      case 'medium':
        if (_currentRound >= 12) stars = 3;
        else if (_currentRound >= 9) stars = 2;
        break;
      case 'hard':
        if (_currentRound >= 15) stars = 3;
        else if (_currentRound >= 12) stars = 2;
        break;
    }

    return stars;
  }

  void resetGame() {
    initializeGame(_currentLevel);
  }
}

