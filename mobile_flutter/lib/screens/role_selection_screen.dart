import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  void initState() {
    super.initState();
    checkSavedRole();
  }

  Future<void> checkSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('userRole');

    if (savedRole == null) return;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(role: savedRole),
      ),
    );
  }

  Future<void> openDashboard(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'English Learning App',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => openDashboard(context, 'Admin'),
                child: const Text('Admin'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => openDashboard(context, 'Teacher'),
                child: const Text('Teacher'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => openDashboard(context, 'Learner'),
                child: const Text('Learner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}