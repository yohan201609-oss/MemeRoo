import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guess_provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../utils/ad_manager.dart';
import '../utils/ad_frequency_manager.dart';
import '../utils/audio_manager.dart';
import 'guess_game_screen.dart';
import 'main_menu_screen.dart';

class GuessHomeScreen extends StatefulWidget {
  const GuessHomeScreen({super.key});

  @override
  State<GuessHomeScreen> createState() => _GuessHomeScreenState();
}

class _GuessHomeScreenState extends State<GuessHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

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
              // Botón de volver
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
                '🔍',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 12),
              const Text(
                'Adivina el Animal',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: _getStars(),
                  builder: (context, snapshot) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLevelButton(
                          context,
                          level: 'easy',
                          title: 'Fácil',
                          subtitle: '5 animales comunes',
                          stars: _getStarsDisplay(snapshot.data?['easy'] ?? 0),
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 24),
                        _buildLevelButton(
                          context,
                          level: 'medium',
                          title: 'Medio',
                          subtitle: '10 animales variados',
                          stars: _getStarsDisplay(snapshot.data?['medium'] ?? 0),
                          color: Colors.orange.shade300,
                        ),
                        const SizedBox(height: 24),
                        _buildLevelButton(
                          context,
                          level: 'hard',
                          title: 'Difícil',
                          subtitle: '15 animales (incluyendo raros)',
                          stars: _getStarsDisplay(snapshot.data?['hard'] ?? 0),
                          color: Colors.red.shade300,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, int>> _getStars() async {
    final provider = context.read<GuessProvider>();
    return {
      'easy': await provider.getBestStars('easy'),
      'medium': await provider.getBestStars('medium'),
      'hard': await provider.getBestStars('hard'),
    };
  }

  String _getStarsDisplay(int stars) {
    return '⭐' * stars;
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
        
        // Mostrar interstitial si está disponible y cumple con la frecuencia
        if (AdFrequencyManager.canShowInterstitial()) {
          AdManager().showInterstitialAd();
          AdFrequencyManager.markInterstitialShown();
        }
        
        // Actualizar GameProvider con el nombre del juego para el sistema de pistas
        context.read<GameProvider>().initializeGame(level, gameName: 'guess');
        
        // Inicializar juego
        context.read<GuessProvider>().initializeGame(level);
        
        // Pequeño delay para que se muestre el anuncio antes de navegar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuessGameScreen()),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stars.isEmpty ? '⭐' : stars,
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

