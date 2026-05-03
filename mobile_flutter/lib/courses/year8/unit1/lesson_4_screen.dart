import 'package:flutter/material.dart';

class LessonFourScreen extends StatefulWidget {
  const LessonFourScreen({super.key});

  @override
  State<LessonFourScreen> createState() => _LessonFourScreenState();
}

class _LessonFourScreenState extends State<LessonFourScreen> {
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
          'What Are People Doing Online?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'What are people doing on their phones right now?',
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
          'Many people are communicating online every day. Some are sending messages, while others are sharing photos or watching videos. In many classrooms, students are using apps to learn new languages.',
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
          title: const Text('What people are doing online'),
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
          title: const Text('How to repair a phone'),
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
        'Useful words',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      const Text(
        'online = connected to the internet\napp = a program on a phone or computer',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 30),
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
        'Complete the sentence',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      const Text(
        'Students _____ using apps to learn languages.',
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 20),
      RadioListTile<String>(
        title: const Text('are'),
        value: 'are',
        groupValue: selectedAnswer,
        onChanged: (value) {
          setState(() {
            selectedAnswer = value;
            feedback = '';
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('is'),
        value: 'is',
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
            feedback = selectedAnswer == 'are'
              ? 'Correct!'
              : 'Try again. We use “are” with plural nouns like “students”.';
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
          'You practised reading for gist, useful vocabulary, and describing actions happening now.',
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
        title: const Text('Lesson 4: What Are People Doing Online?'),
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