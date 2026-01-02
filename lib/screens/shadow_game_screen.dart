import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shadow_provider.dart';
import '../models/shadow_animal_model.dart';
import '../widgets/help_button.dart';
import '../widgets/feedback_icon_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../utils/colors.dart';
import '../utils/tutorial_data.dart';
import '../widgets/tutorial_dialog.dart';
import 'shadow_victory_screen.dart';
import 'main_menu_screen.dart';

class ShadowGameScreen extends StatefulWidget {
  const ShadowGameScreen({super.key});

  @override
  State<ShadowGameScreen> createState() => _ShadowGameScreenState();
}

class _ShadowGameScreenState extends State<ShadowGameScreen> {
  @override
  void initState() {
    super.initState();
    _showTutorialIfNeeded();
  }

  Future<void> _showTutorialIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final shouldShow = await TutorialDialog.shouldShow('shadow');
    if (shouldShow) {
      final steps = TutorialData.getTutorial('shadow');
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(
          steps: steps,
          gameKey: 'shadow',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShadowProvider>();

    // Navegación automática
    if (provider.gameState == ShadowGameState.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShadowVictoryScreen(
              score: provider.score,
              correctAnswers: provider.correctAnswers,
              totalRounds: provider.totalRounds,
              level: provider.currentLevel,
            ),
          ),
        );
      });
    }

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
              _buildHeader(context, provider),
              Expanded(
                child: provider.currentShadow != null
                    ? _buildGameArea(context, provider)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ShadowProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FeedbackIconButton(
            icon: Icons.arrow_back,
            onPressed: () async {
              final confirmed = await ConfirmationDialog.confirmExit(context);
              if (confirmed && mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainMenuScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            color: Colors.black87,
          ),
          Column(
            children: [
              Text(
                'Ronda ${provider.round}/${provider.totalRounds}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Puntos: ${provider.score}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Row(
            children: [
              HelpButton(gameKey: 'shadow'),
              const SizedBox(width: 8),
              FeedbackIconButton(
                icon: Icons.refresh,
                onPressed: () async {
                  final confirmed = await ConfirmationDialog.confirmRestart(context);
                  if (confirmed && mounted) {
                    provider.resetGame();
                  }
                },
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(BuildContext context, ShadowProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Sombra (emoji en negro)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade400, width: 3),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Colors.black, Colors.black],
                  ).createShader(bounds);
                },
                child: Text(
                  provider.currentShadow!.emoji,
                  style: const TextStyle(
                    fontSize: 120,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const Text(
            '¿Qué animal es?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Opciones
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: provider.options.map((animal) {
              return _buildOptionButton(animal, provider);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(ShadowAnimal animal, ShadowProvider provider) {
    return GestureDetector(
      onTap: () => provider.selectAnimal(animal.emoji),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              animal.emoji,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 4),
            Text(
              animal.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

