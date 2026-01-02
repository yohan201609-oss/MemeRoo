import 'package:flutter/material.dart';
import 'dart:ui';

class PixelatedImageWidget extends StatelessWidget {
  final String emoji;
  final int revealLevel; // 0-4 (0 = más pixelado, 4 = menos pixelado)

  const PixelatedImageWidget({
    super.key,
    required this.emoji,
    required this.revealLevel,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular el nivel de blur basado en revealLevel
    // revealLevel 0 = blur máximo (más borroso)
    // revealLevel 4 = sin blur (visible)
    final blurAmount = (4 - revealLevel) * 8.0; // 32, 24, 16, 8, 0

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: blurAmount > 0
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 120),
                ),
              )
            : Text(
                emoji,
                style: const TextStyle(fontSize: 120),
              ),
      ),
    );
  }
}

