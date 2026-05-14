import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';
import 'screens/learner_setup_screen.dart';

void main() {
  runApp(const EnglishApp());
}

class EnglishApp extends StatelessWidget {
  const EnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LearnerSetupScreen(),
    );
  }
}