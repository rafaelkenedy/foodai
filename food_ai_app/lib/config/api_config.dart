class ApiConfig {
  // Base URL for the backend API
  static const String baseUrl = 'http://localhost:8000';
  
  // API Endpoints
  static const String chatMessage = '/api/chat/message';
  static const String chatHistory = '/api/chat/history';
  static const String preferences = '/api/preferences';
  static const String orders = '/api/orders';
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}
