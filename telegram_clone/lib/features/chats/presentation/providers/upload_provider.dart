import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/media_upload_service.dart';
import '../../domain/entities/message_entity.dart';
import 'messages_provider.dart';

class UploadState {
  const UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.fileName = '',
    this.error,
  });

  final bool isUploading;
  final double progress;
  final String fileName;
  final String? error;
}

final uploadProvider =
    StateNotifierProvider.family<UploadNotifier, UploadState, int>(
  (ref, chatId) => UploadNotifier(chatId: chatId, ref: ref),
);

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier({required this.chatId, required this.ref})
      : super(const UploadState());

  final int chatId;
  final Ref ref;

  Future<void> uploadFile(File file, {String caption = ''}) async {
    state = UploadState(
      isUploading: true,
      progress: 0.0,
      fileName: file.path.split('/').last,
    );

    try {
      final message = await MediaUploadService.instance.uploadFile(
        file: file,
        chatId: chatId,
        caption: caption,
        onProgress: (p) {
          state = UploadState(
            isUploading: true,
            progress: p,
            fileName: state.fileName,
          );
        },
      );

      // Append the uploaded message to the messages list
      final entity = message.toEntity();
      final messagesNotifier = ref.read(messagesProvider(chatId).notifier);
      messagesNotifier.appendMessage(entity);

      state = const UploadState();
    } catch (e) {
      state = UploadState(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() => state = const UploadState();
}
