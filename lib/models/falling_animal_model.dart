import 'package:flutter/material.dart';

class FallingAnimal {
  final String id;
  final String emoji;
  final Color color;
  double x; // Posición horizontal (0.0 - 1.0)
  double y; // Posición vertical (0.0 - 1.0)
  bool isDragging;
  bool isMatched;
  double size;

  FallingAnimal({
    required this.id,
    required this.emoji,
    required this.color,
    required this.x,
    required this.y,
    this.isDragging = false,
    this.isMatched = false,
    this.size = 60.0,
  });

  FallingAnimal copyWith({
    String? id,
    String? emoji,
    Color? color,
    double? x,
    double? y,
    bool? isDragging,
    bool? isMatched,
    double? size,
  }) {
    return FallingAnimal(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      x: x ?? this.x,
      y: y ?? this.y,
      isDragging: isDragging ?? this.isDragging,
      isMatched: isMatched ?? this.isMatched,
      size: size ?? this.size,
    );
  }
}

