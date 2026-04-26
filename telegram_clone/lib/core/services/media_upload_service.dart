import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../../features/chats/data/models/message_model.dart';

/// Handles multipart file uploads to POST /api/messages/upload/
class MediaUploadService {
  MediaUploadService._();
  static final MediaUploadService instance = MediaUploadService._();

  final Dio _dio = DioClient.instance.dio;

  /// Uploads [file] to [chatId] and returns the created [MessageModel].
  /// [onProgress] fires with values 0.0 → 1.0 as bytes are sent.
  Future<MessageModel> uploadFile({
    required File file,
    required int chatId,
    String caption = '',
    void Function(double progress)? onProgress,
  }) async {
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileName = file.path.split('/').last;
    final mimeParts = mimeType.split('/');

    final formData = FormData.fromMap({
      'chat': chatId,
      'caption': caption,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType(
          mimeParts[0],
          mimeParts.length > 1 ? mimeParts[1] : '*',
        ),
      ),
    });

    final response = await _dio.post(
      ApiConstants.mediaUpload,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );

    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
