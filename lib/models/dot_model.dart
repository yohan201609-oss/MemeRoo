import 'package:flutter/material.dart';

class Dot {
  final int number;
  final Offset position; // Posición normalizada (0.0-1.0)
  final bool isConnected;

  Dot({
    required this.number,
    required this.position,
    this.isConnected = false,
  });

  Dot copyWith({
    int? number,
    Offset? position,
    bool? isConnected,
  }) {
    return Dot(
      number: number ?? this.number,
      position: position ?? this.position,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

