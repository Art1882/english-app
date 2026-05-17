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

  int getPercentage(Map answer) {
    final score = getScore(answer);
    final possible = getPossibleScore(answer);

    if (possible == 0) return 0;

    return ((score / possible) * 100).round();
  }

  int getAveragePercentage() {
    final scoredSubmissions =
        submissions.where((item) => item['answer'] is Map).toList();

    if (scoredSubmissions.isEmpty) return 0;

    final total = scoredSubmissions.fold<int>(
      0,
      (sum, item) => sum + getPercentage(item['answer']),
    );

    return (total / scoredSubmissions.length).round();
  }

  Color getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _summaryCard({
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

  Widget _scoreRow(String label, dynamic score, String possible) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$score / $possible',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

 Widget _responseBox(Map responses) {
  Widget answerSection({
    required String title,
    required Map answers,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...answers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      entry.value.toString(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map getMap(String key) {
    final value = responses[key];
    if (value is Map) return value;
    return {};
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (getMap('inputAnswers').isNotEmpty)
        answerSection(
          title: 'Input answers',
          answers: getMap('inputAnswers'),
        ),

      if (getMap('vocabularyAnswers').isNotEmpty)
        answerSection(
          title: 'Vocabulary answers',
          answers: getMap('vocabularyAnswers'),
        ),

      if (getMap('grammarAnswers').isNotEmpty)
        answerSection(
          title: 'Grammar answers',
          answers: getMap('grammarAnswers'),
        ),

      if (getMap('comprehensionAnswers').isNotEmpty)
        answerSection(
          title: 'Comprehension answers',
          answers: getMap('comprehensionAnswers'),
        ),

      if (getMap('shortAnswers').isNotEmpty)
        answerSection(
          title: 'Short answers',
          answers: getMap('shortAnswers'),
        ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    final averagePercentage = getAveragePercentage();

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
                            'Review saved lesson scores, progress, and learner responses.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: _summaryCard(
                                  title: 'Lessons saved',
                                  value: submissions.length.toString(),
                                  icon: Icons.menu_book_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _summaryCard(
                                  title: 'Average score',
                                  value: '$averagePercentage%',
                                  icon: Icons.trending_up,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            'Lesson breakdown',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          ...submissions.map((item) {
                            final answer = item['answer'];
                            final responses = item['responses'];

                            int score = 0;
                            int possible = 0;
                            int percentage = 0;

                            if (answer is Map) {
                              score = getScore(answer);
                              possible = getPossibleScore(answer);
                              percentage = getPercentage(answer);
                            }

                            final scoreColor = getScoreColor(percentage);

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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['lesson'] ?? 'Unknown lesson',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (answer is Map)
                                        Text(
                                          '$percentage%',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: scoreColor,
                                          ),
                                        ),
                                    ],
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
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      minHeight: 9,
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    const SizedBox(height: 14),

                                    _scoreRow(
                                      'Total',
                                      score,
                                      possible.toString(),
                                    ),

                                    if (answer.containsKey('inputScore'))
                                      _scoreRow(
                                        'Input',
                                        answer['inputScore'] ?? 0,
                                        '3',
                                      ),

                                    if (answer.containsKey('vocabularyScore'))
                                      _scoreRow(
                                        'Vocabulary',
                                        answer['vocabularyScore'] ?? 0,
                                        '8',
                                      ),

                                    if (answer.containsKey('grammarScore'))
                                      _scoreRow(
                                        'Grammar',
                                        answer['grammarScore'] ?? 0,
                                        '5',
                                      ),

                                    if (answer.containsKey('comprehensionScore'))
                                      _scoreRow(
                                        'Comprehension',
                                        answer['comprehensionScore'] ?? 0,
                                        '10',
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

                                    _responseBox(responses),
                                  ],

                                  if ((item['feedback'] ?? '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Text(
                                      item['feedback'],
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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

