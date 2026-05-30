import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'learner_setup_screen.dart';
import 'teacher_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    saveRole();
  }

  Future<void> saveRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', widget.role);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'Learner') {
      return const LearnerSetupScreen();
    } else if (widget.role == 'Teacher') {
      return const TeacherDashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Dashboard'),
      ),
      body: Center(
        child: Text(
          'Welcome to the ${widget.role} dashboard',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}