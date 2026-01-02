import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';
import 'home_screen.dart';
import 'cascade_home_screen.dart';
import 'guess_home_screen.dart';
import 'sequence_home_screen.dart';
import 'jigsaw_home_screen.dart';
import 'shadow_home_screen.dart';
import 'riddle_home_screen.dart';
import 'dots_home_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Logo del juego
                  Container(
                    width: 90,
                    height: 90,
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
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Título
                  const Text(
                    'MemeRoo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Juegos de Animales',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
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
                        ],
                      ),
                    ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
