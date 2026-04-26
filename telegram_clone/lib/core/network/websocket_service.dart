import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';

/// Manages a single WebSocket connection to a chat room.
class WebSocketService {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  int? _currentChatId;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect(int chatId) async {
    // Already connected to this chat
    if (_currentChatId == chatId && _channel != null) return;

    // Disconnect from previous chat
    await disconnect();

    final token = await TokenStorage.instance.getAccessToken();
    if (token == null) return;

    final uri = Uri.parse(
      '${ApiConstants.wsBaseUrl}/ws/chat/$chatId/?token=$token',
    );

    _channel = WebSocketChannel.connect(uri);
    _currentChatId = chatId;

    _channel!.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          _messageController.add(decoded);
        } catch (_) {}
      },
      onError: (_) => disconnect(),
      onDone: () => _currentChatId = null,
    );
  }

  void sendMessage({required String content, String type = 'text'}) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({'content': content, 'type': type}));
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _currentChatId = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
