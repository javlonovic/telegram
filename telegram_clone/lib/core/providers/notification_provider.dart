import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Unread badge counts per chat
// ---------------------------------------------------------------------------

final unreadCountProvider =
    StateNotifierProvider<UnreadCountNotifier, Map<int, int>>((ref) {
  return UnreadCountNotifier();
});

class UnreadCountNotifier extends StateNotifier<Map<int, int>> {
  UnreadCountNotifier() : super({});

  void increment(int chatId) {
    state = {...state, chatId: (state[chatId] ?? 0) + 1};
  }

  void clear(int chatId) {
    final updated = Map<int, int>.from(state);
    updated.remove(chatId);
    state = updated;
  }

  void clearAll() => state = {};

  int totalUnread() => state.values.fold(0, (a, b) => a + b);
}

// ---------------------------------------------------------------------------
// Foreground notification stream provider
// ---------------------------------------------------------------------------

/// Emits [RemoteMessage] whenever a foreground FCM message arrives.
final foregroundMessageProvider = StreamProvider<RemoteMessage>((ref) {
  return FirebaseMessaging.onMessage;
});
