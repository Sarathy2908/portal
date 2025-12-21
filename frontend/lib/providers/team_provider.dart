import 'package:flutter/foundation.dart';
import '../core/api_service.dart';
import '../models/team.dart';
import '../models/queue_status.dart';
import '../services/storage_service.dart';

class TeamProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  Team? _currentTeam;
  QueueStatus? _queueStatus;
  String? _errorMessage;
  bool _isLoading = false;

  Team? get currentTeam => _currentTeam;
  QueueStatus? get queueStatus => _queueStatus;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void setAuthToken(String? token) {
    _apiService.setAuthToken(token);
  }

  Future<void> loadLastTeamData() async {
    final data = await _storageService.getLastTeamData();
    if (data['teamId'] != null && data['teamName'] != null && data['endpointUrl'] != null) {
      _currentTeam = Team(
        teamId: data['teamId']!,
        teamName: data['teamName']!,
        endpointUrl: data['endpointUrl']!,
      );
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getSubmissionHistory() async {
    return await _storageService.getSubmissionHistory();
  }

  Future<bool> submitEndpoint(Team team) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.submitEndpoint(team);
      _currentTeam = team;
      
      await _storageService.saveTeamData(
        teamId: team.teamId,
        teamName: team.teamName,
        endpointUrl: team.endpointUrl,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchQueueStatus(String teamId) async {
    try {
      _queueStatus = await _apiService.getQueueStatus(teamId);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
