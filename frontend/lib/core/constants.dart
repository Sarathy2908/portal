class AppConstants {
  // Use environment variable for API URL, fallback to Vercel backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-git-main-arjuns-projects-8874ea54.vercel.app',
  );
  
  static const String submitEndpoint = '/submit-endpoint';
  static const String queueStatusEndpoint = '/queue-status';
  static const String leaderboardEndpoint = '/leaderboard';
  static const String teamResultEndpoint = '/team-result';
  
  static const int pollInterval = 5;
  
  static const Map<String, int> statusColors = {
    'QUEUED': 0xFFFFA726,
    'EVALUATING': 0xFF42A5F5,
    'COMPLETED': 0xFF66BB6A,
    'FAILED': 0xFFEF5350,
  };
}
