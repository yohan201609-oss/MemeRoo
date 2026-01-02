import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guess_animal_model.dart';
import '../utils/constants.dart';

enum GuessGameState { playing, won, lost }

class GuessProvider extends ChangeNotifier {
  List<GuessAnimal> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  String _currentLevel = 'easy';
  GuessGameState _gameState = GuessGameState.playing;
  Timer? _revealTimer;
  bool _hasAnswered = false;

  List<GuessAnimal> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  GuessAnimal? get currentQuestion => 
      _currentQuestionIndex < _questions.length ? _questions[_currentQuestionIndex] : null;
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  int get totalQuestions => _questions.length;
  String get currentLevel => _currentLevel;
  GuessGameState get gameState => _gameState;
  bool get hasAnswered => _hasAnswered;

  // Obtener mejor puntuación de estrellas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('guess_stars_$level') ?? 0;
  }

  // Guardar mejor puntuación de estrellas
  Future<void> _saveBestStars(String level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(level);
    if (stars > currentBest) {
      await prefs.setInt('guess_stars_$level', stars);
    }
  }

  void initializeGame(String level) {
    _currentLevel = level;
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswers = 0;
    _gameState = GuessGameState.playing;
    _hasAnswered = false;
    _revealTimer?.cancel();

    List<String> animalList;
    
    switch (level) {
      case 'easy':
        animalList = GameConstants.easyAnimals;
        break;
      case 'medium':
        animalList = GameConstants.mediumAnimals;
        break;
      case 'hard':
        animalList = GameConstants.hardAnimals;
        break;
      default:
        animalList = GameConstants.easyAnimals;
    }

    // Crear preguntas
    final random = Random();
    final selectedAnimals = List<String>.from(animalList);
    selectedAnimals.shuffle(random);
    
    _questions = [];
    for (int i = 0; i < selectedAnimals.length; i++) {
      final correctAnimal = selectedAnimals[i];
      
      // Crear opciones (1 correcta + 3 incorrectas)
      final options = <String>[correctAnimal];
      final wrongAnimals = List<String>.from(animalList);
      wrongAnimals.remove(correctAnimal);
      wrongAnimals.shuffle(random);
      options.addAll(wrongAnimals.take(3));
      options.shuffle(random);

      _questions.add(GuessAnimal(
        emoji: correctAnimal,
        correctAnswer: _getAnimalName(correctAnimal),
        options: options.map((e) => _getAnimalName(e)).toList(),
        revealLevel: 0,
      ));
    }

    _startRevealTimer();
    notifyListeners();
  }

  String _getAnimalName(String emoji) {
    const names = {
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

  void _startRevealTimer() {
    _revealTimer?.cancel();
    _hasAnswered = false;
    
    if (currentQuestion == null) return;

    _revealTimer = Timer.periodic(
      const Duration(seconds: GameConstants.guessRevealInterval),
      (timer) {
        if (_hasAnswered || currentQuestion == null) {
          timer.cancel();
          return;
        }

        final question = currentQuestion!;
        if (question.revealLevel < GameConstants.guessMaxRevealLevels - 1) {
          final index = _questions.indexOf(question);
          if (index != -1) {
            _questions[index] = question.copyWith(
              revealLevel: question.revealLevel + 1,
            );
            notifyListeners();
          }
        } else {
          timer.cancel();
        }
      },
    );
  }

  void answerQuestion(String answer) {
    if (_hasAnswered || currentQuestion == null) return;

    _hasAnswered = true;
    _revealTimer?.cancel();

    final question = currentQuestion!;
    final isCorrect = answer == question.correctAnswer;

    if (isCorrect) {
      _correctAnswers++;
      // Calcular puntos según nivel de revelación
      final points = _calculatePoints(question.revealLevel);
      _score += points;
    }

    notifyListeners();
  }

  int _calculatePoints(int revealLevel) {
    // Nivel 0 (más borroso) = 50 puntos, nivel 4 (menos borroso) = 10 puntos
    return 50 - (revealLevel * 10);
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _hasAnswered = false;
      _startRevealTimer();
      notifyListeners();
    } else {
      // Juego completado
      _gameState = GuessGameState.won;
      _calculateAndSaveStars();
      notifyListeners();
    }
  }

  void _calculateAndSaveStars() {
    final totalQuestions = _questions.length;
    final correctPercentage = _correctAnswers / totalQuestions;
    final avgRevealLevel = _questions
        .where((q) => q.revealLevel < 3)
        .length / totalQuestions;

    int stars = 1;
    if (correctPercentage == 1.0 && avgRevealLevel >= 0.8) {
      stars = 3; // Todos correctos antes del nivel 3
    } else if (correctPercentage == 1.0 && avgRevealLevel >= 0.5) {
      stars = 2; // Todos correctos antes del nivel 4
    }

    _saveBestStars(_currentLevel, stars);
  }

  int getStars() {
    if (_gameState != GuessGameState.won) return 0;
    
    final totalQuestions = _questions.length;
    final correctPercentage = _correctAnswers / totalQuestions;
    final avgRevealLevel = _questions
        .where((q) => q.revealLevel < 3)
        .length / totalQuestions;

    if (correctPercentage == 1.0 && avgRevealLevel >= 0.8) {
      return 3;
    } else if (correctPercentage == 1.0 && avgRevealLevel >= 0.5) {
      return 2;
    } else {
      return 1;
    }
  }

  void resetGame() {
    initializeGame(_currentLevel);
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }
}

