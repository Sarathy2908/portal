import 'package:flutter/foundation.dart';
import '../core/api_service.dart';
import '../models/leaderboard.dart';

class LeaderboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<LeaderboardEntry> _leaderboard = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _leaderboard = await _apiService.getLeaderboard();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
