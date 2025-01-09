import 'dart:async';
import '../models/message.dart';

class ChatManager {
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _messages = <ChatMessage>[];
  
  Stream<ChatMessage> get messageStream => _messageController.stream;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendMessage(String content, String senderId, String recipientId) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: senderId,
      recipientId: recipientId,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    
    _messages.add(message);
    _messageController.add(message);
  }

  void sendQuickReply(String content, String senderId, String recipientId) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: senderId,
      recipientId: recipientId,
      timestamp: DateTime.now(),
      type: MessageType.quickReply,
    );
    
    _messages.add(message);
    _messageController.add(message);
  }

  void sendSystemMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: 'system',
      recipientId: 'all',
      timestamp: DateTime.now(),
      type: MessageType.systemMessage,
    );
    
    _messages.add(message);
    _messageController.add(message);
  }

  List<ChatMessage> getMessageHistory() {
    return _messages;
  }

  void dispose() {
    _messageController.close();
  }
}