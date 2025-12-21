class Team {
  final String teamId;
  final String teamName;
  final String endpointUrl;

  Team({
    required this.teamId,
    required this.teamName,
    required this.endpointUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'team_name': teamName,
      'endpoint_url': endpointUrl,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['team_id'],
      teamName: json['team_name'],
      endpointUrl: json['endpoint_url'],
    );
  }
}
