import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/dots_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';
import 'main_menu_screen.dart';
import 'dots_home_screen.dart';
import 'dots_game_screen.dart';

class DotsVictoryScreen extends StatefulWidget {
  final int seconds;
  final String level;
  final String animal;

  const DotsVictoryScreen({
    super.key,
    required this.seconds,
    required this.level,
    required this.animal,
  });

  @override
  State<DotsVictoryScreen> createState() => _DotsVictoryScreenState();
}

class _DotsVictoryScreenState extends State<DotsVictoryScreen> {
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
    final provider = context.read<DotsProvider>();
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                      const SizedBox(height: 20),
                      // Animal revelado
                      Text(
                        widget.animal,
                        style: const TextStyle(fontSize: 100),
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
                        'Tiempo: ${_formatTime(widget.seconds)}',
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
                            context.read<DotsProvider>().initializeGame(nextLevel);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DotsGameScreen(),
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
                          context.read<DotsProvider>().resetGame();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DotsGameScreen(),
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
                              builder: (_) => const DotsHomeScreen(),
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

