import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/riddle_provider.dart';
import '../models/riddle_animal_model.dart';
import '../widgets/help_button.dart';
import '../widgets/feedback_icon_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../utils/colors.dart';
import '../utils/tutorial_data.dart';
import '../widgets/tutorial_dialog.dart';
import 'riddle_victory_screen.dart';
import 'main_menu_screen.dart';

class RiddleGameScreen extends StatefulWidget {
  const RiddleGameScreen({super.key});

  @override
  State<RiddleGameScreen> createState() => _RiddleGameScreenState();
}

class _RiddleGameScreenState extends State<RiddleGameScreen> {
  @override
  void initState() {
    super.initState();
    _showTutorialIfNeeded();
  }

  Future<void> _showTutorialIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final shouldShow = await TutorialDialog.shouldShow('riddle');
    if (shouldShow) {
      final steps = TutorialData.getTutorial('riddle');
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(
          steps: steps,
          gameKey: 'riddle',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiddleProvider>();

    // Navegación automática
    if (provider.gameState == RiddleGameState.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RiddleVictoryScreen(
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
                child: provider.currentAnimal != null
                    ? _buildGameArea(context, provider)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RiddleProvider provider) {
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
                'Pregunta ${provider.round}/${provider.totalRounds}',
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
              HelpButton(gameKey: 'riddle'),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 28),
                onPressed: () => provider.resetGame(),
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(BuildContext context, RiddleProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            '¿Quién soy?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // Pistas reveladas
          ...List.generate(provider.currentClueIndex + 1, (index) {
            return _buildClueCard(
              provider.currentAnimal!.clues[index],
              index + 1,
            );
          }),

          const SizedBox(height: 20),

          // Botón para mostrar siguiente pista (si hay)
          if (provider.currentClueIndex < 2)
            ElevatedButton.icon(
              onPressed: () => provider.showNextClue(),
              icon: const Icon(Icons.lightbulb),
              label: const Text('Ver siguiente pista (-10 pts)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Opciones
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: provider.options.length,
            itemBuilder: (context, index) {
              final animal = provider.options[index];
              return _buildOptionButton(animal, provider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClueCard(String clue, int number) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              clue,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(RiddleAnimal animal, RiddleProvider provider) {
    return GestureDetector(
      onTap: () => provider.selectAnimal(animal.emoji),
      child: Container(
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
            const SizedBox(height: 8),
            Text(
              animal.name,
              style: const TextStyle(
                fontSize: 16,
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

