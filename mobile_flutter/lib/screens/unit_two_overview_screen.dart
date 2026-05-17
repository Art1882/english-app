import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitTwoOverviewScreen extends StatefulWidget {
  const UnitTwoOverviewScreen({super.key});

  @override
  State<UnitTwoOverviewScreen> createState() =>
      _UnitTwoOverviewScreenState();
}

class _UnitTwoOverviewScreenState
    extends State<UnitTwoOverviewScreen> {
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
          prefs.getBool('unit2_lesson1_complete') ?? false;

      lesson2Complete =
          prefs.getBool('unit2_lesson2_complete') ?? false;

      lesson3Complete =
          prefs.getBool('unit2_lesson3_complete') ?? false;

      lesson4Complete =
          prefs.getBool('unit2_lesson4_complete') ?? false;

      lesson5Complete =
          prefs.getBool('unit2_lesson5_complete') ?? false;

      unitTestComplete =
          prefs.getBool('unit2_test_complete') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Unit 2',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Placeholder unit title',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 24),

            buildLessonCard(
              title: 'Lesson 1',
              subtitle: 'Placeholder lesson',
              complete: lesson1Complete,
            ),

            buildLessonCard(
              title: 'Lesson 2',
              subtitle: 'Placeholder lesson',
              complete: lesson2Complete,
            ),

            buildLessonCard(
              title: 'Lesson 3',
              subtitle: 'Placeholder lesson',
              complete: lesson3Complete,
            ),

            buildLessonCard(
              title: 'Lesson 4',
              subtitle: 'Placeholder lesson',
              complete: lesson4Complete,
            ),

            buildLessonCard(
              title: 'Lesson 5',
              subtitle: 'Placeholder lesson',
              complete: lesson5Complete,
            ),

            buildLessonCard(
              title: 'Unit Review',
              subtitle: 'Placeholder review',
              complete: unitTestComplete,
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
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unit 2 lessons coming soon',
              ),
            ),
          );
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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