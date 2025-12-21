class QueueStatus {
  final String teamId;
  final String status;
  final int? position;
  final int? estimatedWaitTime;
  final String? failureReason;

  QueueStatus({
    required this.teamId,
    required this.status,
    this.position,
    this.estimatedWaitTime,
    this.failureReason,
  });

  factory QueueStatus.fromJson(Map<String, dynamic> json) {
    return QueueStatus(
      teamId: json['team_id'],
      status: json['status'],
      position: json['position'],
      estimatedWaitTime: json['estimated_wait_time'],
      failureReason: json['failure_reason'],
    );
  }
}
