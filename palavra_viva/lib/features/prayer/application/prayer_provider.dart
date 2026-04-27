import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/gamification_service.dart';

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
  late OpenAiService _openAi;

  @override
  PrayerState build() {
    _openAi = OpenAiService();
    return const PrayerState();
  }

  Future<void> generatePrayer(String emotion) async {
    state = const PrayerState(isLoading: true);

    try {
      final replyText = await _openAi.getReply(
        messages: [
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
      );

      state = PrayerState(prayerText: replyText);

      // Track activity for streak
      try {
        await GamificationService().logActivity('prayer', xp: 5);
      } catch (_) {}
    } catch (e) {
      state = const PrayerState(
        error: 'Houve um silêncio no santuário... Tente gerar novamente.',
      );
    }
  }

  void reset() {
    state = const PrayerState();
  }
}
