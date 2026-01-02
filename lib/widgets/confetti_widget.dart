import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart' as confetti;
import 'dart:math';

class ConfettiWidget extends StatefulWidget {
  final bool isPlaying;

  const ConfettiWidget({
    super.key,
    required this.isPlaying,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  late confetti.ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = confetti.ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: confetti.ConfettiWidget(
        confettiController: _controller,
        blastDirection: pi / 2,
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
      ),
    );
  }
}

