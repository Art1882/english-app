import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

import '../../../screens/writing_template_screen.dart';
import '../../../screens/subscription_screen.dart';

class InputLessonScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const InputLessonScreen({
    super.key,
    required this.data,
  });

  @override
  State<InputLessonScreen> createState() => _InputLessonScreenState();
}

class _InputLessonScreenState extends State<InputLessonScreen> {
  late final Map<String, dynamic> data;

  int step = 0;
  String? selectedAnswer;
  String feedback = '';

  final ScrollController scrollController = ScrollController();

  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  Map<int, String> inputAnswers = {};
  bool inputSubmitted = false;
  int inputScore = 0;

  Map<int, String> vocabularyAnswers = {};
  bool vocabularySubmitted = false;
  int vocabularyScore = 0;

  Map<int, String> grammarAnswers = {};
  bool grammarSubmitted = false;
  int grammarScore = 0;

  Map<int, String?> comprehensionAnswers = {};
  bool comprehensionSubmitted = false;
  int comprehensionScore = 0;

  Map<int, String> shortAnswers = {};
  bool shortAnswersSubmitted = false;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

void nextStep() {
  setState(() {
    step++;
    selectedAnswer = null;
    feedback = '';
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  });
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
        color: Colors.blue.shade100,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Colors.blue,
        width: 2,
      ),
    ),
  );
}

Future<void> toggleAudio() async {
  final audioPath = data['audioPath'] as String;

  if (isPlaying) {
    await audioPlayer.pause();
  } else {
    await audioPlayer.play(AssetSource(audioPath));
  }

  setState(() {
    isPlaying = !isPlaying;
  });
}
  void submitInputAnswers() {
    final questions = data['inputQuestions'] as List;

    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];

      if (inputAnswers[i] == question['answer']) {
        score++;
      }
    }

    setState(() {
      inputScore = score;
      inputSubmitted = true;
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
  final grammar = data['grammar'] as Map;
  final practice = grammar['practice'] as List;

  int score = 0;

  for (int i = 0; i < practice.length; i++) {
    final correctAnswer =
        (practice[i]['answer'] as String).trim().toLowerCase();

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

void submitComprehensionAnswers() {
  final mcQuestions = data['comprehension'] as List;
  final shortQuestions =
      data['shortAnswerQuestions'] as List? ?? [];

  int score = 0;

  // Multiple choice
  for (int i = 0; i < mcQuestions.length; i++) {
    if (comprehensionAnswers[i] ==
        mcQuestions[i]['answer']) {
      score++;
    }
  }

  // Short answers
  for (int i = 0; i < shortQuestions.length; i++) {
    final correctAnswer =
        (shortQuestions[i]['answer'] as String)
            .trim()
            .toLowerCase();

    final learnerAnswer =
        (shortAnswers[i] ?? '')
            .trim()
            .toLowerCase();

    if (learnerAnswer == correctAnswer) {
      score++;
    }
  }

  setState(() {
    comprehensionScore = score;
    comprehensionSubmitted = true;
    shortAnswersSubmitted = true;
  });
}

  void handleWritingAccess(BuildContext context) {
    bool isSubscribed = false; // temporary

    if (isSubscribed) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WritingTemplateScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SubscriptionScreen(),
        ),
      );
    }
  }

  //Beta save
  Future<void> saveLessonComplete() async {
  final prefs = await SharedPreferences.getInstance();

  final lessonId = data['lessonId'] as String;
  await prefs.setBool('${lessonId}_complete', true);
}

Future<void> saveTeacherSubmission() async {
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
      "lesson": data['appBarTitle'] ?? 'Unknown lesson',
      "activity": "Lesson completed",

      "answer": {
        "inputScore": inputScore,
        "vocabularyScore": vocabularyScore,
        "grammarScore": grammarScore,
        "comprehensionScore": comprehensionScore,
      },

      "responses": {
        "inputAnswers": inputAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        "vocabularyAnswers": vocabularyAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        "grammarAnswers": grammarAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        "comprehensionAnswers": comprehensionAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        "shortAnswers": shortAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      },
    }),
  );
}

 Widget getStep() {
  switch (step) {
    case 0:
      return buildInputStep();
    case 1:
      return buildVocabularyStep();
    case 2:
      return buildGrammarStep(); 
    case 3:
      return buildComprehensionStep();
    default:
      return buildCompleteStep();
  }
}

Widget buildLessonSectionHeader({
  required int stepNumber,
  required int totalSteps,
  required String title,
}) {
  final double progressValue = stepNumber / totalSteps;

  return Card(
    color: Colors.blue.shade50,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step $stepNumber of $totalSteps',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

Widget buildInputStep() {
  final inputType = data['inputType'] as String;
  final questions = data['inputQuestions'] as List;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      buildLessonSectionHeader(
      stepNumber: 1,
      totalSteps: 4,
      title: inputType == 'reading' ? 'Read' : 'Listen',
    ),
      Text(
        inputType == 'reading' ? 'Read' : 'Listen',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        const SizedBox(height: 20),
      ],

      if (inputType == 'reading')
        Text(
          data['input'] as String,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 17,
            height: 1.6,
          ),
        )
      else
        Column(
          children: [
            const Text(
              'Listen to the audio.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleAudio,
              child: Text(isPlaying ? 'Pause audio' : 'Play audio'),
            ),
          ],
        ),

      const SizedBox(height: 30),

      const Text(
        'Overview questions',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 12),

      ...List.generate(questions.length, (index) {
        final question = questions[index];
        final options = question['options'] as List;

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
                  '${index + 1}. ${question['question']}',
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
                    groupValue: inputAnswers[index],
                    onChanged: inputSubmitted
                        ? null
                        : (value) {
                            setState(() {
                              inputAnswers[index] = value ?? '';
                            });
                          },
                  );
                }),

                if (inputSubmitted)
                  Text(
                    inputAnswers[index] == question['answer']
                        ? 'Correct'
                        : 'Not quite',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: inputAnswers[index] == question['answer']
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),

      const SizedBox(height: 12),

      if (!inputSubmitted)
        ElevatedButton(
          onPressed: submitInputAnswers,
          child: const Text('Submit answers'),
        )
      else ...[
        Text(
          'You got $inputScore / ${questions.length} correct.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: nextStep,
          child: const Text('Continue'),
        ),
      ],
    ],
  );
}

Widget buildVocabularyStep() {
  final vocab = data['vocabulary'] as List;
  final questions = data['vocabularyQuestions'] as List;

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildLessonSectionHeader(
          stepNumber: 2,
          totalSteps: 4,
          title: 'Vocabulary',
        ),

        const Text(
          'Learn Words',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        ...vocab.map((item) {
          return Card(
            color: Colors.amber.shade50,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.menu_book),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['word']} (${item['partOfSpeech'] ?? ''})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item['meaning'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),

        const Text(
          'Choose the best word to complete each sentence',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 12),

        ...List.generate(questions.length, (index) {
          final question = questions[index];
          final options = question['options'] as List;

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
                            },
                    );
                  }),

                  if (vocabularySubmitted)
                    Text(
                      vocabularyAnswers[index] == question['answer']
                          ? 'Correct'
                          : 'Incorrect. Correct answer: ${question['answer']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: vocabularyAnswers[index] == question['answer']
                            ? Colors.green
                            : Colors.orange,
                      ),
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
            child: const Text('Submit answers'),
          ),
        ] else ...[
          Text(
            'You got $vocabularyScore / ${questions.length} correct.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: nextStep,
            child: const Text('Continue'),
          ),
        ],
      ],
    ),
  );
}
Widget buildGrammarStep() {
  final grammar = data['grammar'] as Map;
  final examples = grammar['examples'] as List;
  final textExamples = grammar['textExamples'] as List? ?? [];
  final practice = grammar['practice'] as List;

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLessonSectionHeader(
          stepNumber: 3,
          totalSteps: 4,
          title: 'Grammar',
        ),

        const SizedBox(height: 20),

        Text(
          grammar['title'] as String,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                grammar['use'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                grammar['form'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Examples',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...examples.map((example) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade100),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.blue.shade400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    example as String,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        if (textExamples.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Examples from the text',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...textExamples.map((example) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade100),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      example as String,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 24),

        const Text(
          'Practice',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          grammar['instruction'] as String? ??
              'Use the correct word to complete each sentence.',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        ...List.generate(practice.length, (index) {
          final question = practice[index];

          final learnerAnswer =
              (grammarAnswers[index] ?? '').trim().toLowerCase();

          final correctAnswer =
              question['answer'].toString().trim().toLowerCase();

          final isCorrect = learnerAnswer == correctAnswer;

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
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    enabled: !grammarSubmitted,
                    decoration:
                      buildAnswerInputDecoration('Missing word(s) only'),
                    onChanged: (value) {
                      grammarAnswers[index] = value;
                    },
                  ),

                  if (grammarSubmitted) ...[
                    const SizedBox(height: 10),
                    Text(
                      isCorrect
                          ? 'Correct'
                          : 'Incorrect. Correct answer: ${question['answer']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green
                            : Colors.orange,
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
          ElevatedButton(
            onPressed: submitGrammarAnswers,
            child: const Text('Submit grammar answers'),
          ),
        ] else ...[
          Text(
            'You got $grammarScore / ${practice.length} correct.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextStep,
            child: const Text('Continue'),
          ),
        ],
      ],
    ),
  );
}
Widget buildComprehensionStep() {
  final questions = data['comprehension'] as List;
  final shortQuestions = data['shortAnswerQuestions'] as List? ?? [];
  final inputType = data['inputType'] as String;

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          buildLessonSectionHeader(
            stepNumber: 4,
            totalSteps: 4,
            title: 'Comprehension',
          ),
        const Text(
          'Comprehension',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

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
            const SizedBox(height: 20),
          ],

          if (inputType == 'listening') ...[
          const Text(
            'Listen to the audio again before answering the questions.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: toggleAudio,
            child: Text(isPlaying ? 'Pause audio' : 'Play audio'),
          ),
        ] else ...[
          const Text(
            'Read the text again before answering the questions.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['input'] as String,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 17,
              height: 1.6,
            ),
          ),
        ],

        const SizedBox(height: 24),

        const Text(
          'Multiple Choice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...List.generate(questions.length, (index) {
          final question = questions[index];
          final options = question['options'] as List;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question['question']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...options.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: comprehensionAnswers[index],
                      onChanged: comprehensionSubmitted
                          ? null
                          : (value) {
                              setState(() {
                                comprehensionAnswers[index] = value;
                              });
                            },
                    );
                  }),
                ],
              ),
            ),
          );
        }),

         const SizedBox(height: 30),

        if (shortQuestions.isNotEmpty) ...[
          const Text(
            'Short Answer Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...List.generate(shortQuestions.length, (index) {
            final question = shortQuestions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${question['question']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      enabled: !shortAnswersSubmitted,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write your answer',
                      ),
                      onChanged: (value) {
                        shortAnswers[index] = value;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

        if (!comprehensionSubmitted) ...[
          ElevatedButton(
            onPressed: submitComprehensionAnswers,
            child: const Text('Submit comprehension answers'),
          ),
        ] else ...[
          const SizedBox(height: 20),
          Text(
            'You got $comprehensionScore / 10 correct.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextStep,
            child: const Text('Continue'),
          ),
        ],
        ] else ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextStep,
            child: const Text('Continue'),
          ),
        ],
      ],
    ),
  );
}

Widget buildCompleteStep() {
  final totalScore =
      inputScore +
      vocabularyScore +
      grammarScore +
      comprehensionScore;

  final percentage =
      ((totalScore / 28) * 100).round();

  String message = '';

  if (totalScore >= 24) {
    message = 'Excellent work!';
  } else if (totalScore >= 18) {
    message = 'Good job!';
  } else if (totalScore >= 12) {
    message = 'Nice effort!';
  } else {
    message = 'Keep practising!';
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Lesson complete!',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      Text(
        message,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 20),

      Text(
        data['completionText'] as String,
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 30),

      Text(
        'Lesson Score: $percentage%',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Input: $inputScore / 3'),
              Text('Vocabulary: $vocabularyScore / 5'),
              Text('Grammar: $grammarScore / 5'),
              Text('Comprehension: $comprehensionScore / 10'),
            ],
          ),
        ),
      ),

      const SizedBox(height: 30),

      ElevatedButton(
        onPressed: () async {
          await saveLessonComplete();

          try {
            await saveTeacherSubmission();
          } catch (e) {
            print('Teacher submission failed: $e');
          }

          if (!context.mounted) return;
          Navigator.pop(context);
        },
        child: Text(data['backButtonText'] as String),
      ),
    ],
  );
}
@override
void dispose() {
  scrollController.dispose();
  audioPlayer.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['appBarTitle'] as String),
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