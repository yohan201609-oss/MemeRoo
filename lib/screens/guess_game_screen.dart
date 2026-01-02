import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/guess_provider.dart';
import '../utils/colors.dart';
import '../widgets/pixelated_image_widget.dart';
import 'guess_victory_screen.dart';
import 'main_menu_screen.dart';

class GuessGameScreen extends StatelessWidget {
  const GuessGameScreen({super.key});

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
              _buildFooter(context, provider),
            ],
          ),
        ),
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

