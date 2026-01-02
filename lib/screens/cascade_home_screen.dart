import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cascade_provider.dart';
import '../utils/colors.dart';
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
                          const SizedBox(height: 24),
                          _buildLevelButton(
                            context,
                            level: 'medium',
                            title: 'Medio',
                            subtitle: 'Meta: 200 puntos\n25 movimientos • 90s',
                            stars: _getStarsDisplay(snapshot.data?['medium'] ?? 0),
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 24),
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
        context.read<CascadeProvider>().initializeGame(level);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CascadeGameScreen()),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

