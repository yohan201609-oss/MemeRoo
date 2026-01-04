import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dots_provider.dart';
import '../providers/game_provider.dart';
import '../models/dot_model.dart';
import '../widgets/help_button.dart';
import '../widgets/feedback_icon_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/hint_button.dart';
import '../utils/colors.dart';
import '../utils/tutorial_data.dart';
import '../widgets/tutorial_dialog.dart';
import 'dots_victory_screen.dart';
import 'main_menu_screen.dart';

class DotsGameScreen extends StatefulWidget {
  const DotsGameScreen({super.key});

  @override
  State<DotsGameScreen> createState() => _DotsGameScreenState();
}

class _DotsGameScreenState extends State<DotsGameScreen> {
  String? _currentHint;

  @override
  void initState() {
    super.initState();
    // Asegurar que el juego esté inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DotsProvider>();
      if (provider.dots.isEmpty) {
        // Si no hay puntos, inicializar con el nivel actual
        provider.initializeGame(provider.currentLevel);
      }
    });
    _showTutorialIfNeeded();
  }

  Future<void> _showTutorialIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final shouldShow = await TutorialDialog.shouldShow('dots');
    if (shouldShow) {
      final steps = TutorialData.getTutorial('dots');
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(
          steps: steps,
          gameKey: 'dots',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DotsProvider>();

    // Navegación automática
    if (provider.gameState == DotsGameState.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DotsVictoryScreen(
              seconds: provider.seconds,
              level: provider.currentLevel,
              animal: provider.currentAnimal,
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
                child: provider.dots.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildGameArea(context, provider),
              ),
              _buildHintSection(context),
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

  Widget _buildHeader(BuildContext context, DotsProvider provider) {
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
                'Conecta: ${provider.nextDotNumber}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                provider.getFormattedTime(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Row(
            children: [
              HelpButton(gameKey: 'dots'),
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

  Widget _buildGameArea(BuildContext context, DotsProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: Stack(
              children: [
                // Líneas conectando dots
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(size * 0.9, size * 0.9),
                    painter: DotLinePainter(
                      dots: provider.dots,
                      currentIndex: provider.currentDotIndex,
                    ),
                  ),
                ),

                // Dots
                ...provider.dots.map((dot) {
                  return _buildDot(dot, size * 0.9, provider);
                }).toList(),

                // Animal revelado (cuando termine)
                if (provider.gameState == DotsGameState.won)
                  IgnorePointer(
                    child: Center(
                      child: Text(
                        provider.currentAnimal,
                        style: TextStyle(
                          fontSize: size * 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDot(Dot dot, double containerSize, DotsProvider provider) {
    final isNext = dot.number == provider.nextDotNumber;
    final isConnected = dot.isConnected;

    return Positioned(
      left: (dot.position.dx * containerSize) - 30,
      top: (dot.position.dy * containerSize) - 30,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.onDotTapped(dot.number),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.green
                  : isNext
                      ? Colors.blue
                      : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isNext ? Colors.blue : Colors.grey.shade400,
                width: isNext ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${dot.number}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isConnected || isNext ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter para dibujar líneas
class DotLinePainter extends CustomPainter {
  final List<Dot> dots;
  final int currentIndex;

  DotLinePainter({
    required this.dots,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentIndex < 1) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < currentIndex - 1; i++) {
      final start = Offset(
        dots[i].position.dx * size.width,
        dots[i].position.dy * size.height,
      );
      final end = Offset(
        dots[i + 1].position.dx * size.width,
        dots[i + 1].position.dy * size.height,
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(DotLinePainter oldDelegate) {
    return currentIndex != oldDelegate.currentIndex;
  }
}

