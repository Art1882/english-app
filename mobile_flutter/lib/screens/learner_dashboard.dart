import 'package:flutter/material.dart';
import 'unit_one_lesson_screen.dart';

class LearnerDashboard extends StatelessWidget {
  const LearnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Dashboard'),
      ),
      body: const Center(
        child: const Text('Unit 1: How People Communicate'),
      ),
    );
  }
}