import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tutorial_step.dart';
import '../utils/colors.dart';
import '../utils/audio_manager.dart';

class TutorialDialog extends StatefulWidget {
  final List<TutorialStep> steps;
  final String gameKey;

  const TutorialDialog({
    super.key,
    required this.steps,
    required this.gameKey,
  });

  static Future<bool> shouldShow(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('tutorial_shown_$gameKey') ?? false);
  }

  static Future<void> markAsShown(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_shown_$gameKey', true);
  }

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _currentStep = 0;
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final step = widget.steps[_currentStep];
    final isLastStep = _currentStep == widget.steps.length - 1;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backGradient,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji o imagen
            if (step.emoji != null)
              Text(
                step.emoji!,
                style: const TextStyle(fontSize: 80),
              ),
            const SizedBox(height: 16),

            // Título
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descripción
            Text(
              step.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Indicador de progreso
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.steps.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == _currentStep
                        ? Colors.blue
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Checkbox "No volver a mostrar"
            if (isLastStep)
              CheckboxListTile(
                title: const Text(
                  'No volver a mostrar',
                  style: TextStyle(fontSize: 14),
                ),
                value: _dontShowAgain,
                onChanged: (value) {
                  setState(() {
                    _dontShowAgain = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),

            const SizedBox(height: 16),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Saltar
                if (!isLastStep)
                  TextButton(
                    onPressed: () {
                      AudioManager().playTap();
                      Navigator.pop(context);
                    },
                    child: const Text('Saltar'),
                  )
                else
                  const SizedBox(),

                // Botón Siguiente/Comenzar
                ElevatedButton(
                  onPressed: () {
                    AudioManager().playTap();
                    if (isLastStep) {
                      if (_dontShowAgain) {
                        TutorialDialog.markAsShown(widget.gameKey);
                      }
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        _currentStep++;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isLastStep ? '¡Comenzar!' : 'Siguiente',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

