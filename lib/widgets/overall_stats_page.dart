import 'package:flutter/material.dart';

class OverallStatsPage extends StatelessWidget {
  final List<ContestantStats> stats;
  final int cutIndex;

  const OverallStatsPage({
    Key? key,
    required this.stats,
    required this.cutIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overall Stats')),
      body: ListView.builder(
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final contestant = stats[index];
          final isCutLine = index == cutIndex;
          return Column(
            children: [
              ListTile(
                leading: Text('#${index + 1}'),
                title: Text(contestant.name),
                subtitle: Text('Total Points: ${contestant.totalPoints}'),
              ),
              if (isCutLine)
                Divider(
                  thickness: 2,
                  color: Colors.red,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        },
      ),
    );
  }
}

class ContestantStats {
  final String name;
  final double qualification1;
  final double qualification2;
  double get totalPoints => qualification1 + qualification2;

  ContestantStats({
    required this.name,
    required this.qualification1,
    required this.qualification2,
  });
}
