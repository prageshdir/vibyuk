import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<Map<String, dynamic>>> getConversations();

  Future<List<Map<String, dynamic>>> getMessages(
      String conversationId, {int page = 1, int pageSize = 30});

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String text,
  });

  Future<void> markConversationRead(String conversationId);

  Future<Map<String, dynamic>> getOrCreateConversation({
    required String otherUserId,
    String? bookingId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    final res = await _dio.get(ApiEndpoints.chatConversations);
    final data = res.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(
      String conversationId, {int page = 1, int pageSize = 30}) async {
    final res = await _dio.get(
      ApiEndpoints.chatMessages(conversationId),
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final data = res.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.chatMessages(conversationId),
      data: {'text': text, 'type': 'text'},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    await _dio.post(ApiEndpoints.chatConversationRead(conversationId));
  }

  @override
  Future<Map<String, dynamic>> getOrCreateConversation({
    required String otherUserId,
    String? bookingId,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.chatConversations,
      data: {
        'other_user_id': otherUserId,
        if (bookingId != null) 'booking_id': bookingId,
      },
    );
    return res.data as Map<String, dynamic>;
  }
}
