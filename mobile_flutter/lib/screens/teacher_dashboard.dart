import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List submissions = [];
  bool loading = true;
  String teacherClass = '';

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    try {
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