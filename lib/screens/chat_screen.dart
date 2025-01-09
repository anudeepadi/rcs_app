import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatManager _chatManager = ChatManager();
  final TextEditingController _messageController = TextEditingController();
  final String _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  final String _clientId = 'client_service';

  @override
  void dispose() {
    _chatManager.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _chatManager.sendMessage(
      _messageController.text,
      _userId,
      _clientId,
    );
    _messageController.clear();

    // Simulate client response
    Future.delayed(const Duration(seconds: 1), () {
      _chatManager.sendMessage(
        'Thanks for your message! How can I help you today?',
        _clientId,
        _userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<ChatMessage>(
              stream: _chatManager.messageStream,
              builder: (context, snapshot) {
                final messages = _chatManager.messages;
                
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.senderId == _userId;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isUser ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}