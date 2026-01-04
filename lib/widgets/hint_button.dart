import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/ad_manager.dart';

class HintButton extends StatefulWidget {
  final Function(String hint) onHintRevealed;
  
  const HintButton({
    super.key,
    required this.onHintRevealed,
  });

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton> {
  bool _isLoading = false;

  void _showHintDialog() {
    final gameProvider = context.read<GameProvider>();
    
    if (!gameProvider.canUseHint) {
      _showMaxHintsDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber[700], size: 32),
            const SizedBox(width: 12),
            const Text(
              '💡 ¿Necesitas Ayuda?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás atascado? ¡No te preocupes! 🤔',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.purple[50]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.play_circle_filled, 
                    color: Colors.blue[600], 
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Mira un video corto y te daré una pista especial',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pistas restantes: ${gameProvider.hintsRemaining}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _watchAdForHint();
            },
            icon: const Icon(Icons.play_arrow, size: 22),
            label: const Text(
              'Ver Video',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  void _watchAdForHint() {
    setState(() => _isLoading = true);

    if (!AdManager().isRewardedLoaded) {
      AdManager().loadRewardedAd();
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (AdManager().isRewardedLoaded) {
            _showRewardedAd();
          } else {
            _showAdNotReadyDialog();
          }
        }
      });
    } else {
      _showRewardedAd();
    }
  }

  void _showRewardedAd() {
    AdManager().showRewardedAd(
      onUserEarnedReward: () {
        if (!mounted) return;
        
        final gameProvider = context.read<GameProvider>();
        gameProvider.useHint();
        
        final hint = _generateHint();
        
        setState(() => _isLoading = false);
        
        widget.onHintRevealed(hint);
        _showHintRevealedDialog(hint);
        
        print('📊 Pista ${gameProvider.hintsUsed} usada en ${gameProvider.currentGame}');
      },
    );
  }

  // ========== SISTEMA DE PISTAS INTELIGENTE ==========
  
  String _generateHint() {
    final gameProvider = context.read<GameProvider>();
    final gameName = gameProvider.currentGame;
    final hintNumber = gameProvider.hintsUsed;

    // Pistas según el juego
    switch (gameName.toLowerCase()) {
      case 'differences':
      case 'diferencias':
        return _getDifferencesHint(hintNumber);
      
      case 'memory':
      case 'memoria':
        return _getMemoryHint(hintNumber);
      
      case 'puzzle':
      case 'rompecabezas':
      case 'jigsaw':
        return _getPuzzleHint(hintNumber);
      
      case 'sequence':
      case 'secuencia':
        return _getSequenceHint(hintNumber);
      
      case 'cascade':
        return _getCascadeHint(hintNumber);
      
      case 'guess':
        return _getGuessHint(hintNumber);
      
      case 'shadow':
        return _getShadowHint(hintNumber);
      
      case 'riddle':
        return _getRiddleHint(hintNumber);
      
      case 'dots':
        return _getDotsHint(hintNumber);
      
      default:
        return _getGenericHint(hintNumber);
    }
  }

  // ===== PISTAS: ENCUENTRA LAS DIFERENCIAS =====
  String _getDifferencesHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '🔍 Busca en las ESQUINAS de la imagen. Las diferencias suelen esconderse ahí';
      case 2:
        return '👀 Fíjate bien en los COLORES. Algo cambió de color entre las dos imágenes';
      case 3:
        return '✨ Mira cerca del CENTRO de la imagen. Hay algo diferente en los detalles pequeños';
      default:
        return '🎯 Compara cada sección con calma';
    }
  }

  // ===== PISTAS: MEMORY MATCH =====
  String _getMemoryHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '🧠 Empieza por las ESQUINAS. Son más fáciles de recordar porque están en los bordes';
      case 2:
        return '🎯 Intenta voltear cartas en FILA. Así puedes recordar mejor dónde están los pares';
      case 3:
        return '💡 Las cartas que buscas están en la MITAD SUPERIOR del tablero. ¡Tú puedes!';
      default:
        return '🌟 Concéntrate y recuerda las posiciones';
    }
  }

  // ===== PISTAS: PUZZLE SLIDER =====
  String _getPuzzleHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '🧩 PRIMERO completa la fila de ARRIBA. Es más fácil empezar desde arriba';
      case 2:
        return '⬆️ Mueve las piezas hacia ARRIBA primero, luego hacia los lados';
      case 3:
        return '🎲 La pieza que necesitas mover está en la DERECHA. Muévela hacia el espacio vacío';
      default:
        return '🔄 Mueve una pieza a la vez con paciencia';
    }
  }

  // ===== PISTAS: SECUENCIAS =====
  String _getSequenceHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '🔢 Busca un PATRÓN. Los números o colores se repiten de alguna forma';
      case 2:
        return '➕ Fíjate si los números SUBEN o BAJAN. Puede ser +1, +2 o -1';
      case 3:
        return '🌈 Si son colores, sigue el orden del ARCOÍRIS: rojo, naranja, amarillo, verde, azul';
      default:
        return '🎯 Observa cómo cambian los elementos';
    }
  }

  // ===== PISTAS: CASCADA =====
  String _getCascadeHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '💧 Toca RÁPIDAMENTE los animales que caen antes de que se acumulen';
      case 2:
        return '🎯 Prioriza los animales que están MÁS ABAJO en la pila';
      case 3:
        return '⚡ Mantén la CALMA y toca con PRECISIÓN. ¡Tú puedes!';
      default:
        return '💪 Sigue intentando';
    }
  }

  // ===== PISTAS: ADIVINA EL ANIMAL =====
  String _getGuessHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '👁️ Observa CUIDADOSAMENTE las formas que se van revelando';
      case 2:
        return '🤔 Piensa en animales que tengan esas CARACTERÍSTICAS';
      case 3:
        return '✨ El animal se está REVELANDO. Observa bien los detalles finales';
      default:
        return '🔍 Sigue observando';
    }
  }

  // ===== PISTAS: SOMBRAS =====
  String _getShadowHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '🌑 Compara la FORMA de la sombra con los animales disponibles';
      case 2:
        return '📏 La SILUETA te da pistas sobre el TAMAÑO y forma del animal';
      case 3:
        return '🔍 Compara CADA opción con la sombra cuidadosamente';
      default:
        return '👀 Observa las formas';
    }
  }

  // ===== PISTAS: ADIVINANZAS =====
  String _getRiddleHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '📖 Lee TODAS las pistas cuidadosamente antes de responder';
      case 2:
        return '❌ Elimina las opciones que NO coinciden con todas las pistas';
      case 3:
        return '🎯 Piensa en el animal que mejor ENCAJA con todas las pistas';
      default:
        return '💭 Piensa con calma';
    }
  }

  // ===== PISTAS: CONECTA LOS PUNTOS =====
  String _getDotsHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '🔢 Sigue los números en ORDEN del 1 al último';
      case 2:
        return '📏 Conecta los puntos formando LÍNEAS SUAVES';
      case 3:
        return '✨ Sigue el orden numérico SIN SALTARTE ningún punto';
      default:
        return '🎯 Sigue la secuencia';
    }
  }

  // ===== PISTAS GENÉRICAS =====
  String _getGenericHint(int hintNumber) {
    switch (hintNumber) {
      case 1:
        return '👀 Mira con atención cada detalle. La respuesta está frente a ti';
      case 2:
        return '🎯 Divide el problema en partes pequeñas. Resuelve una cosa a la vez';
      case 3:
        return '💪 ¡Casi lo logras! Confía en lo que has visto hasta ahora';
      default:
        return '🌟 Sigue intentando, tú puedes';
    }
  }

  // ========== DIÁLOGOS ==========

  void _showHintRevealedDialog(String hint) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.tips_and_updates, color: Colors.amber[600], size: 36),
            const SizedBox(width: 12),
            const Text(
              '💡 ¡Pista!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[50]!, Colors.orange[50]!],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[300]!, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hint,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '¡Úsala sabiamente! 🎯',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                '¡Entendido! 🚀',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaxHintsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red[400], size: 32),
            const SizedBox(width: 12),
            const Text(
              '❌ Sin Pistas',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ya usaste todas las pistas para este nivel.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    '¡Casi lo logras! 💪',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sigue intentando,\ntú puedes hacerlo 🌟',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Seguir Intentando 🎯',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdNotReadyDialog() {
    setState(() => _isLoading = false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange[600]),
            const SizedBox(width: 12),
            const Text('⏳ Espera'),
          ],
        ),
        content: const Text(
          'El video aún está cargando.\n\nIntenta de nuevo en unos segundos.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gameProvider.canUseHint
              ? [Colors.amber[400]!, Colors.orange[500]!]
              : [Colors.grey[400]!, Colors.grey[500]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gameProvider.canUseHint
                ? Colors.orange.withOpacity(0.4)
                : Colors.black.withOpacity(0.2),
            blurRadius: gameProvider.canUseHint ? 12 : 8,
            spreadRadius: gameProvider.canUseHint ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: gameProvider.canUseHint && !_isLoading
              ? _showHintDialog
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 28,
                  ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pista',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${gameProvider.hintsRemaining} restantes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
