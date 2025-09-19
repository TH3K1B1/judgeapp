import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContestantNamesPage extends StatefulWidget {
  final Map<String, String> contestantNames;
  final Function(Map<String, String>) onSave;

  const ContestantNamesPage({
    super.key,
    required this.contestantNames,
    required this.onSave,
  });

  @override
  State<ContestantNamesPage> createState() => _ContestantNamesPageState();
}

class _ContestantNamesPageState extends State<ContestantNamesPage> {
  late Map<String, TextEditingController> controllers;
  late List<String> letters;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    letters = widget.contestantNames.keys.toList();
    controllers = {
      for (var letter in letters)
        letter: TextEditingController(text: widget.contestantNames[letter]),
    };
  }

  void addContestant() {
    String newLetter = _nextLetter();
    setState(() {
      letters.add(newLetter);
      controllers[newLetter] = TextEditingController();
    });
  }

  String _nextLetter() {
    // Find next available letter (A-Z)
    for (int i = 0; i < 26; i++) {
      String letter = String.fromCharCode(65 + i);
      if (!letters.contains(letter)) return letter;
    }
    return '?';
  }

  void saveAndPop() {
    final updatedNames = {
      for (var letter in letters)
        letter: controllers[letter]!.text.isNotEmpty
            ? controllers[letter]!.text
            : 'Contestant $letter',
    };
    widget.onSave(updatedNames);
    Navigator.pop(context, updatedNames);
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        saveAndPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Contestant Names'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Contestant',
              onPressed: addContestant,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: letters.map((letter) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: controllers[letter],
                decoration: InputDecoration(
                  labelText: 'Contestant $letter',
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}