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
      lesson1Complete = prefs.getBool('unit1_lesson1_complete') ?? false;
      lesson2Complete = prefs.getBool('unit1_lesson2_complete') ?? false;
      lesson3Complete = prefs.getBool('unit1_lesson3_complete') ?? false;
      lesson4Complete = prefs.getBool('unit1_lesson4_complete') ?? false;
      lesson5Complete = prefs.getBool('unit1_lesson5_complete') ?? false;
      unitTestComplete = prefs.getBool('unit1_test_complete') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Unit 1',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'How people communicate',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            buildLessonCard(
              title: 'Lesson 1',
              subtitle: 'Why Do People Learn Languages?',
              complete: lesson1Complete,
              screen: InputLessonScreen(data: lesson1),
            ),

            buildLessonCard(
              title: 'Lesson 2',
              subtitle: 'Different Ways to Say the Same Thing',
              complete: lesson2Complete,
              screen: InputLessonScreen(data: lesson2),
            ),

            buildLessonCard(
              title: 'Lesson 3',
              subtitle: 'Communicating Without Words',
              complete: lesson3Complete,
              screen: InputLessonScreen(data: lesson3),
            ),

            buildLessonCard(
              title: 'Lesson 4',
              subtitle: 'What Are People Doing Online?',
              complete: lesson4Complete,
              screen: InputLessonScreen(data: lesson4),
            ),

            buildLessonCard(
              title: 'Lesson 5',
              subtitle: 'Feelings, Ideas and Identity',
              complete: lesson5Complete,
              screen: InputLessonScreen(data: lesson5),
            ),

            buildLessonCard(
              title: 'Unit Review',
              subtitle: 'Review test',
              complete: unitTestComplete,
              screen: UnitTestScreen(data: unit1Test),
              isTest: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLessonCard({
    required String title,
    required String subtitle,
    required bool complete,
    required Widget screen,
    bool isTest = false,
  }) {
    return Card(
      color: isTest
          ? Colors.purple.shade50
          : complete
              ? Colors.green.shade100
              : Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
            ),
          );

          loadProgress();
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                complete
                    ? Icons.check_circle_outline
                    : isTest
                        ? Icons.star_outline
                        : Icons.play_circle_outline,
                size: 36,
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complete ? '✔ $title' : title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      complete
                          ? 'Completed'
                          : isTest
                              ? 'Test'
                              : 'Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: complete
                            ? Colors.green
                            : isTest
                                ? Colors.purple
                                : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}