import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

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
      home: const RoleSelectionScreen(),
    );
  }
}

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

class DashboardScreen extends StatelessWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'Learner') {
      return const LearnerScreen();
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

class LearnerScreen extends StatefulWidget {
  const LearnerScreen({super.key});

  @override
  State<LearnerScreen> createState() => _LearnerScreenState();
}

class _LearnerScreenState extends State<LearnerScreen> {
  final TextEditingController sentenceController = TextEditingController();
  String feedback = '';

Future<void> submitSentence() async {
  final sentence = sentenceController.text.trim();

  if (sentence.isEmpty) {
    setState(() {
      feedback = 'Please write a sentence first.';
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sentence': sentence}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        feedback = data['feedback'];
      });
    } else {
      setState(() {
        feedback = 'Server error.';
      });
    }
  } catch (e) {
    setState(() {
      feedback = 'Cannot connect to backend.';
    });
  }
}

  @override
  void dispose() {
    sentenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Write one English sentence',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: sentenceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Your sentence',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitSentence,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 30),
                Text(
                  feedback,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}