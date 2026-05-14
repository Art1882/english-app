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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
      ),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : submissions.isEmpty
        ? const Center(child: Text('No work found'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final item = submissions[index];
            final answer = item['answer'];

            final totalScore =
                (answer is Map)
                    ? (answer['inputScore'] ?? 0) +
                        (answer['vocabularyScore'] ?? 0) +
                        (answer['grammarScore'] ?? 0) +
                        (answer['comprehensionScore'] ?? 0)
                    : 0;

            return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['lesson'] ?? 'Unknown lesson',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item['timestamp'] ?? 'No timestamp',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (answer is Map) ...[
                    Text(
                      'Total Score: $totalScore',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text('Input: ${answer['inputScore'] ?? 0}'),
                    Text('Vocabulary: ${answer['vocabularyScore'] ?? 0}'),
                    Text('Grammar: ${answer['grammarScore'] ?? 0}'),
                    Text('Comprehension: ${answer['comprehensionScore'] ?? 0} / 10'),
                  ] else ...[
                    Text('Answer: ${answer ?? ''}'),
                  ],

                  const SizedBox(height: 8),

                  Text(
                    item['feedback'] ?? '',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  ],
                  ),
                ),
              );
            },
          ),
      );
    }
}