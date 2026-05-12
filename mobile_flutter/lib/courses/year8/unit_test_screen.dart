import 'package:flutter/material.dart';

class UnitTestScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const UnitTestScreen({
    super.key,
    required this.data,
  });

  @override
  State<UnitTestScreen> createState() =>
      _UnitTestScreenState();
}

class _UnitTestScreenState extends State<UnitTestScreen> {
  late final Map<String, dynamic> data;

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

  Widget buildVocabularyTest() {
    final questions = data['vocabularyQuestions'] as List;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vocabulary Test',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final totalQuestions = vocabQuestions.length + grammarQuestions.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data['title'] as String,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Unit'),
        ),
      ],
    );
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
            child: getStep(),
          ),
        ),
      ),
    );
  }
}