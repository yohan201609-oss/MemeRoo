import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/riddle_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';
import 'main_menu_screen.dart';
import 'riddle_home_screen.dart';
import 'riddle_game_screen.dart';

class RiddleVictoryScreen extends StatefulWidget {
  final int score;
  final int correctAnswers;
  final int totalRounds;
  final String level;

  const RiddleVictoryScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalRounds,
    required this.level,
  });

  @override
  State<RiddleVictoryScreen> createState() => _RiddleVictoryScreenState();
}

class _RiddleVictoryScreenState extends State<RiddleVictoryScreen> {
  late ConfettiController _controller;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _controller.play();
    AudioManager().playWin();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final provider = context.read<RiddleProvider>();
    setState(() {
      _stars = provider.getStars();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLevelName(String level) {
    switch (level) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Medio';
      case 'hard':
        return 'Difícil';
      default:
        return 'Desconocido';
    }
  }

  String _getStarMessage(int stars) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backGradient,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🎉',
                        style: TextStyle(fontSize: 70),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '¡Felicitaciones!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Completaste el nivel ${_getLevelName(widget.level)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '⭐' * _stars,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getStarMessage(_stars),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Puntos: ${widget.score}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Correctas: ${widget.correctAnswers}/${widget.totalRounds}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón de siguiente nivel o mensaje de juego completado
                      if (GameConstants.getNextLevel(widget.level) != null)
                        _buildButton(
                          context,
                          'Siguiente Nivel',
                          Icons.arrow_forward,
                          Colors.green,
                          () {
                            final nextLevel = GameConstants.getNextLevel(widget.level)!;
                            context.read<RiddleProvider>().initializeGame(nextLevel);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RiddleGameScreen(),
                              ),
                            );
                          },
                        )
                      else
                        _buildButton(
                          context,
                          '¡Juego Completado!',
                          Icons.emoji_events,
                          Colors.amber,
                          () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainMenuScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      const SizedBox(height: 12),
                      _buildButton(
                        context,
                        'Reintentar',
                        Icons.refresh,
                        Colors.orange,
                        () {
                          context.read<RiddleProvider>().resetGame();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RiddleGameScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildButton(
                        context,
                        'Niveles',
                        Icons.list,
                        Colors.blue,
                        () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RiddleHomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildButton(
                        context,
                        'Inicio',
                        Icons.home,
                        Colors.purple,
                        () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainMenuScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
        ),
      ),
    );
  }
}

