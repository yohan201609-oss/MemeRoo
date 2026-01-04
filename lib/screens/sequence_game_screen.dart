import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sequence_provider.dart';
import '../providers/game_provider.dart';
import '../utils/colors.dart';
import '../widgets/hint_button.dart';
import 'sequence_victory_screen.dart';

class SequenceGameScreen extends StatefulWidget {
  const SequenceGameScreen({super.key});

  @override
  State<SequenceGameScreen> createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen> {
  String? _currentHint;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SequenceProvider>();

    // Navegación automática
    if (provider.gameState == SequenceGameState.won ||
        provider.gameState == SequenceGameState.wrong) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SequenceVictoryScreen(
              rounds: provider.currentRound,
              level: provider.currentLevel,
              isWon: provider.gameState == SequenceGameState.won,
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
                child: Center(
                  child: _buildGameArea(context, provider),
                ),
              ),
              _buildHintSection(context),
              _buildFooter(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentHint != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade300,
                    width: 2,
                  ),
                ),
                child: Text(
                  _currentHint!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          if (_currentHint != null) const SizedBox(width: 12),
          HintButton(
            onHintRevealed: (hint) {
              setState(() => _currentHint = hint);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SequenceProvider provider) {
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
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
            color: Colors.black87,
          ),
          Column(
            children: [
              Text(
                'Ronda ${provider.currentRound}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Récord: ${provider.highScore}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGameArea(BuildContext context, SequenceProvider provider) {
    if (provider.gameState == SequenceGameState.ready) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Listo?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.startNewRound(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Comenzar',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      );
    }

    if (provider.gameState == SequenceGameState.showing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Observa la secuencia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          _buildAnimalGrid(provider, enabled: false),
        ],
      );
    }

    if (provider.gameState == SequenceGameState.waiting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¡Tu turno! (${provider.playerSequence.length}/${provider.sequenceLength})',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          _buildAnimalGrid(provider, enabled: true),
        ],
      );
    }

    if (provider.gameState == SequenceGameState.correct) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Correcto!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.startNewRound(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Siguiente Ronda',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildAnimalGrid(SequenceProvider provider, {required bool enabled}) {
    return SizedBox(
      width: 300,
      height: 300,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final animal = provider.availableAnimals[index];
          final isAnimating = provider.animatingIndex == index;

          return GestureDetector(
            onTap: enabled ? () => provider.onAnimalTapped(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isAnimating
                    ? Colors.yellow.shade300
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isAnimating
                        ? Colors.yellow.withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: isAnimating ? 20 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isAnimating ? Colors.orange : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  animal.emoji,
                  style: TextStyle(
                    fontSize: isAnimating ? 70 : 60,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SequenceProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => provider.resetGame(),
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text('Reiniciar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

