import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/memory_card.dart';
import '../utils/constants.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';

enum GameState { playing, paused, won }

class GameProvider extends ChangeNotifier {
  bool _isDisposed = false;
  List<MemoryCard> _cards = [];
  List<MemoryCard> _flippedCards = [];
  String _currentLevel = 'easy';
  int _pairsFound = 0;
  int _moves = 0;
  GameState _gameState = GameState.playing;
  bool _canFlip = true;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<MemoryCard> get cards => _cards;
  int get pairsFound => _pairsFound;
  int get totalPairs => GameConstants.levelConfig[_currentLevel]!['pairs']!;
  int get moves => _moves;
  GameState get gameState => _gameState;
  String get currentLevel => _currentLevel;

  // Almacenar mejores puntuaciones por nivel
  final Map<String, int> _bestStars = {
    'easy': 0,
    'medium': 0,
    'hard': 0,
  };

  int getBestStars(String level) {
    return _bestStars[level] ?? 0;
  }

  void _updateBestStars(String level, int stars) {
    final currentBest = _bestStars[level] ?? 0;
    if (stars > currentBest) {
      _bestStars[level] = stars;
      notifyListeners();
    }
  }

  void initializeGame(String level) {
    _currentLevel = level;
    _pairsFound = 0;
    _moves = 0;
    _gameState = GameState.playing;
    _flippedCards.clear();
    _canFlip = true;

    final pairs = GameConstants.levelConfig[level]!['pairs']!;
    final selectedAnimals = GameConstants.animals.take(pairs).toList();
    
    _cards = [];
    for (int i = 0; i < selectedAnimals.length; i++) {
      final emoji = selectedAnimals[i];
      final color = AppColors.cardColors[i % AppColors.cardColors.length];
      
      _cards.add(MemoryCard(
        id: '${emoji}_1',
        emoji: emoji,
        color: color,
      ));
      _cards.add(MemoryCard(
        id: '${emoji}_2',
        emoji: emoji,
        color: color,
      ));
    }

    _cards.shuffle(Random());
    notifyListeners();
  }

  Future<void> flipCard(String cardId) async {
    if (!_canFlip || _gameState != GameState.playing) return;

    final cardIndex = _cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final card = _cards[cardIndex];
    if (card.isFlipped || card.isMatched) return;

    if (_flippedCards.length >= 2) return;

    AudioManager().playFlip();
    _cards[cardIndex] = card.copyWith(isFlipped: true);
    _flippedCards.add(_cards[cardIndex]);
    notifyListeners();

    if (_flippedCards.length == 2) {
      _moves++;
      _canFlip = false;
      await _checkMatch();
    }
  }

  Future<void> _checkMatch() async {
    await Future.delayed(GameConstants.matchDelay);

    final card1 = _flippedCards[0];
    final card2 = _flippedCards[1];

    if (card1.emoji == card2.emoji) {
      // Match encontrado
      HapticFeedback.lightImpact();
      AudioManager().playMatch();
      
      final index1 = _cards.indexWhere((c) => c.id == card1.id);
      final index2 = _cards.indexWhere((c) => c.id == card2.id);

      _cards[index1] = card1.copyWith(isMatched: true);
      _cards[index2] = card2.copyWith(isMatched: true);

      _pairsFound++;
      _flippedCards.clear();

      if (_pairsFound == totalPairs) {
        _gameState = GameState.won;
        AudioManager().playWin();
        // Actualizar mejor puntuación
        final stars = GameConstants.calculateStars(_currentLevel, _moves);
        _updateBestStars(_currentLevel, stars);
      }

      _canFlip = true;
      notifyListeners();
    } else {
      // No match
      AudioManager().playError();
      await Future.delayed(GameConstants.mismatchDelay);

      final index1 = _cards.indexWhere((c) => c.id == card1.id);
      final index2 = _cards.indexWhere((c) => c.id == card2.id);

      _cards[index1] = card1.copyWith(isFlipped: false);
      _cards[index2] = card2.copyWith(isFlipped: false);

      _flippedCards.clear();
      _canFlip = true;
      notifyListeners();
    }
  }

  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      notifyListeners();
    }
  }

  void resetGame() {
    initializeGame(_currentLevel);
  }

  void startGame(String level) {
    initializeGame(level);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

