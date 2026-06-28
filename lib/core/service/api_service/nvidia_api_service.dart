import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:nexora/core/local_storage/LocalStorage.dart';

class NvidiaApiService {
  static const String baseUrl = "https://integrate.api.nvidia.com/v1";
  static const String apiKey =
      "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";
  static const String model = "qwen/qwen3-next-80b-a3b-thinking";

  late final Dio _dio;

  NvidiaApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<Stream<String>> streamCompletion({
    required List<Map<String, String>> messages,
    double temperature = 0.6,
    double topP = 0.7,
    int maxTokens = 4096,
  }) async {
    String localModel = await LocalStorage.getSelectedModelApiName() ?? model;
    const url = '/chat/completions';

    final body = {
      'model': localModel,
      'messages': messages,
      'temperature': temperature,
      'top_p': topP,
      'max_tokens': maxTokens,
      'stream': true,
    };

    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'},
        ),
      );

      final responseStream = response.data as ResponseBody;
      final streamController = StreamController<String>();

      responseStream.stream.listen(
        (data) {
          final lines = utf8.decode(data).split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ') && line.length > 6) {
              final jsonString = line.substring(6);
              if (jsonString == '[DONE]' || jsonString.isEmpty) {
                continue;
              }

              try {
                final jsonData = jsonDecode(jsonString);
                final choices = jsonData['choices'] as List?;
                if (choices != null && choices.isNotEmpty) {
                  final delta = choices[0]['delta'] as Map<String, dynamic>?;
                  if (delta != null) {
                    // Only extract content, ignore reasoning_content
                    final content = delta['content'];
                    if (content != null) {
                      streamController.add(content as String);
                    }
                  }
                }
              } catch (e) {
                // Skip invalid JSON lines
                continue;
              }
            }
          }
        },
        onError: (error) => streamController.addError(error),
        onDone: () => streamController.close(),
        cancelOnError: true,
      );

      return streamController.stream;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('API Error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    }
  }
}
