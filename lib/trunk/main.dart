import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum RunType { qualification1, qualification2, final1, final2 }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(SkateJudgeApp());
  });
}

class SkateJudgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JudgeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JudgeScreen extends StatefulWidget {
  @override
  _JudgeScreenState createState() => _JudgeScreenState();
}

class _JudgeScreenState extends State<JudgeScreen> {
  RunType currentRun = RunType.qualification1;
  final letters = ['A', 'B', 'C', 'D', 'E'];
  final Map<String, String> contestantNames = {};

  // scores[letter][run][category]
  final Map<String, Map<RunType, Map<String, double>>> scores = {};

  // short labels for the runs
  final Map<RunType, String> runLabels = {
    RunType.qualification1: 'Q1',
    RunType.qualification2: 'Q2',
    RunType.final1: 'F1',
    RunType.final2: 'F2',
  };

  final List<String> categories = [
    'Level',
    'Creativity',
    'Style',
    'Stay On',
  ];

  @override
  void initState() {
    super.initState();
    for (var letter in letters) {
      contestantNames[letter] = '';
      scores[letter] = {
        for (var run in RunType.values)
          run: {
            for (var cat in categories) cat: 0.0,
          }
      };
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Skate Judge'),
      backgroundColor: Colors.blueGrey,
      toolbarHeight: 40, // much smaller top bar
    ),
    body: Row(
      children: [
        NavigationRail(
          selectedIndex: currentRun.index,
          onDestinationSelected: (idx) =>
              setState(() => currentRun = RunType.values[idx]),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.looks_one),
              label: Text('Qual 1'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.looks_two),
              label: Text('Qual 2'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.filter_1),
              label: Text('Final 1'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.filter_2),
              label: Text('Final 2'),
            ),
          ],
        ),
        Expanded(
          child: PageView.builder(
            itemCount: letters.length,
            itemBuilder: (context, idx) {
              final letter = letters[idx];
              return Card(
                margin: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Contestant Name',
                          ),
                          controller: TextEditingController(
                            text: contestantNames[letter],
                          ),
                          onChanged: (val) => setState(
                            () => contestantNames[letter] = val,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Table(
                          border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(2),
                          },
                          children: [
                            // header
                            const TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.blueGrey),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Run',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Level',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Creativity',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Style',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Stay On',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // data rows
                            for (var run in RunType.values)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(runLabels[run]!),
                                  ),
                                  for (var cat in categories)
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: TextField(
                                        enabled: run == currentRun,
                                        keyboardType:
                                            TextInputType.number,
                                        controller: TextEditingController(
                                          text: scores[letter]![run]![cat]
                                              .toString(),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            scores[letter]![run]![cat] =
                                                double.tryParse(val) ?? 0.0;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ); // End of Card
            },
          ), // End of PageView.builder
        ), // End of Expanded
      ],
    ), // End of Row
  ); // End of Scaffold
}
}