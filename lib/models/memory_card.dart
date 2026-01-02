import 'package:flutter/material.dart';

class MemoryCard {
  final String id;
  final String emoji;
  final Color color;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    String? id,
    String? emoji,
    Color? color,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

