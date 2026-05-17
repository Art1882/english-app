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

  Color getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String getRankLabel(int index) {
    if (index == 0) return '1st';
    if (index == 1) return '2nd';
    if (index == 2) return '3rd';
    return '${index + 1}th';
  }

  int getStudentScore(dynamic student) {
    return (student['average_percentage'] ??
            student['average_score'] ??
            0)
        .round();
  }

  int getClassAverage() {
    if (students.isEmpty) return 0;

    final total = students.fold<int>(
      0,
      (sum, student) => sum + getStudentScore(student),
    );

    return (total / students.length).round();
  }

  Widget _analyticsCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int classAverage = getClassAverage();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('${widget.className} Leaderboard'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : students.isEmpty
              ? const Center(
                  child: Text(
                    'No students found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Class analytics',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'View class progress, rankings, and average scores.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: _analyticsCard(
                                  title: 'Students',
                                  value: students.length.toString(),
                                  icon: Icons.people,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _analyticsCard(
                                  title: 'Class average',
                                  value: '$classAverage%',
                                  icon: Icons.trending_up,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          ...List.generate(students.length, (index) {
                            final student = students[index];
                            final int score =
                                getStudentScore(student);
                            final Color scoreColor =
                                getScoreColor(score);

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 18),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(22),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentWorkScreen(
                                        studentName:
                                            student['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05),
                                        blurRadius: 10,
                                        offset:
                                            const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: scoreColor
                                            .withOpacity(0.15),
                                        child: Text(
                                          getRankLabel(index),
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            color: scoreColor,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 18),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  student['name'],
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                Text(
                                                  '$score%',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                    color:
                                                        scoreColor,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(
                                                height: 10),

                                            LinearProgressIndicator(
                                              value: score / 100,
                                              minHeight: 8,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(20),
                                            ),

                                            const SizedBox(
                                                height: 10),

                                            Text(
                                              'Lessons completed: ${student['lessons_completed'] ?? 0}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors
                                                    .grey.shade700,
                                              ),
                                            ),

                                            const SizedBox(
                                                height: 4),

                                            Text(
                                              'Last active: ${student['last_active'] ?? 'No activity yet'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors
                                                    .grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Icon(
                                        Icons
                                            .arrow_forward_ios_rounded,
                                        color:
                                            Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}