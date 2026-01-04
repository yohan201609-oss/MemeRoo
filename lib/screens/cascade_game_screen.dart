import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cascade_provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../widgets/falling_animal_widget.dart';
import '../widgets/hint_button.dart';
import 'cascade_victory_screen.dart';
import 'main_menu_screen.dart';

class CascadeGameScreen extends StatefulWidget {
  const CascadeGameScreen({super.key});

  @override
  State<CascadeGameScreen> createState() => _CascadeGameScreenState();
}

class _CascadeGameScreenState extends State<CascadeGameScreen> {
  final GlobalKey _stackKey = GlobalKey();
  String? _currentHint;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CascadeProvider>();

    // Navegar a la pantalla de victoria o game over
    if (provider.gameState == CascadeGameState.won ||
        provider.gameState == CascadeGameState.lost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CascadeVictoryScreen(
              score: provider.score,
              targetScore: provider.targetScore,
              level: provider.currentLevel,
              isWon: provider.gameState == CascadeGameState.won,
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, provider),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gameWidth = constraints.maxWidth;
                    final gameHeight = constraints.maxHeight;

                    // Notificar al provider del tamaño solo una vez
                    if (gameWidth > 0 && gameHeight > 0) {
                      provider.setGameAreaSize(gameWidth, gameHeight);
                    }

                    return Stack(
                      key: _stackKey,
                      children: [
                        // Área de juego - SOLO los animales
                        ...provider.animals.map((animal) {
                          return Positioned(
                            left: animal.x * gameWidth - animal.size / 2,
                            top: animal.y * gameHeight - animal.size / 2,
                            child: FallingAnimalWidget(
                              animal: animal,
                              gameWidth: gameWidth,
                              gameHeight: gameHeight,
                              onDragStart: (id, globalX, globalY) {
                                // Convertir coordenada global a local del Stack
                                final RenderBox? box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                                if (box != null) {
                                  final localPosition = box.globalToLocal(Offset(globalX, globalY));
                                  provider.startDrag(id, localPosition.dx, localPosition.dy);
                                } else {
                                  provider.startDrag(id, globalX, globalY);
                                }
                              },
                              onDragUpdate: (globalX, globalY) {
                                // Convertir coordenada global a local del Stack
                                final RenderBox? box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                                if (box != null) {
                                  final localPosition = box.globalToLocal(Offset(globalX, globalY));
                                  provider.updateDrag(localPosition.dx, localPosition.dy);
                                } else {
                                  provider.updateDrag(globalX, globalY);
                                }
                              },
                              onDragEnd: () {
                                provider.endDrag();
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
              _buildFooter(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CascadeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => _showExitDialog(context),
                color: Colors.black87,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Puntos: ${provider.score}/${provider.targetScore}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 150,
                      child: LinearProgressIndicator(
                        value: (provider.score / provider.targetScore).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          provider.score >= provider.targetScore
                              ? Colors.green
                              : Colors.blue,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                icon: Icons.touch_app,
                label: 'Movimientos',
                value: '${provider.movesLeft}',
                color: provider.movesLeft <= 5 ? Colors.red : Colors.blue,
              ),
              _buildStatChip(
                icon: Icons.timer,
                label: 'Tiempo',
                value: '${provider.timeLeft}s',
                color: provider.timeLeft <= 10 ? Colors.red : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentHint != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade300,
                    width: 2,
                  ),
                ),
                child: Text(
                  _currentHint!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          if (_currentHint != null) const SizedBox(width: 12),
          HintButton(
            onHintRevealed: (hint) {
              setState(() => _currentHint = hint);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, CascadeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              provider.resetGame();
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Reiniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showExitDialog(context),
            icon: const Icon(Icons.home, size: 20),
            label: const Text('Inicio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Salir del juego?'),
          content: const Text(
              '¿Estás seguro de que quieres volver al menú principal? Tu progreso actual se perderá.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainMenuScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }
}

