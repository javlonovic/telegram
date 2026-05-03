import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';

/// Manages the presence WebSocket — tracks online/offline status of users.
class PresenceService {
  PresenceService._();
  static final PresenceService instance = PresenceService._();

  WebSocketChannel? _channel;
  final _presenceController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;

  Future<void> connect() async {
    if (_channel != null) return;
    final token = await TokenStorage.instance.getAccessToken();
    if (token == null) return;

    final uri = Uri.parse('${ApiConstants.presenceWs}?token=$token');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          _presenceController.add(decoded);
        } catch (_) {}
      },
      onDone: () => _channel = null,
      onError: (_) => disconnect(),
    );
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _presenceController.close();
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider for online status map  { userId: isOnline }
// ---------------------------------------------------------------------------

final onlineStatusProvider =
    StateNotifierProvider<OnlineStatusNotifier, Map<int, bool>>((ref) {
  return OnlineStatusNotifier();
});

class OnlineStatusNotifier extends StateNotifier<Map<int, bool>> {
  OnlineStatusNotifier() : super({}) {
    _listen();
  }

  StreamSubscription<Map<String, dynamic>>? _sub;

  void _listen() {
    _sub = PresenceService.instance.presenceStream.listen((event) {
      if (event['type'] == 'presence') {
        final userId = event['user_id'] as int;
        final isOnline = event['is_online'] as bool;
        state = {...state, userId: isOnline};
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
