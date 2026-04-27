import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/gamification_service.dart';

String get _openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

final prayerProvider = NotifierProvider<PrayerNotifier, PrayerState>(PrayerNotifier.new);

class PrayerState {
  final String? prayerText;
  final bool isLoading;
  final String? error;

  const PrayerState({
    this.prayerText,
    this.isLoading = false,
    this.error,
  });
}

class PrayerNotifier extends Notifier<PrayerState> {
  late Dio _dio;

  @override
  PrayerState build() {
    _dio = Dio();
    return const PrayerState();
  }

  Future<void> generatePrayer(String emotion) async {
    state = const PrayerState(isLoading: true);

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        }),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Aja como o conselheiro espiritual de uma profunda vivência em oração cristã. Redija uma oração linda, íntima, tocante e confortadora abordando a sensação relatada. Máximo de 3 parágrafos curtos. Sem clichês baratos; seja majestoso e sagrado na palavra. Feche a oração sempre com o termo "Em nome de Jesus, Amém".'
            },
            {
              'role': 'user',
              'content': 'Meu coração agora se sente: $emotion.',
            }
          ],
        },
      );

      final replyText = response.data['choices'][0]['message']['content'];
      state = PrayerState(prayerText: replyText);

      // Track activity for streak
      try {
        await GamificationService().logActivity('prayer', xp: 5);
      } catch (_) {}
    } catch (e) {
      if (_openAiApiKey.isEmpty || _openAiApiKey.contains('SUA-CHAVE')) {
        state = const PrayerState(
          error: '⚠️ Lembre-se de colocar sua chave do OpenAI para gerar orações IA.',
        );
        return;
      }
      state = const PrayerState(
        error: 'Houve um silêncio no santuário... Tente gerar novamente.',
      );
    }
  }

  void reset() {
    state = const PrayerState();
  }
}
