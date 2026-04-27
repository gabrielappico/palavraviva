import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized service for all OpenAI calls.
/// Routes through Supabase Edge Function so the API key
/// is NEVER embedded in the client app.
class OpenAiService {
  static final OpenAiService _instance = OpenAiService._();
  factory OpenAiService() => _instance;
  OpenAiService._();

  final _dio = Dio();

  String get _edgeFunctionUrl {
    final baseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    return '$baseUrl/functions/v1/ai-chat';
  }

  String get _anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Sends a chat completion request through the Edge Function proxy.
  ///
  /// [messages] — OpenAI-formatted message list
  /// [model] — defaults to gpt-4o-mini
  /// [responseFormat] — optional, e.g. {'type': 'json_object'}
  ///
  /// Returns the raw OpenAI response data map.
  Future<Map<String, dynamic>> chatCompletion({
    required List<Map<String, String>> messages,
    String model = 'gpt-4o-mini',
    Map<String, dynamic>? responseFormat,
  }) async {
    final body = <String, dynamic>{
      'messages': messages,
      'model': model,
    };

    if (responseFormat != null) {
      body['response_format'] = responseFormat;
    }

    final response = await _dio.post(
      _edgeFunctionUrl,
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_anonKey',
        'apikey': _anonKey,
      }),
      data: body,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Convenience: extract the reply text from a chat completion.
  Future<String> getReply({
    required List<Map<String, String>> messages,
    String model = 'gpt-4o-mini',
  }) async {
    final data = await chatCompletion(messages: messages, model: model);
    return data['choices'][0]['message']['content'] as String;
  }
}
