import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_avatar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(name: 'Chat $chatId', size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat $chatId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Text('online',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: const Center(
        child: Text('Messages will appear here — Phase 2'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Message',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
