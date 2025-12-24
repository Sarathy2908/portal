import 'package:flutter/material.dart';
import '../models/leaderboard.dart';
import 'dart:math' as math;

class LeaderboardTable extends StatefulWidget {
  final List<LeaderboardEntry> entries;
  final String? highlightTeamId;

  const LeaderboardTable({
    Key? key,
    required this.entries,
    this.highlightTeamId,
  }) : super(key: key);

  @override
  State<LeaderboardTable> createState() => _LeaderboardTableState();
}

class _LeaderboardTableState extends State<LeaderboardTable> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.entries.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );
    }).toList();

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(LeaderboardTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries.length != widget.entries.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: MaterialStateProperty.all(
              Colors.blue.shade100.withOpacity(0.5),
            ),
            dataRowMinHeight: 64,
            dataRowMaxHeight: 80,
            columns: const [
              DataColumn(
                label: Text(
                  'Rank',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Team Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Accuracy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'F1 Score',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Latency (ms)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: widget.entries.asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final isHighlighted = entry.teamId == widget.highlightTeamId;
              final animation = index < _animations.length ? _animations[index] : null;

              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (entry.isPlagiarized) {
                    return Colors.red.shade50;
                  }
                  if (isHighlighted) {
                    return Colors.yellow.shade100;
                  }
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.blue.shade50;
                  }
                  return null;
                }),
                cells: [
                  DataCell(
                    animation != null
                        ? ScaleTransition(
                            scale: animation,
                            child: _buildRankCell(entry),
                          )
                        : _buildRankCell(entry),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.teamName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: entry.rank <= 3
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (entry.isPlagiarized) ...[
                          const SizedBox(width: 8),
                          _PlagiarismBadge(entry: entry),
                        ],
                      ],
                    ),
                  ),
                  DataCell(
                    _buildMetricCell(
                      '${(entry.accuracy * 100).toStringAsFixed(2)}%',
                      entry.accuracy,
                      animation,
                    ),
                  ),
                  DataCell(
                    _buildMetricCell(
                      entry.f1Score.toStringAsFixed(4),
                      entry.f1Score,
                      animation,
                    ),
                  ),
                  DataCell(
                    _buildMetricCell(
                      entry.latencyMs.toStringAsFixed(2),
                      1 - (entry.latencyMs / 1000),
                      animation,
                    ),
                  ),
                  DataCell(
                    _buildStatusCell(entry),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRankCell(LeaderboardEntry entry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entry.rank <= 3)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: Icon(
                  Icons.emoji_events,
                  color: entry.rank == 1
                      ? Colors.amber
                      : entry.rank == 2
                          ? Colors.grey.shade400
                          : Colors.brown.shade400,
                  size: 28,
                ),
              );
            },
          ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: entry.rank <= 3
                ? (entry.rank == 1
                    ? Colors.amber.shade100
                    : entry.rank == 2
                        ? Colors.grey.shade200
                        : Colors.brown.shade100)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            entry.rank.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  entry.rank <= 3 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCell(
      String text, double value, Animation<double>? animation) {
    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorForValue(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation,
        child: widget,
      );
    }
    return widget;
  }

  Color _getColorForValue(double value) {
    if (value >= 0.9) return Colors.green.shade100;
    if (value >= 0.7) return Colors.blue.shade100;
    if (value >= 0.5) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Widget _buildStatusCell(LeaderboardEntry entry) {
    if (entry.isPlagiarized) {
      return Tooltip(
        message: 'Plagiarism Detected',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade300, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade700, size: 18),
              const SizedBox(width: 4),
              Text(
                'FLAGGED',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
          const SizedBox(width: 4),
          Text(
            'CLEAN',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlagiarismBadge extends StatefulWidget {
  final LeaderboardEntry entry;

  const _PlagiarismBadge({required this.entry});

  @override
  State<_PlagiarismBadge> createState() => _PlagiarismBadgeState();
}

class _PlagiarismBadgeState extends State<_PlagiarismBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.entry.plagiarismSummary != null
          ? 'Similar to ${widget.entry.plagiarismSummary!.similarTeamsCount} team(s)\n'
              'Highest similarity: ${(widget.entry.plagiarismSummary!.highestSimilarity * 100).toStringAsFixed(1)}%'
          : 'Plagiarism detected',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.red.shade300,
                Colors.red.shade600,
                _controller.value,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.content_copy,
              size: 16,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
