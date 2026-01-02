import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';
import '../widgets/help_button.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Botón de volver y ayuda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () {
                        AudioManager().playTap();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainMenuScreen(),
                          ),
                        );
                      },
                      color: Colors.black87,
                    ),
                    HelpButton(gameKey: 'memory'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🎴',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 12),
              const Text(
                '¡Encuentra las Parejas!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLevelButton(
                        context,
                        level: 'easy',
                        title: 'Fácil',
                        subtitle: '6 cartas',
                        stars: '⭐',
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(height: 24),
                      _buildLevelButton(
                        context,
                        level: 'medium',
                        title: 'Medio',
                        subtitle: '12 cartas',
                        stars: '⭐⭐',
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(height: 24),
                      _buildLevelButton(
                        context,
                        level: 'hard',
                        title: 'Difícil',
                        subtitle: '16 cartas',
                        stars: '⭐⭐⭐',
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context, {
    required String level,
    required String title,
    required String subtitle,
    required String stars,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        AudioManager().playTap();
        context.read<GameProvider>().initializeGame(level);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      },
      child: Container(
        width: 280,
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stars,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

