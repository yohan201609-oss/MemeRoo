import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jigsaw_provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../utils/ad_manager.dart';
import '../utils/ad_frequency_manager.dart';
import '../utils/audio_manager.dart';
import 'jigsaw_game_screen.dart';
import 'main_menu_screen.dart';

class JigsawHomeScreen extends StatefulWidget {
  const JigsawHomeScreen({super.key});

  @override
  State<JigsawHomeScreen> createState() => _JigsawHomeScreenState();
}

class _JigsawHomeScreenState extends State<JigsawHomeScreen> {
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainMenuScreen(),
                          ),
                        );
                      },
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🧩',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rompecabezas',
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
                  'Arrastra las piezas para completar el puzzle',
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
                            subtitle: '2×2 = 4 piezas\nMejor tiempo: ${_formatTime(snapshot.data?['easy_time'] ?? 999)}',
                            stars: snapshot.data?['easy'] ?? 0,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 24),
                          _buildLevelButton(
                            context,
                            level: 'medium',
                            title: 'Medio',
                            subtitle: '2×3 = 6 piezas\nMejor tiempo: ${_formatTime(snapshot.data?['medium_time'] ?? 999)}',
                            stars: snapshot.data?['medium'] ?? 0,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 24),
                          _buildLevelButton(
                            context,
                            level: 'hard',
                            title: 'Difícil',
                            subtitle: '3×3 = 9 piezas\nMejor tiempo: ${_formatTime(snapshot.data?['hard_time'] ?? 999)}',
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

  Future<Map<String, dynamic>> _getStats() async {
    final provider = context.read<JigsawProvider>();
    return {
      'easy': await provider.getBestStars('easy'),
      'medium': await provider.getBestStars('medium'),
      'hard': await provider.getBestStars('hard'),
      'easy_time': await provider.getBestTime('easy'),
      'medium_time': await provider.getBestTime('medium'),
      'hard_time': await provider.getBestTime('hard'),
    };
  }

  String _formatTime(int seconds) {
    if (seconds >= 999) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
        AudioManager().playTap();
        
        // Mostrar interstitial si está disponible y cumple con la frecuencia
        if (AdFrequencyManager.canShowInterstitial()) {
          AdManager().showInterstitialAd();
          AdFrequencyManager.markInterstitialShown();
        }
        
        // Actualizar GameProvider con el nombre del juego para el sistema de pistas
        context.read<GameProvider>().initializeGame(level, gameName: 'jigsaw');
        
        // Inicializar juego
        final size = MediaQuery.of(context).size;
        context.read<JigsawProvider>().initializeGame(level, size);
        
        // Pequeño delay para que se muestre el anuncio antes de navegar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JigsawGameScreen()),
            );
          }
        });
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

