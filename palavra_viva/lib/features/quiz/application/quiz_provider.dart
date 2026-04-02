import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/quiz_question.dart';

enum QuizStatus { idle, loading, playing, finished }

String get _openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

class QuizState {
  final QuizStatus status;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int score;
  final bool isAnswered;
  final String? error;
  final String? selectedDifficulty;

  const QuizState({
    this.status = QuizStatus.idle,
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.isAnswered = false,
    this.error,
    this.selectedDifficulty,
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? score,
    bool? isAnswered,
    String? error,
    bool clearError = false,
    String? selectedDifficulty,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      isAnswered: isAnswered ?? this.isAnswered,
      error: clearError ? null : (error ?? this.error),
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    );
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);

class QuizNotifier extends Notifier<QuizState> {
  late Dio _dio;

  @override
  QuizState build() {
    _dio = Dio();
    return const QuizState();
  }

  void reset() {
    state = const QuizState();
  }

  Future<void> generateQuestions(String difficulty) async {
    state = state.copyWith(
      status: QuizStatus.loading,
      selectedDifficulty: difficulty,
      clearError: true,
      currentIndex: 0,
      score: 0,
      isAnswered: false,
      questions: [],
    );

    if (_openAiApiKey.isEmpty) {
      state = state.copyWith(
        status: QuizStatus.idle,
        error: 'Chave da OpenAI não encontrada. Verifique o arquivo .env.',
      );
      return;
    }

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        }),
        data: {
          'model': 'gpt-4o-mini',
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'system',
              'content':
                  '''Você é um teólogo criador de quizzes bíblicos. 
Objetivo: Criar 5 perguntas do nível "$difficulty".
Formato de saída OBRIGATÓRIO (JSON puro com a raiz "questions"):
{
  "questions": [
    {
      "question": "A pergunta...",
      "options": ["Opção 1", "Opção 2", "Opção 3", "Opção 4"],
      "correctIndex": 0,
      "reference": "Livro X:Y"
    }
  ]
}
A propriedade "correctIndex" deve ser um inteiro de 0 a 3 apontando para a resposta correta em "options".'''
            },
            {
              'role': 'user',
              'content': 'Gere 5 perguntas bíblicas interessantes de dificuldade $difficulty.'
            }
          ],
        },
      );

      final replyContent = response.data['choices'][0]['message']['content'];
      final Map<String, dynamic> parsedJson = jsonDecode(replyContent);
      final List<dynamic> questionsList = parsedJson['questions'] ?? [];

      final generatedQuestions = questionsList
          .map((json) => QuizQuestion.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: QuizStatus.playing,
        questions: generatedQuestions,
      );
    } catch (e) {
      state = state.copyWith(
        status: QuizStatus.idle,
        error: 'Falha ao buscar perguntas: Tente novamente mais tarde.',
      );
    }
  }

  void answerQuestion(int index) {
    if (state.isAnswered || state.status != QuizStatus.playing) return;

    final currentQuestion = state.questions[state.currentIndex];
    final isCorrect = index == currentQuestion.correctIndex;

    state = state.copyWith(
      isAnswered: true,
      score: isCorrect ? state.score + 1 : state.score,
    );
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isAnswered: false,
      );
    } else {
      state = state.copyWith(status: QuizStatus.finished);
    }
  }
}
