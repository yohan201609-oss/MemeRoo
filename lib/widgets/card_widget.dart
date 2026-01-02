import 'package:flutter/material.dart';
import '../models/memory_card.dart';
import '../utils/constants.dart';
import '../utils/colors.dart';

class CardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: card.isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: GameConstants.cardFlipDuration,
        curve: Curves.easeInOut,
        width: GameConstants.cardSize,
        height: GameConstants.cardSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: card.isFlipped || card.isMatched
            ? _buildFront()
            : _buildBack(),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          card.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.cardBackGradient,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

