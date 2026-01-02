import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jigsaw_piece_model.dart';
import '../utils/constants.dart';

enum JigsawGameState { playing, won }

class JigsawProvider extends ChangeNotifier {
  List<JigsawPiece> _pieces = [];
  int _rows = 2;
  int _cols = 2;
  String _currentLevel = 'easy';
  JigsawGameState _gameState = JigsawGameState.playing;
  int _seconds = 0;
  Timer? _timer;
  String _selectedAnimal = '🐶';
  int _piecesPlaced = 0;

  // Dimensiones del área de construcción
  double _pieceSize = 100;

  List<JigsawPiece> get pieces => _pieces;
  int get rows => _rows;
  int get cols => _cols;
  String get currentLevel => _currentLevel;
  JigsawGameState get gameState => _gameState;
  int get seconds => _seconds;
  String get selectedAnimal => _selectedAnimal;
  int get totalPieces => _rows * _cols;
  int get piecesPlaced => _piecesPlaced;
  double get pieceSize => _pieceSize;

  // Obtener estrellas guardadas
  Future<int> getBestStars(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('jigsaw_stars_$level') ?? 0;
  }

  // Guardar estrellas
  Future<void> _saveBestStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestStars(_currentLevel);
    if (stars > currentBest) {
      await prefs.setInt('jigsaw_stars_$_currentLevel', stars);
    }
  }

  // Obtener mejor tiempo
  Future<int> getBestTime(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('jigsaw_time_$level') ?? 999;
  }

  // Guardar mejor tiempo
  Future<void> _saveBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestTime(_currentLevel);
    if (_seconds < currentBest) {
      await prefs.setInt('jigsaw_time_$_currentLevel', _seconds);
    }
  }

  void initializeGame(String level, Size screenSize) {
    _currentLevel = level;
    _seconds = 0;
    _gameState = JigsawGameState.playing;
    _piecesPlaced = 0;
    _timer?.cancel();

    // Configurar grid según nivel
    switch (level) {
      case 'easy':
        _rows = 2;
        _cols = 2;
        break;
      case 'medium':
        _rows = 2;
        _cols = 3;
        break;
      case 'hard':
        _rows = 3;
        _cols = 3;
        break;
    }

    // Seleccionar animal aleatorio
    final random = Random();
    final allAnimals = [...GameConstants.easyAnimals];
    _selectedAnimal = allAnimals[random.nextInt(allAnimals.length)];

    // Calcular dimensiones
    final boardWidth = screenSize.width * 0.8;
    _pieceSize = boardWidth / _cols;

    _initializePieces(screenSize);
    _startTimer();
    notifyListeners();
  }

  void _initializePieces(Size screenSize) {
    _pieces.clear();
    final random = Random();
    
    // Área donde aparecen las piezas desordenadas (parte inferior)
    final scrambleAreaTop = screenSize.height * 0.55;
    final scrambleAreaHeight = screenSize.height * 0.3;
    final scrambleAreaWidth = screenSize.width * 0.9;

    // Lista de emojis según el tamaño del grid
    List<String> partEmojis;
    
    if (_rows == 2 && _cols == 2) {
      // 2x2: 4 emojis diferentes
      partEmojis = ['🐶', '🐱', '🐭', '🐰'];
    } else if (_rows == 2 && _cols == 3) {
      // 2x3: 6 emojis diferentes
      partEmojis = ['🐶', '🐱', '🐭', '🐰', '🦊', '🐻'];
    } else if (_rows == 3 && _cols == 3) {
      // 3x3: 9 emojis diferentes
      partEmojis = ['🐶', '🐱', '🐭', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯'];
    } else {
      partEmojis = ['🐶', '🐱', '🐭', '🐰'];
    }

    int id = 0;
    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        // Posición aleatoria en el área de piezas desordenadas
        final randomX = random.nextDouble() * (scrambleAreaWidth - _pieceSize);
        final randomY = scrambleAreaTop + (random.nextDouble() * (scrambleAreaHeight - _pieceSize));

        _pieces.add(JigsawPiece(
          id: id,
          correctRow: row,
          correctCol: col,
          currentPosition: Offset(randomX, randomY),
          partEmoji: partEmojis[id], // Emoji único para cada pieza
        ));
        id++;
      }
    }
  }

  void onPieceDropped(int pieceId, Offset localPosition, Offset stackBoardPosition) {
    final index = _pieces.indexWhere((p) => p.id == pieceId);
    if (index == -1 || _pieces[index].isPlaced) return;

    final piece = _pieces[index];
    
    // Calcular posición correcta en el tablero (en coordenadas del Stack)
    // stackBoardPosition es la posición del tablero (esquina superior izquierda) en coordenadas del Stack
    final correctX = stackBoardPosition.dx + (piece.correctCol * _pieceSize);
    final correctY = stackBoardPosition.dy + (piece.correctRow * _pieceSize);
    
    // Calcular centro de la posición correcta
    final targetCenterX = correctX + (_pieceSize / 2);
    final targetCenterY = correctY + (_pieceSize / 2);
    
    // localPosition es donde se soltó la pieza (en coordenadas del Stack)
    // Calculamos la distancia desde ese punto al centro del objetivo
    final dx = localPosition.dx - targetCenterX;
    final dy = localPosition.dy - targetCenterY;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Umbral más generoso: 80% del tamaño de la pieza
    final threshold = _pieceSize * 0.8;
    
    print('Pieza ${piece.id}: Distancia = ${distance.toStringAsFixed(1)} (umbral: ${threshold.toStringAsFixed(1)})');
    print('  - Objetivo: ($targetCenterX, $targetCenterY)');
    print('  - Soltado: (${localPosition.dx.toStringAsFixed(1)}, ${localPosition.dy.toStringAsFixed(1)})');
    
    if (distance < threshold) {
      // ¡Encaja!
      _pieces[index] = piece.copyWith(
        currentPosition: Offset(correctX, correctY),
        isPlaced: true,
      );
      _piecesPlaced++;
      
      print('✅ Pieza ${piece.id + 1} encajada correctamente!');
      
      // Verificar victoria
      if (_piecesPlaced == totalPieces) {
        _gameState = JigsawGameState.won;
        _timer?.cancel();
        _calculateAndSaveStars();
        _saveBestTime();
      }
      
      notifyListeners();
    } else {
      // No encaja, mantener la posición actual (la pieza vuelve a donde estaba)
      print('❌ Pieza ${piece.id + 1} no encaja. Distancia: ${distance.toStringAsFixed(1)}');
      notifyListeners();
    }
  }

  void _calculateAndSaveStars() {
    int stars = 1;
    
    switch (_currentLevel) {
      case 'easy':
        if (_seconds <= 30) {
          stars = 3;
        } else if (_seconds <= 60) {
          stars = 2;
        }
        break;
      case 'medium':
        if (_seconds <= 60) {
          stars = 3;
        } else if (_seconds <= 90) {
          stars = 2;
        }
        break;
      case 'hard':
        if (_seconds <= 90) {
          stars = 3;
        } else if (_seconds <= 150) {
          stars = 2;
        }
        break;
    }

    _saveBestStars(stars);
  }

  int getStars() {
    if (_gameState != JigsawGameState.won) return 0;

    int stars = 1;
    
    switch (_currentLevel) {
      case 'easy':
        if (_seconds <= 30) stars = 3;
        else if (_seconds <= 60) stars = 2;
        break;
      case 'medium':
        if (_seconds <= 60) stars = 3;
        else if (_seconds <= 90) stars = 2;
        break;
      case 'hard':
        if (_seconds <= 90) stars = 3;
        else if (_seconds <= 150) stars = 2;
        break;
    }

    return stars;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == JigsawGameState.playing) {
        _seconds++;
        notifyListeners();
      }
    });
  }

  void resetGame(Size screenSize) {
    initializeGame(_currentLevel, screenSize);
  }

  String getFormattedTime() {
    final minutes = _seconds ~/ 60;
    final secs = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

