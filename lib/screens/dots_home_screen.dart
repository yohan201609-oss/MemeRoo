import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dots_provider.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';
import '../widgets/help_button.dart';
import 'dots_game_screen.dart';
import 'main_menu_screen.dart';

class DotsHomeScreen extends StatefulWidget {
  const DotsHomeScreen({super.key});

  @override
  State<DotsHomeScreen> createState() => _DotsHomeScreenState();
}

class _DotsHomeScreenState extends State<DotsHomeScreen> {
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
                    HelpButton(gameKey: 'dots'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '✏️',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 12),
              const Text(
                'Conecta los Puntos',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Une los números en orden para revelar el animal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getStats(),
                  builder: (context, snapshot) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildLevelButton(
                            context,
                            level: 'easy',
                            title: 'Fácil',
                            subtitle: '10 puntos\nMejor tiempo: ${_formatTime(snapshot.data?['easy_time'] ?? 999)}',
                            stars: snapshot.data?['easy'] ?? 0,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 24),
                          _buildLevelButton(
                            context,
                            level: 'medium',
                            title: 'Medio',
                            subtitle: '15 puntos\nMejor tiempo: ${_formatTime(snapshot.data?['medium_time'] ?? 999)}',
                            stars: snapshot.data?['medium'] ?? 0,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 24),
                          _buildLevelButton(
                            context,
                            level: 'hard',
                            title: 'Difícil',
                            subtitle: '20 puntos\nMejor tiempo: ${_formatTime(snapshot.data?['hard_time'] ?? 999)}',
                            stars: snapshot.data?['hard'] ?? 0,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds >= 999) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _getStats() async {
    final provider = context.read<DotsProvider>();
    return {
      'easy': await provider.getBestStars('easy'),
      'medium': await provider.getBestStars('medium'),
      'hard': await provider.getBestStars('hard'),
      'easy_time': await provider.getBestTime('easy'),
      'medium_time': await provider.getBestTime('medium'),
      'hard_time': await provider.getBestTime('hard'),
    };
  }

  Widget _buildLevelButton(
    BuildContext context, {
    required String level,
    required String title,
    required String subtitle,
    required int stars,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<DotsProvider>().initializeGame(level);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DotsGameScreen()),
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: index < stars ? Colors.amber : Colors.white70,
                  size: 24,
                );
              }),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

