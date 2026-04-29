import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

// App starts here
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

// This screen lets user choose Admin / Teacher / Learner
class RoleSelectionScreen extends StatelessWidget {
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

// This function moves to the next screen based on role
void openDashboard(BuildContext context, String role) {
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

// Decides which screen to show based on role
  @override
  Widget build(BuildContext context) {
    if (role == 'Learner') {
      return const LearnerScreen();
    } else if (role == 'Teacher') {
      return const TeacherScreen();
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
// Learner Screen
class LearnerScreen extends StatefulWidget {
  const LearnerScreen({super.key});

  @override
  State<LearnerScreen> createState() => _LearnerScreenState();
}

// Controllers store what user types in inputs
class _LearnerScreenState extends State<LearnerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  String feedback = '';

// Sends data to backend
  Future<void> submitSentence() async {
    final student = nameController.text.trim();
    final sentence = sentenceController.text.trim();

    if (student.isEmpty) {
      setState(() {
        feedback = 'Please write your name first.';
      });
      return;
    }

    if (sentence.isEmpty) {
      setState(() {
        feedback = 'Please write a sentence first.';
      });
      return;
    }

// This is your API call (frontend → backend)
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check'),
        headers: {'Content-Type': 'application/json'},
// This is the DATA you send
        body: jsonEncode({
          'student': student,
          'class': classController.text.trim(),
          'sentence': sentence,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
// Shows response from backend
          feedback = data['feedback'];
          sentenceController.clear();
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
    nameController.dispose();
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
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Your name',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Class',
                  ),
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

// Teacher Screen
class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  List submissions = []; // stores all data from backend
  bool loading = true; // shows loading spinner
  String selectedClass = '';
  String teacherClass = ''; // the class teacher wants to view

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

// Fetch data from backend
  Future<void> fetchSubmissions() async {
    try {
// GET request (read data)
      final response = await http.get(
        Uri.parse('$baseUrl/submissions'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          submissions = data['submissions'];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
// Filter data based on teacher's class
    final filtered = teacherClass.isEmpty
      ? []
      : submissions.where((s) => s['class'] == teacherClass).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter your class (e.g. 10A)',
                      border: OutlineInputBorder(),
                    ),
// Teacher types class → updates filter
                    onChanged: (value) {
                      setState(() {
                        teacherClass = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No submissions yet'))
// Display list of submissions
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item['class']} - ${item['student']}: ${item['sentence']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['feedback'],
                                      style: const TextStyle(
                                          color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}