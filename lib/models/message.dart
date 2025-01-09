class ChatMessage {
  final String id;
  final String content;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      sender: json['sender'] ?? 'Unknown',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isMe: json['isMe'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
    };
  }
}