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
    loadSavedTestProgress();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final imagePath = data['imagePath'] as String?;

    if (imagePath != null) {
      precacheImage(
        AssetImage(imagePath),
        context,
      );
    }
  }
  String getTestId() {
    return data['testId'] as String? ??
        data['lessonId'] as String? ??
        'unit_test';
  }

  Map<int, String> decodeAnswerMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return decoded.map(
      (key, value) => MapEntry(int.parse(key), value.toString()),
    );
  }

  String encodeAnswerMap(Map<int, String> answers) {
    return jsonEncode(
      answers.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<void> loadSavedTestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final testId = getTestId();

    final savedStep = prefs.getInt('${testId}_current_step');

    if (savedStep == null || !mounted) {
      return;
    }

    setState(() {
      step = savedStep;

      vocabularyAnswers = decodeAnswerMap(
        prefs.getString('${testId}_vocabulary_answers'),
      );

      grammarAnswers = decodeAnswerMap(
        prefs.getString('${testId}_grammar_answers'),
      );

      vocabularySubmitted =
          prefs.getBool('${testId}_vocabulary_submitted') ?? false;
      grammarSubmitted = prefs.getBool('${testId}_grammar_submitted') ?? false;

      vocabularyScore = prefs.getInt('${testId}_vocabulary_score') ?? 0;
      grammarScore = prefs.getInt('${testId}_grammar_score') ?? 0;
    });
  }

  Future<void> saveTestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final testId = getTestId();

    await prefs.setInt('${testId}_current_step', step);
    await prefs.setString(
      '${testId}_vocabulary_answers',
      encodeAnswerMap(vocabularyAnswers),
    );
    await prefs.setString(
      '${testId}_grammar_answers',
      encodeAnswerMap(grammarAnswers),
    );
    await prefs.setBool('${testId}_vocabulary_submitted', vocabularySubmitted);
    await prefs.setBool('${testId}_grammar_submitted', grammarSubmitted);
    await prefs.setInt('${testId}_vocabulary_score', vocabularyScore);
    await prefs.setInt('${testId}_grammar_score', grammarScore);
  }

  Future<void> clearSavedTestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final testId = getTestId();

    await prefs.remove('${testId}_current_step');
    await prefs.remove('${testId}_vocabulary_answers');
    await prefs.remove('${testId}_grammar_answers');
    await prefs.remove('${testId}_vocabulary_submitted');
    await prefs.remove('${testId}_grammar_submitted');
    await prefs.remove('${testId}_vocabulary_score');
    await prefs.remove('${testId}_grammar_score');
  }

  Future<void> nextStep() async {
    setState(() {
      step++;
    });

    await saveTestProgress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
  }

String normaliseAnswer(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll('‘', "'")
      .replaceAll('`', "'")
      .replaceAll("can't", 'cannot')
      .replaceAll("won't", 'will not')
      .replaceAll("n't", ' not')
      .replaceAll("'re", ' are')
      .replaceAll("'m", ' am')
      .replaceAll("'s", ' is')
      .replaceAll("'ve", ' have')
      .replaceAll("'ll", ' will')
      .replaceAll("'d", ' would')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

  bool allVocabularyQuestionsAnswered() {
    final questions = data['vocabularyQuestions'] as List;

    return vocabularyAnswers.length == questions.length;
  }

  bool allGrammarQuestionsAnswered() {
    final questions = data['grammarQuestions'] as List;

    for (int i = 0; i < questions.length; i++) {
      if ((grammarAnswers[i] ?? '').trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  void showMissingAnswersMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please answer all questions before submitting.'),
      ),
    );
  }

  void submitVocabularyAnswers() {
    if (!allVocabularyQuestionsAnswered()) {
      showMissingAnswersMessage();
      return;
    }

    final questions = data['vocabularyQuestions'] as List;

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final correctAnswer =
          normaliseAnswer(questions[i]['answer'] as String);

      final learnerAnswer =
          normaliseAnswer(vocabularyAnswers[i] ?? '');

      if (learnerAnswer == correctAnswer) {
        score++;
      }
    }

    setState(() {
      vocabularyScore = score;
      vocabularySubmitted = true;
    });

    saveTestProgress();
  }

  void submitGrammarAnswers() {
    if (!allGrammarQuestionsAnswered()) {
      showMissingAnswersMessage();
      return;
    }

    final questions = data['grammarQuestions'] as List;

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final correctAnswer =
          normaliseAnswer(questions[i]['answer'] as String);

      final learnerAnswer =
          normaliseAnswer(grammarAnswers[i] ?? '');

      if (learnerAnswer == correctAnswer) {
        score++;
      }
    }

    setState(() {
      grammarScore = score;
      grammarSubmitted = true;
    });

    saveTestProgress();
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

  InputDecoration buildAnswerInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.purple.shade100,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.purple,
          width: 2,
        ),
      ),
    );
  }

  Future<void> saveTestComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final testId = getTestId();

    await prefs.setBool('${testId}_complete', true);
    await clearSavedTestProgress();
  }

  Future<void> saveTeacherTestSubmission() async {
    final prefs = await SharedPreferences.getInstance();

    final studentName =
        prefs.getString('studentName') ?? 'Beta Student';

    final studentClass =
        prefs.getString('studentClass') ?? '8EAL';

    final unitTitle = data['unitTitle'] as String? ?? 'Unit';
    final testTitle = data['title'] as String? ?? 'Unit Test';

    await http.post(
      Uri.parse('$baseUrl/submit-activity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "student": studentName,
        "class": studentClass,
        "lesson": '$unitTitle - $testTitle',
        "activity": "Unit review test completed",
        "answer": {
          "vocabularyScore": vocabularyScore,
          "vocabularyTotal": data['vocabularyQuestions'].length,

          "grammarScore": grammarScore,
          "grammarTotal": data['grammarQuestions'].length,

          "totalScore": vocabularyScore + grammarScore,
          "totalPossible":
              data['vocabularyQuestions'].length + data['grammarQuestions'].length,
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

  Widget buildTestSectionHeader({
    required int stepNumber,
    required int totalSteps,
    required String title,
  }) {
    final double progressValue = stepNumber / totalSteps;

    return Card(
      color: Colors.purple.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $stepNumber of $totalSteps',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVocabularyTest() {
    final questions = data['vocabularyQuestions'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTestSectionHeader(
          stepNumber: 1,
          totalSteps: 2,
          title: 'Vocabulary Test',
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

        const Text(
          'Choose the best word to complete each sentence.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        ...List.generate(questions.length, (index) {
          final question = questions[index];
          final options = question['options'] as List;

          final isCorrect =
              vocabularyAnswers[index] == question['answer'];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question['sentence']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...options.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: vocabularyAnswers[index],
                      onChanged: vocabularySubmitted
                          ? null
                          : (value) {
                              setState(() {
                                vocabularyAnswers[index] = value ?? '';
                              });
                              saveTestProgress();
                            },
                    );
                  }),

                  if (vocabularySubmitted)
                    Text(
                      isCorrect
                          ? 'Correct'
                          : 'Incorrect. Correct answer: ${question['answer']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        if (!vocabularySubmitted) ...[
          Center(
          child: ElevatedButton(
            onPressed: submitVocabularyAnswers,
            child: const Text('Submit vocabulary answers'),
          ),
        ),

        const SizedBox(height: 40),
        ] else ...[
          Text(
            'You got $vocabularyScore / ${questions.length} vocabulary questions correct.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Center(
          child: ElevatedButton(
            onPressed: nextStep,
            child: const Text('Continue to grammar test'),
          ),
        ),

        const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget buildGrammarTest() {
    final questions = data['grammarQuestions'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTestSectionHeader(
          stepNumber: 2,
          totalSteps: 2,
          title: 'Grammar Test',
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

          final isCorrect = normaliseAnswer(
                grammarAnswers[index] ?? '',
              ) ==
              normaliseAnswer(question['answer'].toString());

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question['instruction']}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    question['sentence'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),

                  if (question.containsKey('question')) ...[
                    const SizedBox(height: 10),

                    Text(
                      question['question'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: grammarAnswers[index] ?? '',
                    enabled: !grammarSubmitted,
                    decoration:
                        buildAnswerInputDecoration('Missing word(s) only'),
                    onChanged: (value) {
                      grammarAnswers[index] = value;
                      saveTestProgress();
                    },
                  ),

                  if (grammarSubmitted) ...[
                    const SizedBox(height: 12),

                    Text(
                      isCorrect
                          ? 'Correct'
                          : 'Incorrect. Correct answer: ${question['answer']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        if (!grammarSubmitted) ...[
          Center(
          child: ElevatedButton(
            onPressed: submitGrammarAnswers,
            child: const Text('Submit grammar answers'),
          ),
        ),

        const SizedBox(height: 40),
        ] else ...[
          Text(
            'You got $grammarScore / ${questions.length} grammar questions correct.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Center(
          child: ElevatedButton(
            onPressed: nextStep,
            child: const Text('See results'),
          ),
        ),

        const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget buildResultsScreen() {
    final vocabQuestions = data['vocabularyQuestions'] as List;
    final grammarQuestions = data['grammarQuestions'] as List;

    final totalScore = vocabularyScore + grammarScore;
    final totalQuestions =
        vocabQuestions.length + grammarQuestions.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data['title'] as String? ?? 'Unit Test',
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

        Center(
          child: ElevatedButton(
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
          child: Text(
            data['backButtonText'] as String? ?? 'Back to Unit',
          ),
        ),
        ),

        const SizedBox(height: 40),
      ],
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
