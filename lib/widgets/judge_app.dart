import 'package:flutter/material.dart';
import 'judge_home_page.dart';
import 'overall_stats_page.dart';

class JudgeApp extends StatelessWidget {
  const JudgeApp({super.key});

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
  // No routes needed; navigation handled in JudgeHomePage
    );
  }

  // ...existing code...
}
