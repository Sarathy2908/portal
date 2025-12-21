import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _teamIdKey = 'last_team_id';
  static const String _teamNameKey = 'last_team_name';
  static const String _endpointUrlKey = 'last_endpoint_url';
  static const String _submissionsKey = 'submission_history';

  Future<void> saveTeamData({
    required String teamId,
    required String teamName,
    required String endpointUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_teamIdKey, teamId);
    await prefs.setString(_teamNameKey, teamName);
    await prefs.setString(_endpointUrlKey, endpointUrl);
    
    await _addToHistory(teamId, teamName, endpointUrl);
  }

  Future<Map<String, String?>> getLastTeamData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'teamId': prefs.getString(_teamIdKey),
      'teamName': prefs.getString(_teamNameKey),
      'endpointUrl': prefs.getString(_endpointUrlKey),
    };
  }

  Future<void> _addToHistory(String teamId, String teamName, String endpointUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_submissionsKey) ?? '[]';
    final List<dynamic> history = json.decode(historyJson);
    
    final submission = {
      'teamId': teamId,
      'teamName': teamName,
      'endpointUrl': endpointUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    history.insert(0, submission);
    
    if (history.length > 10) {
      history.removeLast();
    }
    
    await prefs.setString(_submissionsKey, json.encode(history));
  }

  Future<List<Map<String, dynamic>>> getSubmissionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_submissionsKey) ?? '[]';
    final List<dynamic> history = json.decode(historyJson);
    return history.cast<Map<String, dynamic>>();
  }

  Future<void> clearTeamData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_teamIdKey);
    await prefs.remove(_teamNameKey);
    await prefs.remove(_endpointUrlKey);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_submissionsKey);
  }
}
