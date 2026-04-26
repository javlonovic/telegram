import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource() : _dio = DioClient.instance.dio;

  final Dio _dio;

  Future<List<ChatModel>> getChats() async {
    final response = await _dio.get(ApiConstants.chats);
    final results = response.data as List<dynamic>;
    return results
        .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageModel>> getMessages(int chatId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.messages,
      queryParameters: {'chat': chatId, 'page': page},
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatModel> createPrivateChat(int targetUserId) async {
    final response = await _dio.post(
      ApiConstants.chats,
      data: {'type': 'private', 'member_ids': [targetUserId]},
    );
    return ChatModel.fromJson(response.data as Map<String, dynamic>);
  }
}
