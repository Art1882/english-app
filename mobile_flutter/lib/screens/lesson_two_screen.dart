import 'package:flutter/material.dart';

class LessonTwoScreen extends StatefulWidget {
  const LessonTwoScreen({super.key});

  @override
  State<LessonTwoScreen> createState() => _LessonTwoScreenState();
}

class _LessonTwoScreenState extends State<LessonTwoScreen> {
  int step = 0;
  String? selectedAnswer;
  String feedback = '';
  
  void nextStep() {
    setState(() {
      step++;
      selectedAnswer = null;
      feedback = '';
    });
  }

  Widget getStep() {
    switch (step) {
      case 0:
        return buildSchemaStep();
      case 1:
        return buildReadingStep();
      case 2:
        return buildGistQuestionStep();
      case 3:
        return buildVocabularyStep();
      case 4:
        return buildPracticeStep();
      default:
        return buildCompleteStep();
    }
  }

  Widget buildSchemaStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Why do people learn languages?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'Think about it: Why do YOU learn English?',
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

  Widget buildReadingStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Read the text',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'People learn languages for many reasons. Some people learn English for work, while others learn it to travel or communicate with friends online.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: nextStep,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget buildGistQuestionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'What is the text about?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        RadioListTile<String>(
          title: const Text('Why people learn languages'),
          value: 'correct',
          groupValue: selectedAnswer,
          onChanged: (value) {
            setState(() {
              selectedAnswer = value;
              feedback = '';
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('How to write emails'),
          value: 'wrong',
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
              feedback = selectedAnswer == 'correct'
                  ? 'Correct!'
                  : 'Try again. Read the text again carefully.';
            });
          },
          child: const Text('Check'),
        ),
        const SizedBox(height: 12),
        Text(
          feedback,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: nextStep,
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget buildVocabularyStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Useful word',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'What does “communicate” mean?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              feedback = 'To communicate means to share information with others.';
            });
          },
          child: const Text('Show meaning'),
        ),
        const SizedBox(height: 12),
        Text(
          feedback,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: nextStep,
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget buildPracticeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Complete the question',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          '_____ do people learn English?',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        RadioListTile<String>(
          title: const Text('Why'),
          value: 'Why',
          groupValue: selectedAnswer,
          onChanged: (value) {
            setState(() {
              selectedAnswer = value;
              feedback = '';
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Where'),
          value: 'Where',
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
              feedback = selectedAnswer == 'Why'
                  ? 'Correct!'
                  : 'Try again. We use “Why” to ask about reasons.';
            });
          },
          child: const Text('Check'),
        ),
        const SizedBox(height: 12),
        Text(
          feedback,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: nextStep,
          child: const Text('Finish Lesson'),
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
        const Text(
          'You practised reading for gist, useful vocabulary, and asking about reasons.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Unit 1'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 1: Why Do People Learn Languages?'),
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