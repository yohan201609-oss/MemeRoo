import '../models/tutorial_step.dart';

class TutorialData {
  static final Map<String, List<TutorialStep>> tutorials = {
    'memory': [
      TutorialStep(
        title: '¡Encuentra las Parejas!',
        description: 'Voltea las cartas para encontrar animales iguales',
        emoji: '🎴',
      ),
      TutorialStep(
        title: 'Toca una carta',
        description: 'Toca cualquier carta para voltearla y ver el animal',
        emoji: '👆',
      ),
      TutorialStep(
        title: 'Busca su pareja',
        description: 'Toca otra carta. Si son iguales, ¡se quedan volteadas!',
        emoji: '✨',
      ),
      TutorialStep(
        title: '¡Encuentra todas!',
        description: 'Gana encontrando todas las parejas en menos movimientos',
        emoji: '🏆',
      ),
    ],
    'cascade': [
      TutorialStep(
        title: 'Cascada de Animales',
        description: 'Los animales aparecen desde arriba',
        emoji: '💧',
      ),
      TutorialStep(
        title: 'Arrastra los animales',
        description: 'Mueve los animales a la izquierda o derecha',
        emoji: '👈👉',
      ),
      TutorialStep(
        title: 'Haz grupos',
        description: 'Junta 2 o más animales iguales para que desaparezcan',
        emoji: '🎯',
      ),
      TutorialStep(
        title: '¡Alcanza la meta!',
        description: 'Consigue puntos antes de que se acabe el tiempo',
        emoji: '⏱️',
      ),
    ],
    'sequence': [
      TutorialStep(
        title: 'Secuencia Animal',
        description: 'Memoriza la secuencia de animales',
        emoji: '🎵',
      ),
      TutorialStep(
        title: 'Observa bien',
        description: 'Los animales se iluminarán en orden',
        emoji: '👀',
      ),
      TutorialStep(
        title: 'Repite la secuencia',
        description: 'Toca los animales en el mismo orden',
        emoji: '🎮',
      ),
      TutorialStep(
        title: '¡Cada vez más largo!',
        description: 'La secuencia crece con cada ronda',
        emoji: '📈',
      ),
    ],
    'jigsaw': [
      TutorialStep(
        title: 'Rompecabezas',
        description: 'Arrastra las piezas a su lugar correcto',
        emoji: '🧩',
      ),
      TutorialStep(
        title: 'Mira las siluetas',
        description: 'Cada pieza tiene su lugar en el tablero',
        emoji: '👁️',
      ),
      TutorialStep(
        title: 'Arrastra y suelta',
        description: 'Arrastra una pieza cerca de su lugar y se pegará',
        emoji: '✋',
      ),
      TutorialStep(
        title: '¡Completa la imagen!',
        description: 'Gana colocando todas las piezas correctamente',
        emoji: '🎨',
      ),
    ],
    'guess': [
      TutorialStep(
        title: 'Adivina el Animal',
        description: 'La imagen está borrosa al inicio',
        emoji: '🔍',
      ),
      TutorialStep(
        title: 'Se va revelando',
        description: 'Cada pocos segundos la imagen se aclara más',
        emoji: '⏳',
      ),
      TutorialStep(
        title: 'Elige la respuesta',
        description: 'Toca el animal que crees que es',
        emoji: '🤔',
      ),
      TutorialStep(
        title: '¡Más rápido = más puntos!',
        description: 'Adivina antes para ganar más puntos',
        emoji: '⚡',
      ),
    ],
    'shadow': [
      TutorialStep(
        title: 'Sombras',
        description: 'Verás la sombra negra de un animal',
        emoji: '🌑',
      ),
      TutorialStep(
        title: 'Mira las opciones',
        description: 'Abajo verás varios animales en color',
        emoji: '🎨',
      ),
      TutorialStep(
        title: 'Elige el correcto',
        description: 'Toca el animal que corresponde a la sombra',
        emoji: '👆',
      ),
      TutorialStep(
        title: '¡Acierta todas!',
        description: 'Completa todas las rondas para ganar',
        emoji: '🎯',
      ),
    ],
    'riddle': [
      TutorialStep(
        title: '¿Quién Soy?',
        description: 'Lee las pistas sobre el animal',
        emoji: '🤔',
      ),
      TutorialStep(
        title: 'Usa las pistas',
        description: 'Cada pista te da más información',
        emoji: '💡',
      ),
      TutorialStep(
        title: 'Adivina rápido',
        description: 'Menos pistas = más puntos',
        emoji: '⚡',
      ),
      TutorialStep(
        title: 'Pide ayuda',
        description: 'Si no sabes, pide la siguiente pista',
        emoji: '❓',
      ),
    ],
    'dots': [
      TutorialStep(
        title: 'Conecta los Puntos',
        description: 'Une los números en orden',
        emoji: '✏️',
      ),
      TutorialStep(
        title: 'Empieza por el 1',
        description: 'Toca el número 1 primero',
        emoji: '1️⃣',
      ),
      TutorialStep(
        title: 'Sigue en orden',
        description: 'Luego toca el 2, después el 3...',
        emoji: '🔢',
      ),
      TutorialStep(
        title: '¡Descubre el animal!',
        description: 'Al terminar se revelará el animal completo',
        emoji: '🎨',
      ),
    ],
  };

  static List<TutorialStep> getTutorial(String gameKey) {
    return tutorials[gameKey] ?? [];
  }
}

