import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'learner_dashboard.dart';
import 'teacher_dashboard.dart';
import 'teacher_pin_screen.dart';

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
    checkExistingUser();
    fetchClasses();
  }

  Future<void> checkExistingUser() async {
    final prefs = await SharedPreferences.getInstance();

    final teacherLoggedIn = prefs.getBool('teacherLoggedIn') ?? false;

    if (teacherLoggedIn) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherDashboard(),
        ),
      );
      return;
    }

    final savedName = prefs.getString('studentName');
    final savedClass = prefs.getString('studentClass');

    if (savedName != null &&
        savedName.isNotEmpty &&
        savedClass != null &&
        savedClass.isNotEmpty) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LearnerDashboard(
            studentName: savedName,
            studentClass: savedClass,
          ),
        ),
      );
    }
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
      );

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          loadingClasses = false;
        });
        return;
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        classes = List<String>.from(data['classes']);
        loadingClasses = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingClasses = false;
      });
    }
  }

  Future<void> fetchLearners(String className) async {
    setState(() {
      loadingLearners = true;
      learners = [];
      selectedLearner = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/learners/$className'),
      );

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          loadingLearners = false;
        });
        return;
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        learners = List<String>.from(data['learners']);
        loadingLearners = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingLearners = false;
      });
    }
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

    await prefs.remove('teacherLoggedIn');
  }

  Future<void> continueToDashboard() async {
    if (selectedClass == null || selectedLearner == null) {
      return;
    }

    await saveLearnerDetails();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LearnerDashboard(
          studentName: selectedLearner!,
          studentClass: selectedClass!,
        ),
      ),
    );
  }

  Future<void> openTeacherAccess() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherPinScreen(),
      ),
    );

    if (!mounted) return;

    await checkExistingUser();
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

                const SizedBox(height: 60),

                TextButton.icon(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Teacher access'),
                  onPressed: openTeacherAccess,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
