import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sequence_provider.dart';
import '../utils/colors.dart';
import 'sequence_game_screen.dart';
import 'main_menu_screen.dart';

class SequenceVictoryScreen extends StatelessWidget {
  final int rounds;
  final String level;
  final bool isWon;

  const SequenceVictoryScreen({
    super.key,
    required this.rounds,
    required this.level,
    required this.isWon,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SequenceProvider>();
    final stars = isWon ? provider.getStars() : 0;

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isWon ? '¡Felicitaciones!' : '¡Casi!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isWon ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (isWon) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            index < stars ? Icons.star : Icons.star_border,
                            size: 60,
                            color: index < stars ? Colors.amber : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Rondas completadas',
                          rounds.toString(),
                          Icons.repeat,
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          'Nivel',
                          _getLevelName(level),
                          Icons.emoji_events,
                        ),
                        if (!isWon) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '¡Inténtalo de nuevo!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.resetGame();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SequenceGameScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 24),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainMenuScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home, size: 24),
                        label: const Text('Inicio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
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
        return level;
    }
  }
}

