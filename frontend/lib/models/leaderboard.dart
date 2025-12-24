class PlagiarismSummary {
  final bool isFlagged;
  final int similarTeamsCount;
  final double highestSimilarity;
  final List<String> similarTeams;

  PlagiarismSummary({
    required this.isFlagged,
    required this.similarTeamsCount,
    required this.highestSimilarity,
    required this.similarTeams,
  });

  factory PlagiarismSummary.fromJson(Map<String, dynamic> json) {
    return PlagiarismSummary(
      isFlagged: json['is_flagged'] ?? false,
      similarTeamsCount: json['similar_teams_count'] ?? 0,
      highestSimilarity: (json['highest_similarity'] ?? 0.0).toDouble(),
      similarTeams: List<String>.from(json['similar_teams'] ?? []),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String teamId;
  final String teamName;
  final double accuracy;
  final double f1Score;
  final double latencyMs;
  final String evaluatedAt;
  final bool isPlagiarized;
  final PlagiarismSummary? plagiarismSummary;

  LeaderboardEntry({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.accuracy,
    required this.f1Score,
    required this.latencyMs,
    required this.evaluatedAt,
    this.isPlagiarized = false,
    this.plagiarismSummary,
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
      isPlagiarized: json['is_plagiarized'] ?? false,
      plagiarismSummary: json['plagiarism_summary'] != null
          ? PlagiarismSummary.fromJson(json['plagiarism_summary'])
          : null,
    );
  }
}
