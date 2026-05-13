import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../courses/year8/input_lesson_screen.dart';
import '../courses/year8/unit1/lesson_1_data.dart';
import '../courses/year8/unit1/lesson_2_data.dart';
import '../courses/year8/unit1/lesson_3_data.dart';
import '../courses/year8/unit1/lesson_4_data.dart';
import '../courses/year8/unit1/lesson_5_data.dart';
import '../courses/year8/unit_test_screen.dart';
import '../courses/year8/unit1/unit_1_test_data.dart';

class UnitOneOverviewScreen extends StatefulWidget {
  const UnitOneOverviewScreen({super.key});

  @override
  State<UnitOneOverviewScreen> createState() => _UnitOneOverviewScreenState();
}

class _UnitOneOverviewScreenState extends State<UnitOneOverviewScreen> {
//Savebeta

  bool lesson1Complete = false;
  bool lesson2Complete = false;
  bool lesson3Complete = false;
  bool lesson4Complete = false;
  bool lesson5Complete = false;
  bool unitTestComplete = false;

  @override
    void initState() {
      super.initState();
      loadProgress();
    }

  Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    lesson1Complete =
        prefs.getBool('unit1_lesson1_complete') ?? false;

    lesson2Complete =
        prefs.getBool('unit1_lesson2_complete') ?? false;

    lesson3Complete =
        prefs.getBool('unit1_lesson3_complete') ?? false;

    lesson4Complete =
        prefs.getBool('unit1_lesson4_complete') ?? false;

    lesson5Complete =
        prefs.getBool('unit1_lesson5_complete') ?? false;

    unitTestComplete =
        prefs.getBool('unit1_test_complete') ?? false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit 1: How People Communicate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Choose a lesson',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            buildLessonButton(
              context,
                lesson1Complete
                  ? '✔ Lesson 1: Why Do People Learn Languages?'
                  : 'Lesson 1: Why Do People Learn Languages?',
              InputLessonScreen(data: lesson1),
            ),

            buildLessonButton(
              context,
                lesson2Complete
                  ? '✔ Lesson 2: Different Ways to Say the Same Thing'
                  : 'Lesson 2: Different Ways to Say the Same Thing',
              InputLessonScreen(data: lesson2),
            ),

            buildLessonButton(
              context,
                lesson3Complete
                  ? '✔ Lesson 3: Communicating Without Words'
                  : 'Lesson 3: Communicating Without Words',
              InputLessonScreen(data: lesson3),
            ),

            buildLessonButton(
              context,
                lesson4Complete
                  ? '✔ Lesson 4: What Are People Doing Online?'
                  : 'Lesson 4: What Are People Doing Online?',
              InputLessonScreen(data: lesson4),
            ),

            buildLessonButton(
              context,
                lesson5Complete
                  ? '✔ Lesson 5: Feelings, Ideas and Identity'
                  : 'Lesson 5: Feelings, Ideas and Identity',
              InputLessonScreen(data: lesson5),
            ),

            const SizedBox(height: 20),

            buildLessonButton(
              context,
                unitTestComplete
                  ? '✔ Unit 1 Review Test'
                  : 'Unit 1 Review Test',
              UnitTestScreen(data: unit1Test),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLessonButton(
      BuildContext context,
      String title,
      Widget? screen,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),

        onPressed: screen == null
            ? null
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => screen,
                  ),
                );

                loadProgress();
              },

        child: Text(title),
      ),
    );
  }
}
