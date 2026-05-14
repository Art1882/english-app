import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import 'learner_dashboard.dart';

class LearnerSetupScreen extends StatefulWidget {
  const LearnerSetupScreen({super.key});

  @override
  State<LearnerSetupScreen> createState() => _LearnerSetupScreenState();
}

class _LearnerSetupScreenState extends State<LearnerSetupScreen> {
  List<String> classes = [];
  String? selectedClass;
  bool loadingClasses = true;

  List<String> learners = [];
  String? selectedLearner;
  bool loadingLearners = false;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes'),
    );

    final data = jsonDecode(response.body);

    setState(() {
      classes = List<String>.from(data['classes']);
      loadingClasses = false;
    });
  }

  Future<void> fetchLearners(String className) async {
    setState(() {
      loadingLearners = true;
      learners = [];
      selectedLearner = null;
    });

    final response = await http.get(
      Uri.parse('$baseUrl/learners/$className'),
    );

    final data = jsonDecode(response.body);

    setState(() {
      learners = List<String>.from(data['learners']);
      loadingLearners = false;
    });
  }

  Future<void> saveLearnerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'studentName',
      selectedLearner ?? '',
    );

    await prefs.setString(
      'studentClass',
      selectedClass ?? '',
    );
  }

  void continueToDashboard() async {
    if (selectedClass == null || selectedLearner == null) {
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

                loadingClasses
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: const InputDecoration(
                          labelText: 'Select your class',
                          border: OutlineInputBorder(),
                        ),
                        items: classes.map((className) {
                          return DropdownMenuItem<String>(
                            value: className,
                            child: Text(className),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });

                          if (value != null) {
                            fetchLearners(value);
                          }
                        },
                      ),

                const SizedBox(height: 20),

                loadingLearners
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: selectedLearner,
                        decoration: const InputDecoration(
                          labelText: 'Select your name',
                          border: OutlineInputBorder(),
                        ),
                        items: learners.map((learnerName) {
                          return DropdownMenuItem<String>(
                            value: learnerName,
                            child: Text(learnerName),
                          );
                        }).toList(),
                        onChanged: learners.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  selectedLearner = value;
                                });
                              },
                      ),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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