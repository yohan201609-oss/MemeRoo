class GameConstants {
  // Animales disponibles
  static const List<String> animals = [
    '🐶', '🐱', '🐰', '🐻', '🦁', '🐼',
    '🐘', '🦒', '🐵', '🦆', '🐮', '🐷',
  ];

  // Tamaños
  static const double cardSize = 80.0;
  static const double cardSpacing = 6.0;
  
  // Configuración de niveles
  static const Map<String, Map<String, int>> levelConfig = {
    'easy': {
      'pairs': 3,
      'columns': 2,
    },
    'medium': {
      'pairs': 6,
      'columns': 3,
    },
    'hard': {
      'pairs': 8,
      'columns': 4,
    },
  };
  
  // Sistema de estrellas: umbrales de movimientos
  static const Map<String, Map<String, int>> starThresholds = {
    'easy': {
      'gold': 8,      // 3 estrellas: 6-8 movimientos
      'silver': 12,   // 2 estrellas: 9-12 movimientos
                      // 1 estrella: 13+ movimientos
    },
    'medium': {
      'gold': 16,     // 3 estrellas: 12-16 movimientos
      'silver': 24,   // 2 estrellas: 17-24 movimientos
                      // 1 estrella: 25+ movimientos
    },
    'hard': {
      'gold': 22,     // 3 estrellas: 16-22 movimientos
      'silver': 32,   // 2 estrellas: 23-32 movimientos
                      // 1 estrella: 33+ movimientos
    },
  };
  
  // Calcular estrellas según movimientos
  static int calculateStars(String level, int moves) {
    final thresholds = starThresholds[level]!;
    
    if (moves <= thresholds['gold']!) {
      return 3; // ⭐⭐⭐
    } else if (moves <= thresholds['silver']!) {
      return 2; // ⭐⭐
    } else {
      return 1; // ⭐
    }
  }
  
  // Obtener mensaje según estrellas
  static String getStarMessage(int stars) {
    switch (stars) {
      case 3:
        return '¡Perfecto! 🏆';
      case 2:
        return '¡Muy bien! 👏';
      case 1:
        return '¡Completado! 👍';
      default:
        return '';
    }
  }
  
  // Obtener el siguiente nivel
  static String? getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case 'easy':
        return 'medium';
      case 'medium':
        return 'hard';
      case 'hard':
        return null; // No hay siguiente nivel
      default:
        return null;
    }
  }
  
  // Obtener el nombre del siguiente nivel
  static String? getNextLevelName(String currentLevel) {
    final nextLevel = getNextLevel(currentLevel);
    if (nextLevel == null) return null;
    
    switch (nextLevel) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Medio';
      case 'hard':
        return 'Difícil';
      default:
        return null;
    }
  }
  
  // Animaciones
  static const Duration cardFlipDuration = Duration(milliseconds: 300);
  static const Duration matchDelay = Duration(milliseconds: 500);
  static const Duration mismatchDelay = Duration(milliseconds: 1000);
  
  // Cascada de Animales
  static const double cascadeSpawnInterval = 2.0; // segundos
  static const double cascadeFallSpeed = 100.0; // píxeles por segundo
  static const int cascadeMaxStackHeight = 10;
  
  // Adivina el Animal
  static const int guessRevealInterval = 3; // segundos
  static const int guessMaxRevealLevels = 5;
  static const List<String> easyAnimals = ['🐶', '🐱', '🐭', '🐹', '🐰'];
  static const List<String> mediumAnimals = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯'];
  static const List<String> hardAnimals = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵'];
}
