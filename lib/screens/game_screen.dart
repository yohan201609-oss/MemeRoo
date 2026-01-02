import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/card_widget.dart';
import '../widgets/help_button.dart';
import '../widgets/feedback_icon_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../utils/constants.dart';
import '../utils/colors.dart';
import '../utils/tutorial_data.dart';
import '../widgets/tutorial_dialog.dart';
import 'victory_screen.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    _showTutorialIfNeeded();
  }

  Future<void> _showTutorialIfNeeded() async {
    // Esperar a que se renderice la pantalla
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    final shouldShow = await TutorialDialog.shouldShow('memory');
    if (shouldShow) {
      final steps = TutorialData.getTutorial('memory');
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(
          steps: steps,
          gameKey: 'memory',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final levelConfig = GameConstants.levelConfig[gameProvider.currentLevel]!;
    final columns = levelConfig['columns']!;

    // Navegar a la pantalla de victoria cuando el juego termine
    if (gameProvider.gameState == GameState.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VictoryScreen(
              moves: gameProvider.moves,
              level: gameProvider.currentLevel,
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
              _buildHeader(context, gameProvider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight;
                      final totalCards = gameProvider.cards.length;
                      final rows = (totalCards / columns).ceil();
                      
                      // Calcular espacios totales
                      final totalHorizontalSpacing = GameConstants.cardSpacing * (columns - 1);
                      final totalVerticalSpacing = GameConstants.cardSpacing * (rows - 1);
                      
                      // Calcular tamaño máximo de celda
                      final maxCellWidth = (availableWidth - totalHorizontalSpacing) / columns;
                      final maxCellHeight = (availableHeight - totalVerticalSpacing) / rows;
                      
                      // Tomar el menor para mantener tarjetas cuadradas
                      final cellSize = (maxCellWidth < maxCellHeight ? maxCellWidth : maxCellHeight) * 0.9;
                      
                      return Center(
                        child: SizedBox(
                          width: (cellSize * columns) + totalHorizontalSpacing,
                          height: (cellSize * rows) + totalVerticalSpacing,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: GameConstants.cardSpacing,
                              mainAxisSpacing: GameConstants.cardSpacing,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: totalCards,
                            itemBuilder: (context, index) {
                              final card = gameProvider.cards[index];
                              return CardWidget(
                                card: card,
                                onTap: () => gameProvider.flipCard(card.id),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              _buildFooter(context, gameProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FeedbackIconButton(
            icon: Icons.arrow_back,
            onPressed: () async {
              final confirmed = await ConfirmationDialog.confirmExit(context);
              if (confirmed && mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainMenuScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            color: Colors.black87,
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Parejas: ${gameProvider.pairsFound}/${gameProvider.totalPairs}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Movimientos: ${gameProvider.moves}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Row(
            children: [
              HelpButton(gameKey: 'memory'),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  gameProvider.gameState == GameState.paused
                      ? Icons.play_arrow
                      : Icons.pause,
                  size: 28,
                ),
                onPressed: () {
                  if (gameProvider.gameState == GameState.paused) {
                    gameProvider.resumeGame();
                  } else {
                    gameProvider.pauseGame();
                  }
                },
                color: Colors.black87,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.confirmRestart(context);
              if (confirmed && mounted) {
                gameProvider.resetGame();
              }
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
            onPressed: () async {
              final confirmed = await ConfirmationDialog.confirmExit(context);
              if (confirmed && mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainMenuScreen(),
                  ),
                  (route) => false,
                );
              }
            },
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

}

