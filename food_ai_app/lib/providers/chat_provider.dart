import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String sessionId = const Uuid().v4();
  final String userId;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({required this.userId});

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _messages = await _apiService.getConversationHistory(sessionId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, {String? imageBase64}) async {
    if (text.trim().isEmpty && imageBase64 == null) return;

    // Add user message to UI immediately
    final userMessage = Message(
      role: MessageRole.user,
      content: text,
      messageType: imageBase64 != null 
          ? MessageType.textWithImage 
          : MessageType.text,
    );
    
    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.sendMessage(
        sessionId: sessionId,
        userId: userId,
        message: text,
        imageData: imageBase64,
      );

      // Add AI response to messages
      final aiMessage = Message(
        role: MessageRole.assistant,
        content: response['message'] ?? '',
        timestamp: DateTime.parse(response['timestamp']),
      );
      
      _messages.add(aiMessage);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _apiService.clearConversationHistory(sessionId);
      _messages.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
