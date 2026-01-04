import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/guess_provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../widgets/pixelated_image_widget.dart';
import '../widgets/hint_button.dart';
import 'guess_victory_screen.dart';
import 'main_menu_screen.dart';

class GuessGameScreen extends StatefulWidget {
  const GuessGameScreen({super.key});

  @override
  State<GuessGameScreen> createState() => _GuessGameScreenState();
}

class _GuessGameScreenState extends State<GuessGameScreen> {
  String? _currentHint;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuessProvider>();

    // Navegar a la pantalla de victoria cuando el juego termine
    if (provider.gameState == GuessGameState.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GuessVictoryScreen(
              score: provider.score,
              correctAnswers: provider.correctAnswers,
              totalQuestions: provider.totalQuestions,
              level: provider.currentLevel,
            ),
          ),
        );
      });
    }

    final question = provider.currentQuestion;
    if (question == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Imagen pixelada del animal
                      PixelatedImageWidget(
                        emoji: question.emoji,
                        revealLevel: question.revealLevel,
                      ),
                      const SizedBox(height: 40),
                      
                      // Pregunta
                      const Text(
                        '¿Qué animal es?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Opciones de respuesta
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: question.options.length,
                          itemBuilder: (context, index) {
                            final option = question.options[index];
                            final isCorrect = option == question.correctAnswer;
                            final isSelected = provider.hasAnswered && isCorrect;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ElevatedButton(
                                onPressed: provider.hasAnswered
                                    ? null
                                    : () {
                                        provider.answerQuestion(option);
                                        // Esperar un momento antes de pasar a la siguiente pregunta
                                        Future.delayed(
                                          const Duration(seconds: 2),
                                          () {
                                            if (provider.gameState != GuessGameState.won) {
                                              provider.nextQuestion();
                                            }
                                          },
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: provider.hasAnswered
                                      ? (isSelected
                                          ? Colors.green
                                          : Colors.grey.shade300)
                                      : Colors.white,
                                  foregroundColor: provider.hasAnswered
                                      ? (isSelected ? Colors.white : Colors.black54)
                                      : Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: provider.hasAnswered ? 0 : 4,
                                ),
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildHintSection(context),
              _buildFooter(context, provider),
            ],
          ),
        ),
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

  Widget _buildHeader(BuildContext context, GuessProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => _showExitDialog(context),
            color: Colors.black87,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pregunta: ${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Puntos: ${provider.score}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Espacio para balancear
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, GuessProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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

