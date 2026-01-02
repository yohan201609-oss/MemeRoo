import 'package:flutter/material.dart';
import '../models/falling_animal_model.dart';

class FallingAnimalWidget extends StatelessWidget {
  final FallingAnimal animal;
  final double gameWidth;
  final double gameHeight;
  final Function(String, double, double) onDragStart;
  final Function(double, double) onDragUpdate;
  final Function() onDragEnd;

  const FallingAnimalWidget({
    super.key,
    required this.animal,
    required this.gameWidth,
    required this.gameHeight,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (animal.isMatched) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        // Usar coordenadas globales
        onDragStart(animal.id, details.globalPosition.dx, details.globalPosition.dy);
      },
      onPanUpdate: (details) {
        // Usar coordenadas globales
        onDragUpdate(details.globalPosition.dx, details.globalPosition.dy);
      },
      onPanEnd: (_) {
        onDragEnd();
      },
      child: Container(
        width: animal.size,
        height: animal.size,
        decoration: BoxDecoration(
          color: animal.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: animal.isDragging ? Colors.yellow : Colors.white,
            width: animal.isDragging ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            animal.emoji,
            style: TextStyle(
              fontSize: animal.size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

