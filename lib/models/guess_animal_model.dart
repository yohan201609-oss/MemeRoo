class GuessAnimal {
  final String emoji;
  final String correctAnswer;
  final List<String> options;
  final int revealLevel; // 0-4 (0 = más pixelado, 4 = menos pixelado)

  GuessAnimal({
    required this.emoji,
    required this.correctAnswer,
    required this.options,
    this.revealLevel = 0,
  });

  GuessAnimal copyWith({
    String? emoji,
    String? correctAnswer,
    List<String>? options,
    int? revealLevel,
  }) {
    return GuessAnimal(
      emoji: emoji ?? this.emoji,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      revealLevel: revealLevel ?? this.revealLevel,
    );
  }
}

