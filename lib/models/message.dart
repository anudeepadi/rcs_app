class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String recipientId;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.recipientId,
    required this.timestamp,
    required this.type,
  });
}

enum MessageType {
  text,
  quickReply,
  systemMessage,
}