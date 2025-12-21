import 'package:flutter/material.dart';
import '../models/leaderboard.dart';

class LeaderboardTable extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? highlightTeamId;

  const LeaderboardTable({
    Key? key,
    required this.entries,
    this.highlightTeamId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 72,
          columns: const [
            DataColumn(label: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            DataColumn(label: Expanded(child: Text('Team Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
            DataColumn(label: Text('Accuracy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), numeric: true),
            DataColumn(label: Text('F1 Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), numeric: true),
            DataColumn(label: Text('Latency (ms)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), numeric: true),
          ],
          rows: entries.map((entry) {
            final isHighlighted = entry.teamId == highlightTeamId;
            return DataRow(
              color: MaterialStateProperty.all(
                isHighlighted ? Colors.yellow.shade100 : null,
              ),
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entry.rank <= 3)
                        Icon(
                          Icons.emoji_events,
                          color: entry.rank == 1
                              ? Colors.amber
                              : entry.rank == 2
                                  ? Colors.grey
                                  : Colors.brown,
                          size: 24,
                        ),
                      const SizedBox(width: 8),
                      Text(entry.rank.toString(), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                DataCell(Text(entry.teamName, style: const TextStyle(fontSize: 16))),
                DataCell(Text('${(entry.accuracy * 100).toStringAsFixed(2)}%', style: const TextStyle(fontSize: 16))),
                DataCell(Text(entry.f1Score.toStringAsFixed(4), style: const TextStyle(fontSize: 16))),
                DataCell(Text(entry.latencyMs.toStringAsFixed(2), style: const TextStyle(fontSize: 16))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
