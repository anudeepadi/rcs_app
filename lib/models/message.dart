import 'package:flutter/foundation.dart';

enum MessageType {
  text,
  quickReply,
  systemMessage,
  multimedia
}

enum MessageStatus {
  sent,
  delivered,
  read,
  failed
}

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String recipientId;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  final List<QuickReply>? quickReplies;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.recipientId,
    required this.timestamp,
    required this.type,
    this.status = MessageStatus.sent,
    this.metadata,
    this.quickReplies,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['sender_id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      metadata: json['metadata'],
      quickReplies: (json['quick_replies'] as List<dynamic>?)
          ?.map((e) => QuickReply.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'metadata': metadata,
      'quick_replies': quickReplies?.map((e) => e.toJson()).toList(),
    };
  }
}

class QuickReply {
  final String id;
  final String text;
  final String? payload;
  final String? imageUrl;

  QuickReply({
    required this.id,
    required this.text,
    this.payload,
    this.imageUrl,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'],
      text: json['text'],
      payload: json['payload'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'payload': payload,
      'image_url': imageUrl,
    };
  }
}