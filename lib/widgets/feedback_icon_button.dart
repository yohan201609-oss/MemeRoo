import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';

class FeedbackIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;
  final bool playSound;

  const FeedbackIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 28,
    this.tooltip,
    this.playSound = true,
  });

  @override
  State<FeedbackIconButton> createState() => _FeedbackIconButtonState();
}

class _FeedbackIconButtonState extends State<FeedbackIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.playSound) {
      AudioManager().playTap();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _handleTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: IconButton(
          icon: Icon(widget.icon, size: widget.size),
          onPressed: null, // Manejado por GestureDetector
          color: widget.color,
          tooltip: widget.tooltip,
        ),
      ),
    );
  }
}

