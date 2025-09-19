import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/drawing_utils.dart';
import '../utils/contestant_names_page.dart'; // Corrected import path
import 'overall_stats_page.dart';

class JudgeHomePage extends StatefulWidget {
  const JudgeHomePage({super.key});

  @override
  State<JudgeHomePage> createState() => _JudgeHomePageState();
}

class _JudgeHomePageState extends State<JudgeHomePage> {
  Widget _buildContestSwitcher() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        isSelected: [selectedContest == 'Kids', selectedContest == 'Grown'],
        onPressed: (idx) {
          setState(() {
            selectedContest = idx == 0 ? 'Kids' : 'Grown';
          });
        },
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Kids'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Grown'),
          ),
        ],
      ),
    );
  }
  void _openOverallStatsPage() {
    // Build stats from current contest
    final contestContestantNames = contestantNames[selectedContest] ?? {};
    final contestScores = scores[selectedContest] ?? {};
    final List<ContestantStats> stats = contestContestantNames.entries.map((entry) {
      final letter = entry.key;
      final name = entry.value;
      double qual1 = 0.0;
      double qual2 = 0.0;
      if (contestScores[letter] != null) {
        final qual1Scores = contestScores[letter]?[RunType.qual1] ?? {};
        final qual2Scores = contestScores[letter]?[RunType.qual2] ?? {};
        qual1 = (qual1Scores.values).fold(0.0, (a, b) => a + b);
        qual2 = (qual2Scores.values).fold(0.0, (a, b) => a + b);
      }
      return ContestantStats(name: name, qualification1: qual1, qualification2: qual2);
    }).toList();
    stats.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    final int cutIndex = 0; // TODO: set cut index based on rules
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => OverallStatsPage(stats: stats, cutIndex: cutIndex),
    ));
  }
  String selectedContest = 'Kids'; // 'Kids' or 'Grown'
  List<String> letters = [];
  bool drawingMode = false;
  bool eraserMode = false;
  RunType currentRun = RunType.qual1;
  bool showEditNames = false;
  Map<String, Map<String, String>> contestantNames = {
    'Kids': {},
    'Grown': {},
  };
  Map<String, Map<String, Map<RunType, Map<String, double>>>> scores = {
    'Kids': {},
    'Grown': {},
  };
  Map<String, Map<String, Map<RunType, List<Stroke>>>> drawings = {
    'Kids': {},
    'Grown': {},
  };
  final PageController _pageController = PageController();
  bool _isEditingNames = false;

  @override
  void initState() {
    super.initState();
    // Lock the orientation to portrait (vertical) mode only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Load contestants (simulate loading from storage or backend)
    loadContestants();
  }

  void loadContestants() {
    // Simulate loading contestants, e.g. from local storage or backend
    // For now, just check if contestantNames is empty
    if ((contestantNames[selectedContest] ?? {}).isEmpty) {
      letters = [];
    } else {
      letters = contestantNames[selectedContest]!.keys.toList();
    }
  }

  void updateContestants(Map<String, String> updatedNames) {
    contestantNames[selectedContest] = updatedNames;
    loadContestants();
    setState(() {
      showEditNames = false;
    });
  }

  void _openContestantNamesPage() async {
    final updatedNames = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => ContestantNamesPage(
          contestantNames: contestantNames[selectedContest] ?? {},
          onSave: updateContestants,
        ),
      ),
    );
    if (updatedNames != null) {
      updateContestants(updatedNames);
      loadContestants();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final contestContestantNames = contestantNames[selectedContest];
    final contestScores = scores[selectedContest];
    final contestDrawings = drawings[selectedContest];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 56,
        title: const Text('Skate Judge',
            style: TextStyle(
                color: Color(0xFF222B45),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2)),
        actions: [
          IconButton(
            tooltip: 'Draw',
            icon: Icon(
              drawingMode ? Icons.brush : Icons.brush_outlined,
              color: drawingMode ? Colors.blue : Color(0xFF222B45),
            ),
            onPressed: () {
              setState(() {
                drawingMode = !drawingMode;
                eraserMode = false;
              });
            },
          ),
          IconButton(
            tooltip: 'Eraser',
            icon: Icon(
              Icons.cleaning_services,
              color: eraserMode ? Colors.red : Color(0xFF222B45),
            ),
            onPressed: () {
              if (drawingMode) {
                final pageIdx = _pageController.hasClients ? _pageController.page?.toInt() ?? 0 : 0;
                final drawingMap = (contestDrawings != null && letters.isNotEmpty)
                    ? contestDrawings[letters[pageIdx]]
                    : null;
                if (drawingMap != null) {
                  setState(() {
                    drawingMap[currentRun] = [];
                  });
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildContestSwitcher(),
          Expanded(
            child: Row(
              children: [
                JudgeSidebar(
                  currentRun: currentRun,
                  onEditNamesPressed: _openContestantNamesPage,
                  onRunSelected: (run) {
                    setState(() {
                      currentRun = run;
                    });
                  },
                ),
                Expanded(
                  child: (contestContestantNames?.isEmpty ?? true)
                      ? Center(
                          child: Text(
                            'Add contestants',
                            style: TextStyle(fontSize: 24, color: Color(0xFF222B45), fontWeight: FontWeight.bold),
                          ),
                        )
                      : JudgeContent(
                          showEditNames: false,
                          letters: letters,
                          contestantNames: contestContestantNames ?? {},
                          scores: contestScores ?? {},
                          drawings: contestDrawings ?? {},
                          drawingMode: drawingMode,
                          currentRun: currentRun,
                          pageController: _pageController,
                          onContestantNamesSave: updateContestants,
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

class JudgeSidebar extends StatelessWidget {
  final RunType currentRun;
  final VoidCallback onEditNamesPressed;
  final ValueChanged<RunType> onRunSelected;

  const JudgeSidebar({
    Key? key,
    required this.currentRun,
    required this.onEditNamesPressed,
    required this.onRunSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return NavigationRail(
    minWidth: 24,
        groupAlignment: -1.0, // Align buttons to the top
        selectedIndex: currentRun.index,
        onDestinationSelected: (idx) {
          if (idx < RunType.values.length) {
            onRunSelected(RunType.values[idx]);
          } else if (idx == RunType.values.length) {
            onEditNamesPressed();
          } else if (idx == RunType.values.length + 1) {
            // Call parent method to open stats page
            final state = context.findAncestorStateOfType<_JudgeHomePageState>();
            state?._openOverallStatsPage();
          }
        },
        labelType: NavigationRailLabelType.all,
        destinations: [
          const NavigationRailDestination(
            icon: Icon(Icons.looks_one, color: Color(0xFF222B45)),
            label: Text('Qual 1',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.w600)),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.looks_two, color: Color(0xFF222B45)),
            label: Text('Qual 2',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.w600)),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.filter_1, color: Color(0xFF222B45)),
            label: Text('Final 1',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.w600)),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.filter_2, color: Color(0xFF222B45)),
            label: Text('Final 2',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.w600)),
          ),
          NavigationRailDestination(
            icon: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF222B45)),
              tooltip: 'Names',
              onPressed: onEditNamesPressed,
            ),
            label: const Text(
              'Names',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.w600),
            ),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.leaderboard, color: Color(0xFF222B45)),
            label: Text('Stats',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      );
  }
}

class JudgeContent extends StatelessWidget {
  final bool showEditNames;
  final List<String> letters;
  final Map<String, String> contestantNames;
  final Map<String, Map<RunType, Map<String, double>>> scores;
  final Map<String, Map<RunType, List<Stroke>>> drawings;
  final bool drawingMode;
  final RunType currentRun;
  final PageController pageController;
  final Function(Map<String, String>) onContestantNamesSave;

  const JudgeContent({
    Key? key,
    required this.showEditNames,
    required this.letters,
    required this.contestantNames,
    required this.scores,
    required this.drawings,
    required this.drawingMode,
    required this.currentRun,
    required this.pageController,
    required this.onContestantNamesSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showEditNames) {
      return ContestantNamesPage(
        contestantNames: contestantNames,
        onSave: onContestantNamesSave,
      );
    }
    if (letters.isEmpty) {
      return Center(
        child: Text(
          'Add contestants',
          style: TextStyle(fontSize: 24, color: Color(0xFF222B45), fontWeight: FontWeight.bold),
        ),
      );
    }
    return PageView.builder(
      itemCount: letters.length,
      physics: drawingMode
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      controller: pageController,
      itemBuilder: (context, idx) {
        final letter = letters[idx % letters.length];
        return StatefulBuilder(
          builder: (context, setState) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  contestantNames[letter] ?? '',
                  style: const TextStyle(fontSize: 18, color: Color(0xFF222B45), fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Table(
                    border: TableBorder.symmetric(inside: BorderSide(color: Color(0xFFE4E9F2))),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                        ),
                        children: [
                          for (final title in const [
                            'Run',
                            'Level',
                            'Creativity',
                            'Style',
                            'Stay On',
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Center(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFF222B45),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],),  
                      for (var run in RunType.values)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  runLabels[run] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Color(0xFF222B45),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            for (var cat in ['Level', 'Creativity', 'Style', 'Stay On'])
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: DropdownButton<int>(
                                  value: (scores[letter]?[run]?[cat]?.toInt() ?? 1).clamp(1, 10),
                                  items: List.generate(10, (index) => index + 1)
                                      .map((value) => DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(
                                              value.toString(),
                                              style: const TextStyle(fontSize: 16, color: Color(0xFF222B45)),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: run == currentRun
                                      ? (val) {
                                          scores[letter] ??= {};
                                          scores[letter]![run] ??= {};
                                          scores[letter]![run]![cat] = (val ?? 0).toDouble();
                                          setState(() {});
                                        }
                                      : null,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: _DrawingArea(
                  strokes: drawings[letter]?[currentRun] ?? [],
                  onStrokeUpdate: (newStrokes) {
                    drawings[letter] ??= {};
                    drawings[letter]![currentRun] = newStrokes;
                  },
                  onClear: () {
                    drawings[letter] ??= {};
                    drawings[letter]![currentRun] = [];
                  },
                  drawingMode: drawingMode,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.width;

      if (stroke.points.length > 1) {
        for (var i = 0; i < stroke.points.length - 1; i++) {
          canvas.drawLine(
            stroke.points[i],
            stroke.points[i + 1],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _DrawingArea extends StatefulWidget {
  final List<Stroke> strokes;
  final ValueChanged<List<Stroke>> onStrokeUpdate;
  final VoidCallback onClear;
  final bool drawingMode;

  const _DrawingArea({
    Key? key,
    required this.strokes,
    required this.onStrokeUpdate,
    required this.onClear,
    required this.drawingMode,
  }) : super(key: key);

  @override
  State<_DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<_DrawingArea> {
  List<Stroke> _strokes = [];
  Stroke? _currentStroke;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.strokes);
  }

  @override
  void didUpdateWidget(_DrawingArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.strokes != oldWidget.strokes) {
      setState(() {
        _strokes = List.from(widget.strokes);
      });
    }
  }

  void _startStroke(Offset pos) {
    if (!widget.drawingMode) return;
    setState(() {
      _currentStroke = Stroke();
      _currentStroke!.points.add(pos);
    });
  }

  void _updateStroke(Offset pos) {
    if (!widget.drawingMode) return;
    setState(() {
      _currentStroke?.points.add(pos);
    });
  }

  void _endStroke() {
    if (!widget.drawingMode) return;
    if (_currentStroke != null && _currentStroke!.points.length > 1) {
      setState(() {
        _strokes.add(_currentStroke!);
        widget.onStrokeUpdate(_strokes);
        _currentStroke = null;
      });
    } else {
      setState(() {
        _currentStroke = null;
      });
    }
  }

  void clearDrawingFromParent() {
    setState(() {
      clearStrokes(_strokes);
      widget.onStrokeUpdate(_strokes);
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: widget.drawingMode ? (details) => _startStroke(details.localPosition) : null,
      onPanUpdate: widget.drawingMode ? (details) => _updateStroke(details.localPosition) : null,
      onPanEnd: widget.drawingMode ? (_) => _endStroke() : null,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomPaint(
          painter: NotesPainter(
            strokesByRun: _strokes,
            blockRect: null,
            tempStroke: _currentStroke,
          ),
          child: Container(),
        ),
      ),
    );
  }
}
