import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';
import 'main_menu_screen.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class VictoryScreen extends StatefulWidget {
  final int moves;
  final String level;

  const VictoryScreen({
    super.key,
    required this.moves,
    required this.level,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _controller.play();
    AudioManager().playWin();
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
                      '⭐' * GameConstants.calculateStars(widget.level, widget.moves),
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      GameConstants.getStarMessage(
                        GameConstants.calculateStars(widget.level, widget.moves),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Movimientos: ${widget.moves}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botón de siguiente nivel o jugar de nuevo
                    if (GameConstants.getNextLevel(widget.level) != null)
                      _buildButton(
                        context,
                        'Siguiente Nivel',
                        Icons.arrow_forward,
                        Colors.green,
                        () {
                          final nextLevel = GameConstants.getNextLevel(widget.level)!;
                          context.read<GameProvider>().startGame(nextLevel);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GameScreen(),
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
                        context.read<GameProvider>().startGame(widget.level);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
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
                            builder: (_) => const HomeScreen(),
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

