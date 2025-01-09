import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatState _chatState = ChatState();
  final TextEditingController _messageController = TextEditingController();
  final String _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  final String _clientId = 'client_service';
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _chatState.initialize();
  }

  @override
  void dispose() {
    _chatState.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _showClearChatDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _chatState.clearChat();
    }
  }

  void _handleSendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();
    setState(() => _isComposing = false);

    await _chatState.sendMessage(
      content,
      _userId,
      _clientId,
      type: MessageType.text,
    );
  }

  void _handleQuickReply(QuickReply reply) async {
    await _chatState.sendMessage(
      reply.text,
      _userId,
      _clientId,
      type: MessageType.quickReply,
      metadata: {'payload': reply.payload},
    );
  }

  Widget _buildQuickReplies(List<QuickReply> quickReplies) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickReplies.length,
        itemBuilder: (context, index) {
          final reply = quickReplies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () => _handleQuickReply(reply),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(reply.text),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isUser = message.senderId == _userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildMessageBubble(message),
          if (message.quickReplies != null && message.quickReplies!.isNotEmpty)
            _buildQuickReplies(message.quickReplies!),
          if (message.type == MessageType.multimedia)
            _buildMultimediaContent(message),
        ],
      ),
    );
  }

  Widget _buildMultimediaContent(ChatMessage message) {
    // Handle multimedia content based on metadata
    if (message.metadata?['type'] == 'image') {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(message.metadata!['url']),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.senderId == _userId;

    return Container(
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: isUser ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(width: 4),
              if (isUser) _buildMessageStatus(message.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white70;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white70;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue[100]!;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red[300]!;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                // TODO: Implement file attachment
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (text) {
                  setState(() => _isComposing = text.isNotEmpty);
                  // Notify typing status
                  _chatState.setTyping(text.isNotEmpty);
                },
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isComposing ? _handleSendMessage : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearChatDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatState.messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageItem(message);
                  },
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: _chatState.typingStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Client is typing...'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}