import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'student_work_screen.dart';

class ClassOverviewScreen extends StatefulWidget {
  final String className;

  const ClassOverviewScreen({
    super.key,
    required this.className,
  });

  @override
  State<ClassOverviewScreen> createState() =>
      _ClassOverviewScreenState();
}

class _ClassOverviewScreenState
    extends State<ClassOverviewScreen> {
  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/teacher/class/${widget.className}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          students = data['students'];
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : students.isEmpty
              ? const Center(
                  child: Text('No students found'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    return Card(
                      child: ListTile(
                        title: Text(
                          student['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Lessons completed: ${student['lessons_completed']}\n'
                          'Average score: ${student['average_score'] ?? 0}\n'
                          'Last active: ${student['last_active'] ?? 'No activity yet'}',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (_) => StudentWorkScreen(
                                    studentName: student['name'],
                                ),
                                ),
                            );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}