import 'package:flutter/material.dart';
import 'learner_dashboard.dart';
import 'teacher_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'Learner') {
      return const LearnerDashboard();
    } else if (role == 'Teacher') {
      return const TeacherDashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$role Dashboard'),
      ),
      body: Center(
        child: Text(
          'Welcome to the $role dashboard',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}