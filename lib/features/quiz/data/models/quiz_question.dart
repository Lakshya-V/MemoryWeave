class QuizQuestion {
  final int id;
  final int questionNumber;
  final int totalQuestions;
  final String questionText;
  final String imageUrl;
  final String category;
  final String answerHint;

  const QuizQuestion({
    required this.id,
    required this.questionNumber,
    required this.totalQuestions,
    required this.questionText,
    required this.imageUrl,
    this.category = 'Family & Memories',
    this.answerHint = '',
  });
}
