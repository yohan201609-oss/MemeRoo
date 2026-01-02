class TutorialStep {
  final String title;
  final String description;
  final String? imagePath;
  final String? emoji;

  TutorialStep({
    required this.title,
    required this.description,
    this.imagePath,
    this.emoji,
  });
}

