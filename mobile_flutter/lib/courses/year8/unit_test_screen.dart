import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class UnitTestScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const UnitTestScreen({
    super.key,
    required this.data,
  });

  @override
  State<UnitTestScreen> createState() => _UnitTestScreenState();
}

class _UnitTestScreenState extends State<UnitTestScreen> {
  late final Map<String, dynamic> data;
  
  final ScrollController scrollController = ScrollController();

  int step = 0;

  Map<int, String> vocabularyAnswers = {};
  Map<int, String> grammarAnswers = {};

  bool vocabularySubmitted = false;
  bool grammarSubmitted = false;

  int vocabularyScore = 0;
  int grammarScore = 0;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  void nextStep() {
    setState(() {
      step++;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
  }

  void submitVocabularyAnswers() {
    final questions = data['vocabularyQuestions'] as List;

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final correctAnswer =
          (questions[i]['answer'] as String).trim().toLowerCase();

      final learnerAnswer =
          (vocabularyAnswers[i] ?? '').trim().toLowerCase();

      if (learnerAnswer == correctAnswer) {
        score++;
      }
    }

    setState(() {
      vocabularyScore = score;
      vocabularySubmitted = true;
    });
  }

  void submitGrammarAnswers() {
    final questions = data['grammarQuestions'] as List;

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final correctAnswer =
          (questions[i]['answer'] as String).trim().toLowerCase();

      final learnerAnswer =
          (grammarAnswers[i] ?? '').trim().toLowerCase();

      if (learnerAnswer == correctAnswer) {
        score++;
      }
    }

    setState(() {
      grammarScore = score;
      grammarSubmitted = true;
    });
  }

  Widget getStep() {
    switch (step) {
      case 0:
        return buildVocabularyTest();
      case 1:
        return buildGrammarTest();
      default:
        return buildResultsScreen();
    }
  }

  Future<void> saveTestComplete() async {
    final prefs = await SharedPreferences.getInstance();

    final testId = data['testId'] as String;
    await prefs.setBool('${testId}_complete', true);
  }

  Future<void> saveTeacherTestSubmission() async {
    final prefs = await SharedPreferences.getInstance();

    final studentName =
        prefs.getString('studentName') ?? 'Beta Student';

    final studentClass =
        prefs.getString('studentClass') ?? '8EAL';

    await http.post(
      Uri.parse('$baseUrl/submit-activity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "student": studentName,
        "class": studentClass,
        "lesson": data['title'] ?? 'Unit Test',
        "activity": "Unit review test completed",
        "answer": {
          "vocabularyScore": vocabularyScore,
          "grammarScore": grammarScore,
          "totalScore": vocabularyScore + grammarScore,
        },
        "responses": {
          "vocabularyAnswers": vocabularyAnswers.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
          "grammarAnswers": grammarAnswers.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        },
      }),
    );
  }

  Widget buildVocabularyTest() {
    final questions = data['vocabularyQuestions'] as List;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vocabulary Test',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          if (data['imagePath'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                data['imagePath'] as String,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
          ],

          ...List.generate(questions.length, (index) {
            final question = questions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${question['sentence']}',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      enabled: !vocabularySubmitted,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write your answer',
                      ),
                      onChanged: (value) {
                        vocabularyAnswers[index] = value;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          if (!vocabularySubmitted) ...[
            ElevatedButton(
              onPressed: submitVocabularyAnswers,
              child: const Text('Submit vocabulary answers'),
            ),
          ] else ...[
            Text(
              'You got $vocabularyScore / ${questions.length} vocabulary questions correct.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: nextStep,
              child: const Text('Continue to grammar test'),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildGrammarTest() {
    final questions = data['grammarQuestions'] as List;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grammar Test',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          if (data['imagePath'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                data['imagePath'] as String,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
          ],

          ...List.generate(questions.length, (index) {
            final question = questions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${question['sentence']}',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      enabled: !grammarSubmitted,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write your answer',
                      ),
                      onChanged: (value) {
                        grammarAnswers[index] = value;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          if (!grammarSubmitted) ...[
            ElevatedButton(
              onPressed: submitGrammarAnswers,
              child: const Text('Submit grammar answers'),
            ),
          ] else ...[
            Text(
              'You got $grammarScore / ${questions.length} grammar questions correct.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: nextStep,
              child: const Text('See results'),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildResultsScreen() {
    final vocabQuestions = data['vocabularyQuestions'] as List;
    final grammarQuestions = data['grammarQuestions'] as List;

    final totalScore = vocabularyScore + grammarScore;
    final totalQuestions =
        vocabQuestions.length + grammarQuestions.length;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data['title'] as String,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          if (data['imagePath'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                data['imagePath'] as String,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'Vocabulary: $vocabularyScore / ${vocabQuestions.length}',
            style: const TextStyle(fontSize: 18),
          ),

          Text(
            'Grammar: $grammarScore / ${grammarQuestions.length}',
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 16),

          Text(
            'Total: $totalScore / $totalQuestions',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              await saveTestComplete();

              try {
                await saveTeacherTestSubmission();
              } catch (e) {
                print('Teacher test submission failed: $e');
              }

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Back to Unit'),
          ),
        ],
      ),
    );
  }
@override
void dispose() {
  scrollController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final title = data['title'] as String? ?? 'Unit Test';

  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 540,
          child: SingleChildScrollView(
            controller: scrollController,
            child: getStep(),
          ),
        ),
      ),
    ),
  );
}
}