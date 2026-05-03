import 'package:flutter/material.dart';
import 'lesson_1_data.dart';

class UnitOneLessonScreen extends StatefulWidget {
  const UnitOneLessonScreen({super.key});

  @override
  State<UnitOneLessonScreen> createState() => _UnitOneLessonScreenState();
}

class _UnitOneLessonScreenState extends State<UnitOneLessonScreen> {
  final data = lesson1;

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
        Text(
          data['title'] as String,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          ((data['schema'] as List)[0]) as String,
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
        Text(
          data['reading'] as String,
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
  final options = data['gistOptions'] as List;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        data['gistQuestion'] as String,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      RadioListTile<String>(
        title: Text(options[0]),
        value: options[0],
        groupValue: selectedAnswer,
        onChanged: (value) {
          setState(() {
            selectedAnswer = value;
            feedback = '';
          });
        },
      ),
      RadioListTile<String>(
        title: Text(options[1]),
        value: options[1],
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
            feedback = selectedAnswer == data['gistAnswer']
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
        child: const Text('Next'),
      ),
    ],
  );
}

Widget buildVocabularyStep() {
  final vocab = data['vocabulary'] as List;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Useful word',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      Text(
        '${vocab[0]['word']} = ${vocab[0]['meaning']}',
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