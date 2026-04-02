class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String reference;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.reference,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? 'Pergunta desconhecida',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'reference': reference,
    };
  }
}
