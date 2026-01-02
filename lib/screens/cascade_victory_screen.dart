import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/cascade_provider.dart';
import '../utils/colors.dart';
import 'main_menu_screen.dart';
import 'cascade_home_screen.dart';
import 'cascade_game_screen.dart';

class CascadeVictoryScreen extends StatefulWidget {
  final int score;
  final int targetScore;
  final String level;
  final bool isWon;

  const CascadeVictoryScreen({
    super.key,
    required this.score,
    required this.targetScore,
    required this.level,
    required this.isWon,
  });

  @override
  State<CascadeVictoryScreen> createState() => _CascadeVictoryScreenState();
}

class _CascadeVictoryScreenState extends State<CascadeVictoryScreen> {
  late ConfettiController _controller;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    if (widget.isWon) {
      _controller.play();
    }
    _loadStars();
  }

  Future<void> _loadStars() async {
    if (widget.isWon) {
      final provider = context.read<CascadeProvider>();
      setState(() {
        _stars = provider.getStars();
      });
    }
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
                    Text(
                      widget.isWon ? '🎉' : '😢',
                      style: const TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.isWon ? '¡Felicitaciones!' : 'Game Over',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.isWon
                          ? 'Completaste el nivel ${_getLevelName(widget.level)}'
                          : 'No alcanzaste la meta',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (widget.isWon) ...[
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
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Puntos: ${widget.score}/${widget.targetScore}',
                      style: const TextStyle(
                        fontSize: 20,
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
                        context.read<CascadeProvider>().resetGame();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CascadeGameScreen(),
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
                            builder: (_) => const CascadeHomeScreen(),
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
          if (widget.isWon)
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

