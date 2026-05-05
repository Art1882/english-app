import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import '../courses/year8/unit1/input_lesson_screen.dart';
import '../courses/year8/unit1/lesson_1_data.dart';
import '../courses/year8/unit1/lesson_2_data.dart';

class UnitOneOverviewScreen extends StatelessWidget {
  const UnitOneOverviewScreen({super.key});

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
              'Lesson 1: Why Do People Learn Languages?',
              InputLessonScreen(data: lesson1),
            ),

            buildLessonButton(
              context,
              'Lesson 2: Different Ways to Say the Same Thing',
              InputLessonScreen(data: lesson2),
            ),

            buildLessonButton(
              context,
              'Lesson 3: Communicating Without Words',
              null,
            ),

            buildLessonButton(
              context,
              'Lesson 4: What Are People Doing Online?',
              null,
            ),

            buildLessonButton(
              context,
              'Lesson 5: Feelings, Ideas and Identity',
              null,
            ),

            const SizedBox(height: 20),

            buildLessonButton(
              context,
              'Final Task: Create a Guide to Communication',
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLessonButton(
      BuildContext context, String title, Widget? screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: screen == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => screen,
                  ),
                );
              },
        child: Text(title),
      ),
    );
  }
}