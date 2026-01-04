import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cascade_provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../utils/ad_manager.dart';
import '../utils/ad_frequency_manager.dart';
import '../utils/audio_manager.dart';
import '../utils/responsive_helper.dart';
import 'cascade_game_screen.dart';
import 'main_menu_screen.dart';

class CascadeHomeScreen extends StatefulWidget {
  const CascadeHomeScreen({super.key});

  @override
  State<CascadeHomeScreen> createState() => _CascadeHomeScreenState();
}

class _CascadeHomeScreenState extends State<CascadeHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    await Future.delayed(Duration.zero);
    setState(() {});
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
                '💧',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cascada de Animales',
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
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLevelButton(
                            context,
                            level: 'easy',
                            title: 'Fácil',
                            subtitle: 'Meta: 100 puntos\n20 movimientos • 60s',
                            stars: _getStarsDisplay(snapshot.data?['easy'] ?? 0),
                            color: Colors.green.shade300,
                          ),
                          SizedBox(height: ResponsiveHelper.isTablet(context) ? 32 : 24),
                          _buildLevelButton(
                            context,
                            level: 'medium',
                            title: 'Medio',
                            subtitle: 'Meta: 200 puntos\n25 movimientos • 90s',
                            stars: _getStarsDisplay(snapshot.data?['medium'] ?? 0),
                            color: Colors.orange.shade300,
                          ),
                          SizedBox(height: ResponsiveHelper.isTablet(context) ? 32 : 24),
                          _buildLevelButton(
                            context,
                            level: 'hard',
                            title: 'Difícil',
                            subtitle: 'Meta: 300 puntos\n30 movimientos • 120s',
                            stars: _getStarsDisplay(snapshot.data?['hard'] ?? 0),
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

  Future<Map<String, int>> _getStars() async {
    final provider = context.read<CascadeProvider>();
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
        context.read<GameProvider>().initializeGame(level, gameName: 'cascade');
        
        // Inicializar juego
        context.read<CascadeProvider>().initializeGame(level);
        
        // Pequeño delay para que se muestre el anuncio antes de navegar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CascadeGameScreen()),
            );
          }
        });
      },
      child: Container(
        width: ResponsiveHelper.isTablet(context) ? 360 : 280,
        constraints: BoxConstraints(
          minHeight: ResponsiveHelper.isTablet(context) ? 120 : 100,
        ),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
          horizontal: ResponsiveHelper.isTablet(context) ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.isTablet(context) ? 24 : 20,
          ),
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
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
              ),
            ),
            SizedBox(height: ResponsiveHelper.isTablet(context) ? 8 : 6),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveHelper.isTablet(context) ? 4 : 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
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

