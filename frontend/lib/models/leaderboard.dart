class LeaderboardEntry {
  final int rank;
  final String teamId;
  final String teamName;
  final double accuracy;
  final double f1Score;
  final double latencyMs;
  final String evaluatedAt;

  LeaderboardEntry({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.accuracy,
    required this.f1Score,
    required this.latencyMs,
    required this.evaluatedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      teamId: json['team_id'],
      teamName: json['team_name'],
      accuracy: json['accuracy'].toDouble(),
      f1Score: json['f1_score'].toDouble(),
      latencyMs: json['latency_ms'].toDouble(),
      evaluatedAt: json['evaluated_at'],
    );
  }
}
