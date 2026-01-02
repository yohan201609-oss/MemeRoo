import 'package:flutter/material.dart';

class JigsawPiece {
  final int id;
  final int correctRow;
  final int correctCol;
  final Offset currentPosition; // Posición actual en pantalla
  final bool isPlaced; // Si ya está en su lugar correcto
  final String partEmoji; // Parte del emoji que representa

  JigsawPiece({
    required this.id,
    required this.correctRow,
    required this.correctCol,
    required this.currentPosition,
    this.isPlaced = false,
    required this.partEmoji,
  });

  JigsawPiece copyWith({
    int? id,
    int? correctRow,
    int? correctCol,
    Offset? currentPosition,
    bool? isPlaced,
    String? partEmoji,
  }) {
    return JigsawPiece(
      id: id ?? this.id,
      correctRow: correctRow ?? this.correctRow,
      correctCol: correctCol ?? this.correctCol,
      currentPosition: currentPosition ?? this.currentPosition,
      isPlaced: isPlaced ?? this.isPlaced,
      partEmoji: partEmoji ?? this.partEmoji,
    );
  }
}

