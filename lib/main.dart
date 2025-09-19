import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/judge_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const JudgeApp());
}