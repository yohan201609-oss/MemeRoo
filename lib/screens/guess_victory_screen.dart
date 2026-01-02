import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/guess_provider.dart';
import '../utils/colors.dart';
import 'main_menu_screen.dart';
import 'guess_home_screen.dart';
import 'guess_game_screen.dart';

class GuessVictoryScreen extends StatefulWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String level;

  const GuessVictoryScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.level,
  });

  @override
  State<GuessVictoryScreen> createState() => _GuessVictoryScreenState();
}

class _GuessVictoryScreenState extends State<GuessVictoryScreen> {
  late ConfettiController _controller;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _controller.play();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final provider = context.read<GuessProvider>();
    // El provider ya calculó las estrellas, solo necesitamos obtenerlas
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Felicitaciones!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Completaste el nivel ${_getLevelName(widget.level)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '⭐' * _stars,
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getStarMessage(_stars),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Puntos: ${widget.score}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Correctas: ${widget.correctAnswers}/${widget.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildButton(
                      context,
                      'Reintentar',
                      Icons.refresh,
                      Colors.orange,
                      () {
                        context.read<GuessProvider>().resetGame();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuessGameScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      context,
                      'Niveles',
                      Icons.list,
                      Colors.blue,
                      () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuessHomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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
                  ],
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        text,
        style: const TextStyle(fontSize: 20),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 8,
      ),
    );
  }
}

