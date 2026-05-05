import 'package:flutter/material.dart';
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

  Map<int, String> inputAnswers = {};
  bool inputSubmitted = false;
  int inputScore = 0;

  Map<int, String> vocabularyAnswers = {};
  bool vocabularySubmitted = false;
  int vocabularyScore = 0;

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

  void submitInputAnswers() {
    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final correctAnswer = question['answer'];

      if (inputAnswers[i] == correctAnswer) {
        score++;
      }
    }

    setState(() {
      inputScore = score;
      inputSubmitted = true;
    });
  }

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
        const Text(
          'Audio player will go here.',
          textAlign: TextAlign.center,
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
          onPressed: inputAnswers.length == questions.length
              ? submitInputAnswers
              : null,
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

  void submitVocabularyAnswers() {
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
  final grammarOptions = data['grammarOptions'] as List;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Complete the question',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      Text(
        data['grammarQuestion'] as String,
        style: const TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 20),
      RadioListTile<String>(
        title: Text(grammarOptions[0]),
        value: grammarOptions[0],
        groupValue: selectedAnswer,
        onChanged: (value) {
          setState(() {
            selectedAnswer = value;
            feedback = '';
          });
        },
      ),
      RadioListTile<String>(
        title: Text(grammarOptions[1]),
        value: grammarOptions[1],
        groupValue: selectedAnswer,
        onChanged: (value) {
          setState(() {
            selectedAnswer = value;
            feedback = '';
          });
        },
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          setState(() {
            feedback = selectedAnswer == data['grammarAnswer']
                ? 'Correct!'
                : 'Try again';
          });
        },
        child: const Text('Check'),
      ),
      const SizedBox(height: 12),
      Text(feedback, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: nextStep,
        child: const Text('Finish Lesson'),
      ),
    ],
  );
}
Widget buildComprehensionStep() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Check Understanding',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      const Text(
        'Comprehension questions will go here next.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 30),
      ElevatedButton(
        onPressed: nextStep,
        child: const Text('Continue'),
      ),
    ],
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
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(data['backButtonText'] as String),
      ),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: () {
          handleWritingAccess(context);
        },
        child: const Text('Improve your writing (AI)'),
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
            child: getStep(),
          ),
        ),
      ),
    );
  }
}