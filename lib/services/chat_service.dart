import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  Future<bool> sendMessage(ChatMessage message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sendmessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }
}