import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shadow_animal_model.dart';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';

enum ShadowGameState { playing, won }

class ShadowProvider extends ChangeNotifier {
  bool _isDisposed = false;
  List<ShadowAnimal> _animals = [];
  ShadowAnimal? _currentShadow;
  List<ShadowAnimal> _options = [];
  int _score = 0;
  int _round = 0;
  int _totalRounds = 10;
  String _currentLevel = 'easy';
  ShadowGameState _gameState = ShadowGameState.playing;
  int _correctAnswers = 0;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<ShadowAnimal> get animals => _animals;
  ShadowAnimal? get currentShadow => _currentShadow;
  List<ShadowAnimal> get options => _options;
  int get score => _score;
  int get round => _round;
  int get totalRounds => _totalRounds;
  String get currentLevel => _currentLevel;
  ShadowGameState get gameState => _gameState;
  int get correctAnswers => _correctAnswers;

  // Obtener estrellas guardadas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('shadow_stars_$level') ?? 0;
  }

  // Guardar estrellas
  Future<void> _saveBestStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(_currentLevel);
    if (stars > currentBest) {
      await prefs.setInt('shadow_stars_$_currentLevel', stars);
    }
  }

  // Obtener mejor puntuación
  Future<int> getBestScore(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('shadow_score_$level') ?? 0;
  }

  // Guardar mejor puntuación
  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestScore(_currentLevel);
    if (_score > currentBest) {
      await prefs.setInt('shadow_score_$_currentLevel', _score);
    }
  }

  void initializeGame(String level) {
    _currentLevel = level;
    _score = 0;
    _round = 0;
    _correctAnswers = 0;
    _gameState = ShadowGameState.playing;

    // Configurar según nivel
    switch (level) {
      case 'easy':
        _totalRounds = 5;
        _animals = GameConstants.easyAnimals.take(6).map((e) => 
          ShadowAnimal(emoji: e, name: _getAnimalName(e))
        ).toList();
        break;
      case 'medium':
        _totalRounds = 8;
        _animals = GameConstants.mediumAnimals.take(10).map((e) => 
          ShadowAnimal(emoji: e, name: _getAnimalName(e))
        ).toList();
        break;
      case 'hard':
        _totalRounds = 10;
        _animals = GameConstants.hardAnimals.take(15).map((e) => 
          ShadowAnimal(emoji: e, name: _getAnimalName(e))
        ).toList();
        break;
    }

    _animals.shuffle(Random());
    _nextRound();
    notifyListeners();
  }

  String _getAnimalName(String emoji) {
    final names = {
      '🐶': 'Perro',
      '🐱': 'Gato',
      '🐭': 'Ratón',
      '🐹': 'Hámster',
      '🐰': 'Conejo',
      '🦊': 'Zorro',
      '🐻': 'Oso',
      '🐼': 'Panda',
      '🐨': 'Koala',
      '🐯': 'Tigre',
      '🦁': 'León',
      '🐮': 'Vaca',
      '🐷': 'Cerdo',
      '🐸': 'Rana',
      '🐵': 'Mono',
    };
    return names[emoji] ?? 'Animal';
  }

  void _nextRound() {
    if (_round >= _totalRounds) {
      _gameState = ShadowGameState.won;
      AudioManager().playWin();
      _calculateAndSaveStars();
      _saveBestScore();
      notifyListeners();
      return;
    }

    _round++;
    final random = Random();

    // Seleccionar animal actual
    var availableAnimals = _animals.where((a) => !a.isMatched).toList();
    if (availableAnimals.isEmpty) {
      _animals = _animals.map((a) => a.copyWith(isMatched: false)).toList();
      availableAnimals = _animals;
    }

    _currentShadow = availableAnimals[random.nextInt(availableAnimals.length)];

    // Generar opciones (1 correcta + 2-3 incorrectas)
    _options = [_currentShadow!];
    
    final numOptions = _currentLevel == 'easy' ? 2 : 
                      _currentLevel == 'medium' ? 3 : 4;

    while (_options.length < numOptions) {
      final randomAnimal = _animals[random.nextInt(_animals.length)];
      if (!_options.any((o) => o.emoji == randomAnimal.emoji)) {
        _options.add(randomAnimal);
      }
    }

    _options.shuffle(Random());
    notifyListeners();
  }

  void selectAnimal(String emoji) {
    if (_gameState != ShadowGameState.playing) return;
    if (_currentShadow == null) return;

    if (emoji == _currentShadow!.emoji) {
      // ¡Correcto!
      AudioManager().playSuccess();
      _correctAnswers++;
      _score += 10;
      
      // Marcar como emparejado
      final index = _animals.indexWhere((a) => a.emoji == emoji);
      if (index != -1) {
        _animals[index] = _animals[index].copyWith(isMatched: true);
      }

      // Siguiente ronda después de un delay
      Future.delayed(const Duration(milliseconds: 800), () {
        _nextRound();
      });
    } else {
      // Incorrecto - no suma puntos pero continúa
      AudioManager().playError();
      Future.delayed(const Duration(milliseconds: 500), () {
        _nextRound();
      });
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
    if (_gameState != ShadowGameState.won) return 0;

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

