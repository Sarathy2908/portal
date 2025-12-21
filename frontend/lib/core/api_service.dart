import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import '../models/team.dart';
import '../models/leaderboard.dart';
import '../models/queue_status.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({this.baseUrl = AppConstants.apiBaseUrl});

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> testAuth() async {
    final url = Uri.parse('$baseUrl/test-auth');
    
    try {
      print('Testing auth with token: ${_authToken?.substring(0, 50)}...');
      final response = await http.post(url, headers: _getHeaders());
      print('Test auth response: ${response.statusCode} - ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Test auth error: $e');
      throw Exception('Test auth failed: $e');
    }
  }

  Future<Map<String, dynamic>> submitEndpoint(Team team) async {
    final url = Uri.parse('$baseUrl${AppConstants.submitEndpoint}');
    
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'team_id': team.teamId,
          'team_name': team.teamName,
          'endpoint_url': team.endpointUrl,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to submit endpoint');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<QueueStatus> getQueueStatus(String teamId) async {
    final url = Uri.parse('$baseUrl${AppConstants.queueStatusEndpoint}/$teamId');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return QueueStatus.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get queue status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final url = Uri.parse('$baseUrl${AppConstants.leaderboardEndpoint}');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaderboardEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get leaderboard');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getTeamResult(String teamId) async {
    final url = Uri.parse('$baseUrl${AppConstants.teamResultEndpoint}/$teamId');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get team result');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
