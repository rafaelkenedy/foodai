import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/message.dart';
import '../models/user_preferences.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String userId,
    required String message,
    String? imageData,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatMessage}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_id': sessionId,
              'user_id': userId,
              'message': message,
              if (imageData != null) 'image_data': imageData,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<List<Message>> getConversationHistory(String sessionId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatHistory}/$sessionId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting history: $e');
    }
  }

  Future<void> clearConversationHistory(String sessionId) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatHistory}/$sessionId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to clear history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing history: $e');
    }
  }

  Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.preferences}/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return UserPreferences.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting preferences: $e');
    }
  }

  Future<UserPreferences> updateUserPreferences(
      UserPreferences preferences) async {
    try {
      final response = await _client
          .put(
            Uri.parse(
                '${ApiConfig.baseUrl}${ApiConfig.preferences}/${preferences.userId}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(preferences.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return UserPreferences.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating preferences: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
