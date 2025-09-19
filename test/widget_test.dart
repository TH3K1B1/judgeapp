import 'package:flutter/material.dart';

enum RunType { qualification1, qualification2, final1, final2 }

void main() => runApp(SkateJudgeApp());

class SkateJudgeApp extends StatelessWidget {
  const SkateJudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: JudgeScreen());
  }
}

class JudgeScreen extends StatefulWidget {
  const JudgeScreen({super.key});

  @override
  _JudgeScreenState createState() => _JudgeScreenState();
}

class _JudgeScreenState extends State<JudgeScreen> {
  RunType currentRun = RunType.qualification1;
  String contestantName = '';
  final letters = ['A', 'B', 'C', 'D', 'E'];
  final Map<String, Map<RunType, double>> scores = {};

  @override
  void initState() {
    super.initState();
    for (var letter in letters) {
      scores[letter] = {
        for (var run in RunType.values) run: 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: currentRun.index,
            onDestinationSelected: (index) {
              setState(() => currentRun = RunType.values[index]);
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.looks_one), label: Text('Qual 1')),
              NavigationRailDestination(
                  icon: Icon(Icons.looks_two), label: Text('Qual 2')),
              NavigationRailDestination(
                  icon: Icon(Icons.filter_1), label: Text('Final 1')),
              NavigationRailDestination(
                  icon: Icon(Icons.filter_2), label: Text('Final 2')),
            ],
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Contestant Name'),
                    onChanged: (value) =>
                        setState(() => contestantName = value),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: letters.length,
                    itemBuilder: (context, index) {
                      final letter = letters[index];
                      final editable = true; // Only current run editable
                      return Card(
                        margin: EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Letter: $letter',
                                  style: TextStyle(fontSize: 24)),
                              TextField(
                                enabled: editable,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Score for ${currentRun.name}'),
                                onChanged: (val) {
                                  setState(() {
                                    scores[letter]![currentRun] =
                                        double.tryParse(val) ?? 0.0;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
