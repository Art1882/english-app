import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class StudentWorkScreen extends StatefulWidget {
  final String studentName;

  const StudentWorkScreen({
    super.key,
    required this.studentName,
  });

  @override
  State<StudentWorkScreen> createState() => _StudentWorkScreenState();
}

class _StudentWorkScreenState extends State<StudentWorkScreen> {
  List submissions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentWork();
  }

  Future<void> fetchStudentWork() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/student/${widget.studentName}'),
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

  int getScore(Map answer) {
    if (answer.containsKey('totalScore')) {
      return answer['totalScore'] ?? 0;
    }

    return (answer['inputScore'] ?? 0) +
        (answer['vocabularyScore'] ?? 0) +
        (answer['grammarScore'] ?? 0) +
        (answer['comprehensionScore'] ?? 0);
  }

  int getPossibleScore(Map answer) {
    if (answer.containsKey('totalScore')) {
      return 20;
    }

    return 26;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(widget.studentName),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(
                  child: Text(
                    'No work found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.studentName} work',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Review saved lesson scores and learner responses.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 30),

                          ...submissions.map((item) {
                            final answer = item['answer'];
                            final responses = item['responses'];

                            int score = 0;
                            int possible = 0;
                            int percentage = 0;

                            if (answer is Map) {
                              score = getScore(answer);
                              possible = getPossibleScore(answer);
                              percentage = possible > 0
                                  ? ((score / possible) * 100).round()
                                  : 0;
                            }

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['lesson'] ?? 'Unknown lesson',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    item['timestamp'] ?? 'No timestamp',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  if (answer is Map) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Score',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$percentage%',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    const SizedBox(height: 14),

                                    Text('Total: $score / $possible'),

                                    if (answer.containsKey('inputScore'))
                                      Text('Input: ${answer['inputScore'] ?? 0} / 3'),

                                    if (answer.containsKey('vocabularyScore'))
                                      Text('Vocabulary: ${answer['vocabularyScore'] ?? 0}'),

                                    if (answer.containsKey('grammarScore'))
                                      Text('Grammar: ${answer['grammarScore'] ?? 0}'),

                                    if (answer.containsKey('comprehensionScore'))
                                      Text(
                                        'Comprehension: ${answer['comprehensionScore'] ?? 0} / 10',
                                      ),
                                  ] else ...[
                                    Text('Answer: ${answer ?? ''}'),
                                  ],

                                  if (responses is Map) ...[
                                    const SizedBox(height: 18),

                                    const Text(
                                      'Learner responses',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    SelectableText(
                                      const JsonEncoder.withIndent('  ')
                                          .convert(responses),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 12),

                                  Text(
                                    item['feedback'] ?? '',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
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