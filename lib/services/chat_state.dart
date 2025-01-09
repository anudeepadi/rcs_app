import 'dart:async';
import '../models/message.dart';
import 'api_service.dart';

class ChatState {
  final ApiService _apiService = ApiService();
  final _messageController = StreamController<List<ChatMessage>>.broadcast();
  final _typingController = StreamController<bool>.broadcast();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  Stream<List<ChatMessage>> get messagesStream => _messageController.stream;
  Stream<bool> get typingStream => _typingController.stream;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  Future<void> initialize() async {
    try {
      final messages = await _apiService.getMessages();
      _messages.addAll(messages);
      _messageController.add(_messages);
    } catch (e) {
      debugPrint('Failed to initialize chat: $e');
    }
  }

  Future<void> sendMessage(String content, String senderId, String recipientId, {
    MessageType type = MessageType.text,
    List<QuickReply>? quickReplies,
    Map<String, dynamic>? metadata,
  }) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: senderId,
      recipientId: recipientId,
      timestamp: DateTime.now(),
      type: type,
      quickReplies: quickReplies,
      metadata: metadata,
    );

    try {
      final success = await _apiService.sendMessage(message);
      if (success) {
        _messages.add(message);
        _messageController.add(_messages);
      }
    } catch (e) {
      debugPrint('Failed to send message: $e');
      // Add message locally with failed status
      final failedMessage = ChatMessage(
        id: message.id,
        content: message.content,
        senderId: message.senderId,
        recipientId: message.recipientId,
        timestamp: message.timestamp,
        type: message.type,
        status: MessageStatus.failed,
        quickReplies: message.quickReplies,
        metadata: message.metadata,
      );
      _messages.add(failedMessage);
      _messageController.add(_messages);
    }
  }

  void setTyping(bool isTyping) {
    _isTyping = isTyping;
    _typingController.add(_isTyping);
  }

  Future<void> markAsRead(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      final updatedMessage = ChatMessage(
        id: message.id,
        content: message.content,
        senderId: message.senderId,
        recipientId: message.recipientId,
        timestamp: message.timestamp,
        type: message.type,
        status: MessageStatus.read,
        quickReplies: message.quickReplies,
        metadata: message.metadata,
      );
      _messages[index] = updatedMessage;
      _messageController.add(_messages);
    }
  }

  Future<void> clearChat() async {
    try {
      final success = await _apiService.clearMessages();
      if (success) {
        _messages.clear();
        _messageController.add(_messages);
      }
    } catch (e) {
      debugPrint('Failed to clear chat: $e');
    }
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}