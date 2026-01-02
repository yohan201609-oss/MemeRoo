import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/jigsaw_provider.dart';
import '../utils/colors.dart';
import 'main_menu_screen.dart';
import 'jigsaw_game_screen.dart';
import 'jigsaw_home_screen.dart';

class JigsawVictoryScreen extends StatefulWidget {
  final int seconds;
  final String level;

  const JigsawVictoryScreen({
    super.key,
    required this.seconds,
    required this.level,
  });

  @override
  State<JigsawVictoryScreen> createState() => _JigsawVictoryScreenState();
}

class _JigsawVictoryScreenState extends State<JigsawVictoryScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _controller.play();
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<JigsawProvider>();
    final stars = provider.getStars();

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
                      style: TextStyle(fontSize: 60),
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
                      '⭐' * stars,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getStarMessage(stars),
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
                    // Botón de siguiente nivel o jugar de nuevo
                    if (_getNextLevel(widget.level) != null)
                      _buildButton(
                        context,
                        'Siguiente Nivel',
                        Icons.arrow_forward,
                        Colors.green,
                        () {
                          final nextLevel = _getNextLevel(widget.level)!;
                          final size = MediaQuery.of(context).size;
                          provider.initializeGame(nextLevel, size);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JigsawGameScreen(),
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
                        final size = MediaQuery.of(context).size;
                        provider.initializeGame(widget.level, size);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JigsawGameScreen(),
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
                            builder: (_) => const JigsawHomeScreen(),
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

  String? _getNextLevel(String level) {
    switch (level) {
      case 'easy':
        return 'medium';
      case 'medium':
        return 'hard';
      default:
        return null;
    }
  }

  String _getStarMessage(int stars) {
    switch (stars) {
      case 3:
        return '¡Perfecto!';
      case 2:
        return '¡Muy bien!';
      case 1:
        return '¡Bien hecho!';
      default:
        return '¡Completado!';
    }
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
            vertical: 12,
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

