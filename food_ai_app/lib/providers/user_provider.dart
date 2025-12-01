import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String userId;

  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  UserProvider({required this.userId});

  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _preferences = await _apiService.getUserPreferences(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _preferences = await _apiService.updateUserPreferences(newPreferences);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
