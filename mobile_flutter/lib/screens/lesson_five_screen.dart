import 'package:flutter/material.dart';

class LessonFiveScreen extends StatefulWidget {
  const LessonFiveScreen({super.key});

  @override
  State<LessonFiveScreen> createState() => _LessonFiveScreenState();
}

class _LessonFiveScreenState extends State<LessonFiveScreen> {
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
          'Feelings, Ideas and Identity',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'How do people express feelings and ideas?',
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
          'People often talk about feelings and ideas. Happiness, communication, and identity are important in daily life. Sharing ideas helps people understand each other better.',
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
          title: const Text('Feelings and ideas'),
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
          title: const Text('Fixing computers'),
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
        'happiness = a feeling of being happy\nidentity = who a person is',
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
        '_____ is important when talking to others.',
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 20),
      RadioListTile<String>(
        title: const Text('Communication'),
        value: 'Communication',
        groupValue: selectedAnswer,
        onChanged: (value) {
          setState(() {
            selectedAnswer = value;
            feedback = '';
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Communicate'),
        value: 'Communicate',
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
            feedback = selectedAnswer == 'Communication'
            ? 'Correct!'
            : 'Try again. We use nouns like “communication” to talk about ideas.';
            }),
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
          'You practised reading for gist, useful vocabulary, and talking about ideas using nouns.',
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
        title: const Text('Lesson 5: Feelings, Ideas and Identity'),
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