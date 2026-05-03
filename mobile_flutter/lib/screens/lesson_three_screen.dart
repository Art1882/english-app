import 'package:flutter/material.dart';

class LessonThreeScreen extends StatefulWidget {
  const LessonThreeScreen({super.key});

  @override
  State<LessonThreeScreen> createState() => _LessonThreeScreenState();
}

class _LessonThreeScreenState extends State<LessonThreeScreen> {
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
          'Communicating Without Words',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'How do people communicate without speaking?',
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
          'People often communicate without speaking. Using emojis is common in messages. Sharing images and reacting quickly helps people understand feelings.',
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
          title: const Text('Communicating without speaking'),
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
          title: const Text('writing long emails'),
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
        'emoji = a small digital image\nreact = to respond quickly',
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
        '_____ emojis is common in messages.',
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 20),
      RadioListTile<String>(
        title: const Text('Using'),
        value: 'Using',
        groupValue: selectedAnswer,
        onChanged: (value) {
          setState(() {
            selectedAnswer = value;
            feedback = '';
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Use'),
        value: 'Use',
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
            feedback = selectedAnswer == 'Using'
                ? 'Correct!'
                : 'Try again. We use "-ing" for actions as subjects.';
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
          'You practised reading for gist, useful vocabulary, and using -ing forms.',
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
        title: const Text('Lesson 3: Communicating Without Words'),
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