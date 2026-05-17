import 'package:flutter/material.dart';
import 'teacher_dashboard.dart';

class TeacherPinScreen extends StatefulWidget {
  const TeacherPinScreen({super.key});

  @override
  State<TeacherPinScreen> createState() => _TeacherPinScreenState();
}

class _TeacherPinScreenState extends State<TeacherPinScreen> {
  final TextEditingController pinController = TextEditingController();
  String errorMessage = '';

  void checkPin() {
    if (pinController.text.trim() == '2005') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherDashboard(),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Incorrect PIN';
      });
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Enter teacher PIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'PIN',
                  ),
                  onSubmitted: (_) => checkPin(),
                ),
                const SizedBox(height: 12),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: checkPin,
                  child: const Text('Open teacher dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}