
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const JudgeApp());
enum RunType { qual1, qual2, final1, final2 }
class JudgeApp extends StatelessWidget {
  const JudgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF222B45),
          secondary: Colors.blue,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const JudgeHomePage(),
    );
  }
}

class JudgeHomePage extends StatefulWidget {
  const JudgeHomePage({Key? key}) : super(key: key);

  @override
  State<JudgeHomePage> createState() => _JudgeHomePageState();
}

class _JudgeHomePageState extends State<JudgeHomePage> {
  // State variables and logic
  final List<String> letters = ['A', 'B', 'C', 'D'];
  bool drawingMode = false;
  bool eraserMode = false;
  RunType currentRun = RunType.qual1;
  final List<String> categories = ['Level', 'Creativity', 'Style', 'Stay On'];
  final Map<String, Map<RunType, Map<String, double>>> scores = {
    for (var letter in ['A', 'B', 'C', 'D'])
      letter: {
        for (var run in RunType.values)
          run: {
            for (var cat in ['Level', 'Creativity', 'Style', 'Stay On']) cat: 0.0,
          },
      },
  };
  final Map<String, Map<RunType, List<_Stroke>>> drawings = {
    for (var letter in ['A', 'B', 'C', 'D'])
      letter: {
        for (var run in RunType.values) run: <_Stroke>[],
      },
  };
  final Map<String, String> contestantNames = {
    for (var letter in ['A', 'B', 'C', 'D']) letter: '',
  };
  final Map<RunType, String> runLabels = {
    RunType.qual1: 'Qual 1',
    RunType.qual2: 'Qual 2',
    RunType.final1: 'Final 1',
    RunType.final2: 'Final 2',
  };
  final double _rowHeight = 48;
  final Map<String, GlobalKey> _overlayKeys = {};
  final Map<String, Map<RunType, GlobalKey>> _rowFirstCellKeys = {};
  Rect? _activeRunRowRect;
  String? _activeDrawLetter;
  RunType? _activeDrawRun;
  _Stroke? _activeStroke;
  final PageController _pageController = PageController();

  void _eraseAt(String letter, RunType run, Offset pos) {
    final strokes = drawings[letter]![run]!;
    for (int i = strokes.length - 1; i >= 0; i--) {
      final stroke = strokes[i];
      for (final pt in stroke.points) {
        if ((pt - pos).distance < 16) {
          strokes.removeAt(i);
          setState(() {});
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced layout: full widget tree
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 56,
        title: const Text('Skate Judge', style: TextStyle(color: Color(0xFF222B45), fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1.2)),
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
                _finishActiveStroke(commit: false);
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
              setState(() {
                if (drawingMode) {
                  eraserMode = !eraserMode;
                }
              });
            },
          ),
          IconButton(
            tooltip: 'Undo',
            icon: Icon(Icons.undo, color: Color(0xFF222B45)),
            onPressed: () {
              setState(() {
                final strokes = drawings[letters[_pageController.page?.round() ?? 0]]?[currentRun];
                if (strokes != null && strokes.isNotEmpty) {
                  strokes.removeLast();
                }
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 0))],
            ),
            child: NavigationRail(
              minWidth: 48,
              groupAlignment: 0.0,
              selectedIndex: currentRun.index,
              onDestinationSelected: (idx) {
                setState(() {
                  currentRun = RunType.values[idx];
                  _finishActiveStroke(commit: false);
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.looks_one, color: Color(0xFF222B45)),
                  label: Text('Qual 1', style: TextStyle(fontSize: 14, color: Color(0xFF222B45), fontWeight: FontWeight.w600)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.looks_two, color: Color(0xFF222B45)),
                  label: Text('Qual 2', style: TextStyle(fontSize: 14, color: Color(0xFF222B45), fontWeight: FontWeight.w600)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.filter_1, color: Color(0xFF222B45)),
                  label: Text('Final 1', style: TextStyle(fontSize: 14, color: Color(0xFF222B45), fontWeight: FontWeight.w600)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.filter_2, color: Color(0xFF222B45)),
                  label: Text('Final 2', style: TextStyle(fontSize: 14, color: Color(0xFF222B45), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: PageView.builder(
                itemCount: letters.length,
                physics: drawingMode
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                controller: _pageController,
                itemBuilder: (context, idx) {
                  final letter = letters[idx];
                  _overlayKeys.putIfAbsent(letter, () => GlobalKey());
                  _rowFirstCellKeys.putIfAbsent(
                    letter,
                    () => {
                      for (var run in RunType.values) run: GlobalKey(),
                    },
                  );
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      key: _overlayKeys[letter],
                      fit: StackFit.passthrough,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: const Color(0xFF222B45),
                                      child: Text(
                                        letter,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Contestant Name',
                                          labelStyle: const TextStyle(color: Color(0xFF222B45)),
                                          filled: true,
                                          fillColor: Color(0xFFF7F8FA),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        style: const TextStyle(fontSize: 18, color: Color(0xFF222B45)),
                                        controller: TextEditingController(text: contestantNames[letter]),
                                        onChanged: (val) => setState(() => contestantNames[letter] = val),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Table(
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
                                      ],
                                    ),
                                    for (var run in RunType.values)
                                      TableRow(
                                        children: [
                                          SizedBox(
                                            height: _rowHeight,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Container(
                                                key: _rowFirstCellKeys[letter]![run],
                                                alignment: Alignment.center,
                                                child: Text(
                                                  runLabels[run]!,
                                                  style: const TextStyle(
                                                    color: Color(0xFF222B45),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          for (var cat in categories)
                                            SizedBox(
                                              height: _rowHeight,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                                child: TextField(
                                                  enabled: run == currentRun && !drawingMode,
                                                  keyboardType: TextInputType.number,
                                                  controller: TextEditingController(text: scores[letter]![run]![cat].toString()),
                                                  style: const TextStyle(fontSize: 16, color: Color(0xFF222B45)),
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Color(0xFFF7F8FA),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      scores[letter]![run]![cat] = double.tryParse(val) ?? 0.0;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        if (drawingMode)
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final cellKey = _rowFirstCellKeys[letter]![currentRun];
                                  final ctx = cellKey?.currentContext;
                                  if (ctx != null) {
                                    final box = ctx.findRenderObject() as RenderBox;
                                    final pos = box.localToGlobal(Offset.zero, ancestor: _overlayKeys[letter]!.currentContext?.findRenderObject() as RenderBox?);
                                    _activeRunRowRect = pos & box.size;
                                  }
                                });
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: (details) {
                                    if (_activeRunRowRect != null && _activeRunRowRect!.contains(details.localPosition)) {
                                      _finishActiveStroke(commit: false);
                                      return;
                                    }
                                    if (eraserMode) {
                                      _eraseAt(letter, currentRun, details.localPosition);
                                    } else {
                                      setState(() {
                                        _activeDrawLetter = letter;
                                        _activeDrawRun = currentRun;
                                        _activeStroke = _Stroke(
                                          color: Colors.blue,
                                          width: 2.5,
                                          isErase: false,
                                        );
                                        _activeStroke!.points.add(details.localPosition);
                                      });
                                    }
                                  },
                                  onPanUpdate: (details) {
                                    if (_activeRunRowRect != null && _activeRunRowRect!.contains(details.localPosition)) {
                                      return;
                                    }
                                    if (eraserMode) {
                                      _eraseAt(letter, currentRun, details.localPosition);
                                    } else if (_activeDrawLetter == letter && _activeDrawRun == currentRun) {
                                      setState(() {
                                        _activeStroke?.points.add(details.localPosition);
                                      });
                                    }
                                  },
                                  onPanEnd: (details) {
                                    if (!eraserMode) {
                                      _finishActiveStroke(commit: true);
                                    }
                                    setState(() {});
                                  },
                                  child: CustomPaint(
                                    painter: _NotesPainter(
                                      strokesByRun: drawings[letter]![currentRun]!,
                                      blockRect: _activeRunRowRect,
                                      tempStroke: (_activeDrawLetter == letter && _activeDrawRun == currentRun)
                                          ? _activeStroke
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ...existing methods and logic...

  // Determine which run row (if any) was touched, using the first cell's key to locate each row.
  RunType? _hitTestRun(String letter, Offset localPosInOverlay) {
    final overlayKey = _overlayKeys[letter];
    if (overlayKey?.currentContext == null) return null;

    final overlayBox =
        overlayKey!.currentContext!.findRenderObject() as RenderBox;

    for (final run in RunType.values) {
      final cellKey = _rowFirstCellKeys[letter]![run];
      final ctx = cellKey!.currentContext;
      if (ctx == null) continue;

      final cellBox = ctx.findRenderObject() as RenderBox;
      final cellPos = cellBox.localToGlobal(Offset.zero, ancestor: overlayBox);
      final cellRect = cellPos & cellBox.size;

      if (cellRect.contains(localPosInOverlay)) {
        return run;
      }
    }
    return null;
  }

  void _finishActiveStroke({required bool commit}) {
    if (_activeDrawLetter != null &&
        _activeDrawRun != null &&
        _activeStroke != null &&
        commit) {
      drawings[_activeDrawLetter]![_activeDrawRun!]!.add(_activeStroke!);
    }
    _activeDrawLetter = null;
    _activeDrawRun = null;
    _activeStroke = null;
  }
}

class _Stroke {
  final List<Offset> points = [];
  final Color color;
  final double width;
  final bool isErase;

  _Stroke({
    this.color = Colors.blue,
    this.width = 2.5,
    this.isErase = false,
  });
}

class _NotesPainter extends CustomPainter {
  final List<_Stroke> strokesByRun;
  final Rect? blockRect;
  final _Stroke? tempStroke;

  _NotesPainter({
    required this.strokesByRun,
    required this.blockRect,
    required this.tempStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw saved strokes, but skip segments inside blockRect
    for (final stroke in strokesByRun) {
      final paint = Paint()
        ..color = stroke.isErase ? Colors.white : stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      _drawStroke(canvas, paint, stroke.points);
    }

    // Draw the temporary stroke
    if (tempStroke != null) {
      final paint = Paint()
        ..color = tempStroke!.isErase ? Colors.white : tempStroke!.color
        ..strokeWidth = tempStroke!.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      _drawStroke(canvas, paint, tempStroke!.points);
    }
  }

  void _drawStroke(Canvas canvas, Paint paint, List<Offset> points) {
    if (points.length < 2) return;
    Path path = Path();
    bool started = false;
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      if (blockRect != null && blockRect!.contains(pt)) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotesPainter oldDelegate) {
    return oldDelegate.strokesByRun != strokesByRun ||
        oldDelegate.tempStroke != tempStroke ||
        oldDelegate.blockRect != blockRect;
  }
}