import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'learner_dashboard.dart';

class LearnerSetupScreen extends StatefulWidget {
  const LearnerSetupScreen({super.key});

  @override
  State<LearnerSetupScreen> createState() =>
      _LearnerSetupScreenState();
}

class _LearnerSetupScreenState
    extends State<LearnerSetupScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController classController =
      TextEditingController();

  Future<void> saveLearnerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'studentName',
      nameController.text.trim(),
    );

    await prefs.setString(
      'studentClass',
      classController.text.trim(),
    );
  }

  void continueToDashboard() async {
    if (nameController.text.trim().isEmpty ||
        classController.text.trim().isEmpty) {
      return;
    }

    await saveLearnerDetails();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LearnerDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Setup'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your details',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: 'Your class',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 50),
                  ),
                  onPressed: continueToDashboard,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}