import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:bp_monitor/domain/repositories/ai_repository.dart';
import 'package:dio/dio.dart';

/// Remote AI analysis via the FastAPI backend, authenticated with Firebase token.
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<Result<AiAnalyzeResponse>> analyze(AiAnalyzeRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/ai/analyze',
        data: request.toJson(),
      );
      final data = response.data;
      if (data == null) {
        return const Err(NetworkFailure('Empty response from AI service'));
      }
      return Success(AiAnalyzeResponse.fromJson(data));
    } on DioException catch (e, st) {
      AppLogger.error('AI analyze failed', tag: 'REPO', error: e, stackTrace: st);
      final message = e.response?.data?['detail'] as String? ??
          e.message ??
          'AI service unavailable';
      return Err(AiFailure(message));
    } catch (e, st) {
      AppLogger.error('AI analyze failed', tag: 'REPO', error: e, stackTrace: st);
      return Err(AiFailure(e.toString()));
    }
  }
}
