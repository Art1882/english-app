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
  int shortAnswerScore = 0;

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

    inputAnswers = {};
    inputSubmitted = false;
    inputScore = 0;

    vocabularyAnswers = {};
    vocabularySubmitted = false;
    vocabularyScore = 0;

    grammarAnswers = {};
    grammarSubmitted = false;
    grammarScore = 0;

    comprehensionAnswers = {};
    comprehensionSubmitted = false;
    comprehensionScore = 0;

    shortAnswers = {};
    shortAnswersSubmitted = false;
    shortAnswerScore = 0;
  });
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
  final questions = data['comprehension'] as List;

  int score = 0;

  for (int i = 0; i < questions.length; i++) {
    if (comprehensionAnswers[i] == questions[i]['answer']) {
      score++;
    }
  }

  setState(() {
    comprehensionScore = score;
    comprehensionSubmitted = true;
  });
}

void submitShortAnswers() {
  final questions = data['shortAnswerQuestions'] as List;

  int score = 0;

  for (int i = 0; i < questions.length; i++) {
    final correctAnswer =
        (questions[i]['answer'] as String).trim().toLowerCase();

    final learnerAnswer =
        (shortAnswers[i] ?? '').trim().toLowerCase();

    if (learnerAnswer == correctAnswer) {
      score++;
    }
  }

  setState(() {
    shortAnswerScore = score;
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
    Uri.parse('$baseUrl/check'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "student": studentName,
      "class": studentClass,
      "lesson": data['appBarTitle'] ?? 'Unknown lesson',
      "activity": "Lesson completed",
      "answer": "Completed lesson activities",
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


Widget buildInputStep() {
  final inputType = data['inputType'] as String;
  final questions = data['inputQuestions'] as List;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        inputType == 'reading' ? 'Read' : 'Listen',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 20),

      if (inputType == 'reading')
        Text(
          data['input'] as String,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question['question']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

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
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 16),
          ],
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

  bool allAnswered = true;

  for (int i = 0; i < questions.length; i++) {
    if ((vocabularyAnswers[i] ?? '').trim().isEmpty) {
      allAnswered = false;
      break;
    }
  }


  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Learn Words',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        ...vocab.map((item) {
          return Card(
            child: ListTile(
              title: Text(
                item['word'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['meaning'] as String),
            ),
          );
        }),

        const SizedBox(height: 24),

        const Text(
          'Complete the sentences',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        ...List.generate(questions.length, (index) {
          final question = questions[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              enabled: !vocabularySubmitted,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '${index + 1}. ${question['sentence']}',
              ),
              onChanged: (value) {
                vocabularyAnswers[index] = value;
              },
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
        Text(
          grammar['title'] as String,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        const Text(
          'Use',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(grammar['use'] as String),

        const SizedBox(height: 16),

        const Text(
          'Form',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(grammar['form'] as String),

        const SizedBox(height: 16),

        const Text(
          'Examples from the text',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...examples.map((example) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $example'),
          );
        }),


        const SizedBox(height: 20),

        if (textExamples.isNotEmpty) ...[
          const Text(
            'Examples from the text',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...textExamples.map((example) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $example'),
            );
          }),

          const SizedBox(height: 20),
        ],

        const Text(
          'Practice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...List.generate(practice.length, (index) {
          final question = practice[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['sentence'] as String,
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
            'You got $grammarScore / ${practice.length} correct.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        const Text(
          'Comprehension',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

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
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
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

        if (!comprehensionSubmitted) ...[
          ElevatedButton(
            onPressed: submitComprehensionAnswers,
            child: const Text('Submit multiple choice answers'),
          ),
        ] else ...[
          Text(
            'You got $comprehensionScore / ${questions.length} multiple choice questions correct.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],

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

          if (!shortAnswersSubmitted) ...[
            ElevatedButton(
              onPressed: submitShortAnswers,
              child: const Text('Submit short answers'),
            ),
          ] else ...[
            Text(
              'You got $shortAnswerScore / ${shortQuestions.length} short answer questions correct.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Lesson complete!',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      Text(
        data['completionText'] as String,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 30),
      ElevatedButton(
        onPressed: () async {
          await saveLessonComplete();
          await saveTeacherSubmission();

          if (!context.mounted) return;
          Navigator.pop(context);
        },
        child: Text(data['backButtonText'] as String),
      ),
    ],
  );
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
              child: getStep(),
            ),
          ),
        ),
      ),
    );
  }
}