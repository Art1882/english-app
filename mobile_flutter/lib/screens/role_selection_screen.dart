import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void openDashboard(BuildContext context, String role) {
    Navigator.push(
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