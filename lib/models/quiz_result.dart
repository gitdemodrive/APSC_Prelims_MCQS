class QuizResult {
  final String questionId;
  final int selectedAnswerIndex;
  final int correctAnswerIndex;
  final bool isCorrect;

  QuizResult({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
  }) : isCorrect = selectedAnswerIndex == correctAnswerIndex;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      questionId: json['question_id'] as String,
      selectedAnswerIndex: json['selected_answer_index'] as int,
      correctAnswerIndex: json['correct_answer_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_answer_index': selectedAnswerIndex,
      'correct_answer_index': correctAnswerIndex,
      'is_correct': isCorrect,
    };
  }
}