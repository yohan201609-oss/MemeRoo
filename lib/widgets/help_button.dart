import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';
import '../utils/tutorial_data.dart';
import 'tutorial_dialog.dart';

class HelpButton extends StatelessWidget {
  final String gameKey;

  const HelpButton({
    super.key,
    required this.gameKey,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 28),
      onPressed: () {
        AudioManager().playTap();
        final steps = TutorialData.getTutorial(gameKey);
        if (steps.isNotEmpty) {
          showDialog(
            context: context,
            builder: (_) => TutorialDialog(
              steps: steps,
              gameKey: gameKey,
            ),
          );
        }
      },
      color: Colors.blue,
      tooltip: 'Ayuda',
    );
  }
}

