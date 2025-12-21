import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/loading_indicator.dart';
import '../core/constants.dart';
import 'leaderboard_screen.dart';

class QueueStatusScreen extends StatefulWidget {
  final String teamId;

  const QueueStatusScreen({Key? key, required this.teamId}) : super(key: key);

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.pollInterval),
      (timer) => _fetchStatus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final provider = Provider.of<TeamProvider>(context, listen: false);
    await provider.fetchQueueStatus(widget.teamId);

    if (mounted && provider.queueStatus?.status == 'COMPLETED') {
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderboardScreen(highlightTeamId: widget.teamId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Status'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.queueStatus == null) {
            return const LoadingIndicator(message: 'Loading status...');
          }

          final status = provider.queueStatus!;

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hourglass_empty,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Evaluation Status',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          StatusBadge(status: status.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (status.position != null) ...[
                        Text(
                          'Queue Position: ${status.position}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (status.estimatedWaitTime != null) ...[
                        Text(
                          'Estimated Wait: ~${status.estimatedWaitTime} seconds',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (status.status == 'EVALUATING') ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text(
                          'Your model is being evaluated...',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                      if (status.status == 'FAILED') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                status.failureReason ?? 'Evaluation failed',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaderboardScreen(
                                highlightTeamId: widget.teamId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.leaderboard),
                        label: const Text('View Leaderboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
