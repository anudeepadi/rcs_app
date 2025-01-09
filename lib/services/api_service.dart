import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  Future<List<ChatMessage>> getMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      throw Exception('Failed to load messages');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> sendMessage(ChatMessage message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sendmessage'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<ChatMessage?> getMessage(String messageId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$messageId'),
      );
      if (response.statusCode == 200) {
        return ChatMessage.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get message: $e');
    }
  }

  Future<bool> clearMessages() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/messages'),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to clear messages: $e');
    }
  }
}