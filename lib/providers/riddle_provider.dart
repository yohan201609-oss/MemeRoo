import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/riddle_animal_model.dart';
import '../utils/audio_manager.dart';

enum RiddleGameState { playing, won }

class RiddleProvider extends ChangeNotifier {
  bool _isDisposed = false;
  List<RiddleAnimal> _animals = [];
  RiddleAnimal? _currentAnimal;
  List<RiddleAnimal> _options = [];
  int _currentClueIndex = 0;
  int _score = 0;
  int _round = 0;
  int _totalRounds = 8;
  String _currentLevel = 'easy';
  RiddleGameState _gameState = RiddleGameState.playing;
  int _correctAnswers = 0;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<RiddleAnimal> get animals => _animals;
  RiddleAnimal? get currentAnimal => _currentAnimal;
  List<RiddleAnimal> get options => _options;
  int get currentClueIndex => _currentClueIndex;
  int get score => _score;
  int get round => _round;
  int get totalRounds => _totalRounds;
  String get currentLevel => _currentLevel;
  RiddleGameState get gameState => _gameState;
  int get correctAnswers => _correctAnswers;

  // Obtener estrellas guardadas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('riddle_stars_$level') ?? 0;
  }

  // Guardar estrellas
  Future<void> _saveBestStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(_currentLevel);
    if (stars > currentBest) {
      await prefs.setInt('riddle_stars_$_currentLevel', stars);
    }
  }

  // Obtener mejor puntuación
  Future<int> getBestScore(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('riddle_score_$level') ?? 0;
  }

  // Guardar mejor puntuación
  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestScore(_currentLevel);
    if (_score > currentBest) {
      await prefs.setInt('riddle_score_$_currentLevel', _score);
    }
  }

  void initializeGame(String level) {
    _currentLevel = level;
    _score = 0;
    _round = 0;
    _correctAnswers = 0;
    _gameState = RiddleGameState.playing;

    // Configurar según nivel
    switch (level) {
      case 'easy':
        _totalRounds = 5;
        break;
      case 'medium':
        _totalRounds = 8;
        break;
      case 'hard':
        _totalRounds = 10;
        break;
    }

    _initializeAnimals();
    _nextRound();
    notifyListeners();
  }

  void _initializeAnimals() {
    _animals = [
      RiddleAnimal(
        emoji: '🐶',
        name: 'Perro',
        clues: [
          '🏠 Vivo en las casas',
          '🦴 Me encanta comer huesos',
          '🔊 Hago "guau guau"',
        ],
      ),
      RiddleAnimal(
        emoji: '🐱',
        name: 'Gato',
        clues: [
          '🏠 Vivo en las casas',
          '🥛 Me gusta la leche',
          '🔊 Hago "miau miau"',
        ],
      ),
      RiddleAnimal(
        emoji: '🐭',
        name: 'Ratón',
        clues: [
          '🧀 Me encanta el queso',
          '📦 Vivo en lugares pequeños',
          '👂 Tengo orejas grandes',
        ],
      ),
      RiddleAnimal(
        emoji: '🐰',
        name: 'Conejo',
        clues: [
          '🥕 Como zanahorias',
          '👂 Tengo orejas largas',
          '🦘 Salto mucho',
        ],
      ),
      RiddleAnimal(
        emoji: '🐻',
        name: 'Oso',
        clues: [
          '🌲 Vivo en el bosque',
          '🍯 Me encanta la miel',
          '💪 Soy muy fuerte',
        ],
      ),
      RiddleAnimal(
        emoji: '🦊',
        name: 'Zorro',
        clues: [
          '🌲 Vivo en el bosque',
          '🟠 Soy de color naranja',
          '🦊 Tengo cola larga y peluda',
        ],
      ),
      RiddleAnimal(
        emoji: '🐼',
        name: 'Panda',
        clues: [
          '🎋 Como bambú',
          '⚪⚫ Soy blanco y negro',
          '🇨🇳 Vivo en China',
        ],
      ),
      RiddleAnimal(
        emoji: '🦁',
        name: 'León',
        clues: [
          '🌍 Vivo en África',
          '👑 Soy el rey de la selva',
          '🔊 Rujo muy fuerte',
        ],
      ),
      RiddleAnimal(
        emoji: '🐘',
        name: 'Elefante',
        clues: [
          '👃 Tengo una trompa larga',
          '💪 Soy muy grande',
          '🐘 Nunca olvido nada',
        ],
      ),
      RiddleAnimal(
        emoji: '🐵',
        name: 'Mono',
        clues: [
          '🌴 Vivo en los árboles',
          '🍌 Me encantan los plátanos',
          '🤸 Soy muy ágil',
        ],
      ),
      RiddleAnimal(
        emoji: '🐸',
        name: 'Rana',
        clues: [
          '💧 Vivo cerca del agua',
          '🦗 Como insectos',
          '🦘 Salto muy bien',
        ],
      ),
      RiddleAnimal(
        emoji: '🐧',
        name: 'Pingüino',
        clues: [
          '❄️ Vivo donde hace frío',
          '🐟 Como pescado',
          '🏊 Nado muy bien',
        ],
      ),
    ];

    _animals.shuffle(Random());
  }

  void _nextRound() {
    if (_round >= _totalRounds) {
      _gameState = RiddleGameState.won;
      AudioManager().playWin();
      _calculateAndSaveStars();
      _saveBestScore();
      notifyListeners();
      return;
    }

    _round++;
    _currentClueIndex = 0;
    final random = Random();

    // Seleccionar animal actual
    _currentAnimal = _animals[(_round - 1) % _animals.length];

    // Generar opciones (1 correcta + 3 incorrectas)
    _options = [_currentAnimal!];

    while (_options.length < 4) {
      final randomAnimal = _animals[random.nextInt(_animals.length)];
      if (!_options.any((o) => o.emoji == randomAnimal.emoji)) {
        _options.add(randomAnimal);
      }
    }

    _options.shuffle(Random());
    notifyListeners();
  }

  void showNextClue() {
    if (_currentClueIndex < 2) {
      _currentClueIndex++;
      notifyListeners();
    }
  }

  void selectAnimal(String emoji) {
    if (_gameState != RiddleGameState.playing) return;
    if (_currentAnimal == null) return;

    if (emoji == _currentAnimal!.emoji) {
      // ¡Correcto!
      AudioManager().playSuccess();
      _correctAnswers++;
      
      // Puntos según la pista en la que acertó
      int points = 0;
      switch (_currentClueIndex) {
        case 0:
          points = 30; // Primera pista
          break;
        case 1:
          points = 20; // Segunda pista
          break;
        case 2:
          points = 10; // Tercera pista
          break;
      }
      _score += points;

      // Siguiente ronda después de un delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        _nextRound();
      });
    } else {
      // Incorrecto - mostrar siguiente pista si hay
      AudioManager().playError();
      if (_currentClueIndex < 2) {
        showNextClue();
      } else {
        // Ya no hay más pistas, siguiente ronda sin puntos
        Future.delayed(const Duration(milliseconds: 800), () {
          _nextRound();
        });
      }
    }

    notifyListeners();
  }

  void _calculateAndSaveStars() {
    int stars = 1;
    final percentage = (_correctAnswers / _totalRounds) * 100;

    if (percentage >= 90) {
      stars = 3;
    } else if (percentage >= 70) {
      stars = 2;
    }

    _saveBestStars(stars);
  }

  int getStars() {
    if (_gameState != RiddleGameState.won) return 0;

    final percentage = (_correctAnswers / _totalRounds) * 100;

    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    return 1;
  }

  void resetGame() {
    initializeGame(_currentLevel);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

