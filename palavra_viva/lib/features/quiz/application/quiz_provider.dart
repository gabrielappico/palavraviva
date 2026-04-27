import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/services/gamification_models.dart';
import '../../../core/providers/gamification_provider.dart';
export '../../../core/providers/gamification_provider.dart';
import '../domain/quiz_question.dart';

// --- Enums ---

enum QuizStatus { idle, loading, playing, finished }

enum GameMode { classic, timed, marathon }

// --- Categories ---

class QuizCategory {
  final String id;
  final String name;
  final String emoji;
  final String prompt;
  final bool isPremium;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.prompt,
    this.isPremium = false,
  });
}

const quizCategories = [
  QuizCategory(
    id: 'geral',
    name: 'Geral',
    emoji: '📖',
    prompt: 'perguntas variadas sobre toda a Bíblia',
  ),
  QuizCategory(
    id: 'antigo_testamento',
    name: 'Antigo Testamento',
    emoji: '📜',
    prompt: 'perguntas exclusivamente sobre o Antigo Testamento',
  ),
  QuizCategory(
    id: 'novo_testamento',
    name: 'Novo Testamento',
    emoji: '🕊️',
    prompt: 'perguntas exclusivamente sobre o Novo Testamento',
  ),
  QuizCategory(
    id: 'reis_profetas',
    name: 'Reis & Profetas',
    emoji: '👑',
    prompt: 'perguntas sobre reis e profetas de Israel e Judá',
  ),
  QuizCategory(
    id: 'parabolas',
    name: 'Parábolas de Jesus',
    emoji: '✝️',
    prompt: 'perguntas sobre as parábolas contadas por Jesus',
  ),
  QuizCategory(
    id: 'geografia',
    name: 'Geografia Bíblica',
    emoji: '🗺️',
    prompt: 'perguntas sobre lugares, cidades, rios e regiões mencionados na Bíblia',
    isPremium: true,
  ),
  QuizCategory(
    id: 'profecias',
    name: 'Profecias',
    emoji: '🔮',
    prompt: 'perguntas sobre profecias bíblicas e seu cumprimento',
    isPremium: true,
  ),
  QuizCategory(
    id: 'proverbios',
    name: 'Provérbios & Sabedoria',
    emoji: '💎',
    prompt: 'perguntas sobre provérbios, sabedoria e livros sapienciais',
  ),
  QuizCategory(
    id: 'quem_disse',
    name: 'Quem disse?',
    emoji: '🧩',
    prompt: 'perguntas no formato "Quem disse esta frase?" com citações bíblicas',
    isPremium: true,
  ),
  QuizCategory(
    id: 'familias',
    name: 'Famílias da Bíblia',
    emoji: '💑',
    prompt: 'perguntas sobre genealogias e famílias bíblicas',
  ),
  QuizCategory(
    id: 'numeros',
    name: 'Números na Bíblia',
    emoji: '🔢',
    prompt: 'perguntas sobre números, quantidades e simbolismo numérico na Bíblia',
    isPremium: true,
  ),
  QuizCategory(
    id: 'batalhas',
    name: 'Batalhas Bíblicas',
    emoji: '⚔️',
    prompt: 'perguntas sobre guerras, batalhas e confrontos na Bíblia',
  ),
];

// --- State ---

String get _openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

class QuizState {
  final QuizStatus status;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int score;
  final bool isAnswered;
  final int? selectedAnswer;
  final String? error;
  final String? selectedDifficulty;
  final QuizCategory? selectedCategory;
  final GameMode gameMode;
  final int timeRemaining;
  final int totalTimePlayed;
  final QuizResult? lastResult;
  final int marathonLives;

  const QuizState({
    this.status = QuizStatus.idle,
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.isAnswered = false,
    this.selectedAnswer,
    this.error,
    this.selectedDifficulty,
    this.selectedCategory,
    this.gameMode = GameMode.classic,
    this.timeRemaining = 15,
    this.totalTimePlayed = 0,
    this.lastResult,
    this.marathonLives = 1,
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? score,
    bool? isAnswered,
    int? selectedAnswer,
    bool clearSelectedAnswer = false,
    String? error,
    bool clearError = false,
    String? selectedDifficulty,
    QuizCategory? selectedCategory,
    GameMode? gameMode,
    int? timeRemaining,
    int? totalTimePlayed,
    QuizResult? lastResult,
    int? marathonLives,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      isAnswered: isAnswered ?? this.isAnswered,
      selectedAnswer: clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
      error: clearError ? null : (error ?? this.error),
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      gameMode: gameMode ?? this.gameMode,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      lastResult: lastResult ?? this.lastResult,
      marathonLives: marathonLives ?? this.marathonLives,
    );
  }
}

// --- Provider ---

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);

class QuizNotifier extends Notifier<QuizState> {
  late Dio _dio;
  late GamificationService _gamification;
  Timer? _timer;

  @override
  QuizState build() {
    _dio = Dio();
    _gamification = GamificationService();
    ref.onDispose(() => _timer?.cancel());
    return const QuizState();
  }

  void reset() {
    _timer?.cancel();
    state = const QuizState();
  }

  void selectCategory(QuizCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void selectGameMode(GameMode mode) {
    state = state.copyWith(gameMode: mode);
  }

  Future<void> generateQuestions(String difficulty) async {
    _timer?.cancel();
    final category = state.selectedCategory ?? quizCategories[0];
    final mode = state.gameMode;
    final questionCount = mode == GameMode.marathon ? 10 : 5;

    state = state.copyWith(
      status: QuizStatus.loading,
      selectedDifficulty: difficulty,
      clearError: true,
      currentIndex: 0,
      score: 0,
      isAnswered: false,
      clearSelectedAnswer: true,
      questions: [],
      totalTimePlayed: 0,
      lastResult: null,
      marathonLives: 1,
      timeRemaining: 15,
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
              'content': '''Você é um teólogo criador de quizzes bíblicos.
Objetivo: Criar $questionCount perguntas do nível "$difficulty" sobre ${category.prompt}.
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
A propriedade "correctIndex" deve ser um inteiro de 0 a 3 apontando para a resposta correta em "options".
Varie a posição da resposta correta. Não coloque sempre no index 0.'''
            },
            {
              'role': 'user',
              'content':
                  'Gere $questionCount perguntas bíblicas de dificuldade $difficulty sobre: ${category.name}.'
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

      // Start timer for timed mode
      if (mode == GameMode.timed) {
        _startTimer();
      }
    } catch (e) {
      state = state.copyWith(
        status: QuizStatus.idle,
        error: 'Falha ao buscar perguntas. Tente novamente.',
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timeRemaining: 15);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isAnswered) return;

      final remaining = state.timeRemaining - 1;
      state = state.copyWith(
        timeRemaining: remaining,
        totalTimePlayed: state.totalTimePlayed + 1,
      );

      if (remaining <= 0) {
        // Time's up — count as wrong
        answerQuestion(-1);
      }
    });
  }

  void answerQuestion(int index) {
    if (state.isAnswered || state.status != QuizStatus.playing) return;

    final currentQuestion = state.questions[state.currentIndex];
    final isCorrect = index == currentQuestion.correctIndex;

    state = state.copyWith(
      isAnswered: true,
      selectedAnswer: index,
      score: isCorrect ? state.score + 1 : state.score,
    );

    // Marathon: wrong answer uses a life
    if (!isCorrect && state.gameMode == GameMode.marathon) {
      final livesLeft = state.marathonLives - 1;
      state = state.copyWith(marathonLives: livesLeft);
    }
  }

  Future<void> nextQuestion() async {
    _timer?.cancel();

    // Marathon: check if game over (no lives left and wrong answer)
    if (state.gameMode == GameMode.marathon && state.marathonLives <= 0) {
      await _finishQuiz();
      return;
    }

    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isAnswered: false,
        clearSelectedAnswer: true,
        timeRemaining: 15,
      );

      if (state.gameMode == GameMode.timed) {
        _startTimer();
      }
    } else if (state.gameMode == GameMode.marathon && state.marathonLives > 0) {
      // Marathon: load more questions
      await _loadMoreMarathonQuestions();
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _loadMoreMarathonQuestions() async {
    final category = state.selectedCategory ?? quizCategories[0];
    final difficulty = state.selectedDifficulty ?? 'Médio';

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
              'content': '''Você é um teólogo criador de quizzes bíblicos.
Crie 5 perguntas do nível "$difficulty" sobre ${category.prompt}.
Formato JSON: {"questions": [{"question": "...", "options": ["A","B","C","D"], "correctIndex": 0, "reference": "Livro X:Y"}]}
Varie a posição da resposta correta.'''
            },
            {
              'role': 'user',
              'content': 'Mais 5 perguntas bíblicas de $difficulty sobre ${category.name}. Não repita perguntas anteriores.'
            }
          ],
        },
      );

      final replyContent = response.data['choices'][0]['message']['content'];
      final parsed = jsonDecode(replyContent);
      final newQuestions = (parsed['questions'] as List)
          .map((j) => QuizQuestion.fromJson(j))
          .toList();

      state = state.copyWith(
        questions: [...state.questions, ...newQuestions],
        currentIndex: state.currentIndex + 1,
        isAnswered: false,
        clearSelectedAnswer: true,
      );
    } catch (_) {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    // Record score in Supabase
    try {
      final result = await _gamification.recordQuizScore(
        difficulty: state.selectedDifficulty ?? 'Médio',
        category: state.selectedCategory?.id ?? 'geral',
        gameMode: state.gameMode.name,
        score: state.score,
        totalQuestions: state.currentIndex + 1,
        timeSpentSeconds: state.totalTimePlayed,
      );

      // Check if user earned a free life:
      // - Classic/Timed: 5/5 perfect
      // - Marathon: 5+ correct answers
      bool earnedLife = false;
      if (state.gameMode == GameMode.marathon && state.score >= 5) {
        earnedLife = true;
      } else if (state.gameMode != GameMode.marathon &&
          state.score == state.questions.length &&
          state.questions.length >= 5) {
        earnedLife = true;
      }

      if (earnedLife) {
        await _gamification.grantFreeLife();
      }

      state = state.copyWith(
        status: QuizStatus.finished,
        lastResult: QuizResult(
          xpEarned: result.xpEarned,
          newStreak: result.newStreak,
          newTotalXp: result.newTotalXp,
          earnedFreeLife: earnedLife,
        ),
      );

      // Invalidate cached stats
      ref.invalidate(userStatsProvider);
      ref.invalidate(weeklyLeaderboardProvider);
    } catch (_) {
      // If recording fails, still show results
      state = state.copyWith(status: QuizStatus.finished);
    }
  }
}
