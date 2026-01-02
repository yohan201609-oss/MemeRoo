class ShadowAnimal {
  final String emoji;
  final String name;
  final bool isMatched;

  ShadowAnimal({
    required this.emoji,
    required this.name,
    this.isMatched = false,
  });

  ShadowAnimal copyWith({
    String? emoji,
    String? name,
    bool? isMatched,
  }) {
    return ShadowAnimal(
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

