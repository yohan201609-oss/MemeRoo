import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';
import '../utils/ad_manager.dart';
import '../utils/responsive_helper.dart';
import 'home_screen.dart';
import 'cascade_home_screen.dart';
import 'guess_home_screen.dart';
import 'sequence_home_screen.dart';
import 'jigsaw_home_screen.dart';
import 'shadow_home_screen.dart';
import 'riddle_home_screen.dart';
import 'dots_home_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final _adManager = AdManager();

  @override
  void initState() {
    super.initState();
    // Cargar banner ad cuando se muestra el menú
    _adManager.loadBannerAd();
  }

  @override
  void dispose() {
    _adManager.disposeBannerAd();
    super.dispose();
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
              // Botón de configuración en la esquina superior derecha
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, size: 28),
                      onPressed: () {
                        AudioManager().playTap();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      color: Colors.black87,
                      tooltip: 'Configuración',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Logo del juego
                  Container(
                    width: ResponsiveHelper.isTablet(context) ? 120 : 90,
                    height: ResponsiveHelper.isTablet(context) ? 120 : 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: ResponsiveHelper.isTablet(context) ? 120 : 90,
                        height: ResponsiveHelper.isTablet(context) ? 120 : 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.isTablet(context) ? 16 : 12),
                  
                  // Título
                  Text(
                    'MemeRoo',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 32),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.isTablet(context) ? 6 : 4),
                  Text(
                    'Juegos de Animales',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.isTablet(context) ? 32 : 24),
                  
                  // Botones de juegos
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildGameButton(
                            context,
                            icon: Icons.auto_awesome,
                            title: 'Encuentra las Parejas',
                            description: 'Memoria con animales',
                            color: AppColors.primaryGreen,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.water_drop,
                            title: 'Cascada de Animales',
                            description: 'Empareja animales que caen',
                            color: AppColors.cascadeColor,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CascadeHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.repeat,
                            title: 'Secuencia Animal',
                            description: 'Memoriza y repite la secuencia',
                            color: Colors.purple.shade300,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SequenceHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.extension,
                            title: 'Rompecabezas Deslizante',
                            description: 'Ordena las piezas del puzzle',
                            color: Colors.teal.shade300,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const JigsawHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.visibility,
                            title: 'Adivina el Animal',
                            description: 'Descubre el animal oculto',
                            color: AppColors.guessColor,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GuessHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.wb_twilight,
                            title: 'Sombras',
                            description: 'Encuentra el animal correcto',
                            color: Colors.indigo.shade300,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShadowHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.psychology,
                            title: '¿Quién Soy?',
                            description: 'Adivina con las pistas',
                            color: Colors.cyan.shade300,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RiddleHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            context,
                            icon: Icons.scatter_plot,
                            title: 'Conecta los Puntos',
                            description: 'Une los números en orden',
                            color: Colors.pink.shade300,
                            onTap: () {
                              AudioManager().playTap();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DotsHomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // BANNER AD
                  if (_adManager.isBannerLoaded && _adManager.bannerAd != null)
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: _adManager.bannerAd!.size.height.toDouble(),
                      color: Colors.transparent,
                      child: AdWidget(ad: _adManager.bannerAd!),
                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 28 : 20),
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
        child: Row(
          children: [
            Container(
              width: isTablet ? 80 : 60,
              height: isTablet ? 80 : 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getResponsiveIconSize(context, 32),
                color: Colors.white,
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}
