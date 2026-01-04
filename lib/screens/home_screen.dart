import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';
import '../utils/ad_manager.dart';
import '../utils/ad_frequency_manager.dart';
import '../utils/responsive_helper.dart';
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
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: ResponsiveHelper.getResponsiveIconSize(context, 28),
                      ),
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
              SizedBox(height: ResponsiveHelper.isTablet(context) ? 16 : 12),
              Text(
                '🎴',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isTablet(context) ? 80 : 60,
                ),
              ),
              SizedBox(height: ResponsiveHelper.isTablet(context) ? 16 : 12),
              Text(
                '¡Encuentra las Parejas!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 26),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.isTablet(context) ? 28 : 20),
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
                      SizedBox(height: ResponsiveHelper.isTablet(context) ? 32 : 24),
                      _buildLevelButton(
                        context,
                        level: 'medium',
                        title: 'Medio',
                        subtitle: '12 cartas',
                        stars: '⭐⭐',
                        color: Colors.orange.shade300,
                      ),
                      SizedBox(height: ResponsiveHelper.isTablet(context) ? 32 : 24),
                      _buildLevelButton(
                        context,
                        level: 'hard',
                        title: 'Difícil',
                        subtitle: '16 cartas',
                        stars: '⭐⭐⭐',
                        color: Colors.red.shade300,
                      ),
                      SizedBox(height: ResponsiveHelper.isTablet(context) ? 28 : 20),
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
    final isTablet = ResponsiveHelper.isTablet(context);
    return GestureDetector(
      onTap: () {
        AudioManager().playTap();
        
        // Mostrar interstitial si está disponible y cumple con la frecuencia
        if (AdFrequencyManager.canShowInterstitial()) {
          AdManager().showInterstitialAd();
          AdFrequencyManager.markInterstitialShown();
        }
        
        // Inicializar juego
        context.read<GameProvider>().initializeGame(level, gameName: 'memory');
        
        // Pequeño delay para que se muestre el anuncio antes de navegar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          }
        });
      },
      child: Container(
        width: isTablet ? 360 : 280,
        constraints: BoxConstraints(minHeight: isTablet ? 120 : 100),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
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
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

