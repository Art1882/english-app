import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unit_one_overview_screen.dart';
import 'unit_two_overview_screen.dart';

import '../courses/year8/input_lesson_screen.dart';

import '../courses/year8/unit1/lesson_1_data.dart' as unit1_lesson1_data;
import '../courses/year8/unit1/lesson_2_data.dart' as unit1_lesson2_data;
import '../courses/year8/unit1/lesson_3_data.dart' as unit1_lesson3_data;
import '../courses/year8/unit1/lesson_4_data.dart' as unit1_lesson4_data;
import '../courses/year8/unit1/lesson_5_data.dart' as unit1_lesson5_data;

import '../courses/year8/unit2/lesson_1_data.dart' as unit2_lesson1_data;
import '../courses/year8/unit2/lesson_2_data.dart' as unit2_lesson2_data;
import '../courses/year8/unit2/lesson_3_data.dart' as unit2_lesson3_data;
import '../courses/year8/unit2/lesson_4_data.dart' as unit2_lesson4_data;

class LearnerDashboard extends StatefulWidget {
  final String studentName;
  final String studentClass;

  const LearnerDashboard({
    super.key,
    required this.studentName,
    required this.studentClass,
  });

  @override
  State<LearnerDashboard> createState() => _LearnerDashboardState();
}

class _LearnerDashboardState extends State<LearnerDashboard> {
  int unit1CompletedItems = 0;
  int unit2CompletedItems = 0;

  String? currentLessonId;

  @override
  void initState() {
    super.initState();
    loadUnitProgress();
  }

  Future<void> loadUnitProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final unit1Completed = [
      prefs.getBool('unit1_lesson1_complete') ?? false,
      prefs.getBool('unit1_lesson2_complete') ?? false,
      prefs.getBool('unit1_lesson3_complete') ?? false,
      prefs.getBool('unit1_lesson4_complete') ?? false,
      prefs.getBool('unit1_lesson5_complete') ?? false,
      prefs.getBool('unit1_test_complete') ?? false,
    ].where((item) => item).length;

    final unit2Completed = [
      prefs.getBool('unit2_lesson1_complete') ?? false,
      prefs.getBool('unit2_lesson2_complete') ?? false,
      prefs.getBool('unit2_lesson3_complete') ?? false,
      prefs.getBool('unit2_lesson4_complete') ?? false,
      prefs.getBool('unit2_test_complete') ?? false,
    ].where((item) => item).length;

    setState(() {
      unit1CompletedItems = unit1Completed;
      unit2CompletedItems = unit2Completed;
      currentLessonId = prefs.getString('current_lesson_id');
    });
  }

  String getUnitStatus(
    int completedItems,
    int totalItems,
  ) {
    if (completedItems == totalItems) {
      return 'Unit completed';
    }

    if (completedItems > 0) {
      return 'In progress';
    }

    return 'Start learning';
  }

  double getUnitProgressValue(
    int completedItems,
    int totalItems,
  ) {
    return completedItems / totalItems;
  }

  String getCurrentLessonTitle(String lessonId) {
    switch (lessonId) {
      case 'unit1_lesson1':
        return 'Unit 1 Lesson 1: Why Do People Learn Languages?';
      case 'unit1_lesson2':
        return 'Unit 1 Lesson 2: Different Ways to Say the Same Thing';
      case 'unit1_lesson3':
        return 'Unit 1 Lesson 3: Communicating Without Words';
      case 'unit1_lesson4':
        return 'Unit 1 Lesson 4: What Are People Doing Online?';
      case 'unit1_lesson5':
        return 'Unit 1 Lesson 5: Feelings, Ideas and Identity';
      case 'unit2_lesson1':
        return 'Unit 2 Lesson 1: Everyday Objects';
      case 'unit2_lesson2':
        return 'Unit 2 Lesson 2: Imagining Different Worlds';
      case 'unit2_lesson3':
        return 'Unit 2 Lesson 3: Amazing Buildings';
      case 'unit2_lesson4':
        return 'Unit 2 Lesson 4: Building a Better Future';
      default:
        return 'Unfinished lesson';
    }
  }

  Widget? getResumeLessonScreen(String lessonId) {
    switch (lessonId) {
      case 'unit1_lesson1':
        return InputLessonScreen(data: unit1_lesson1_data.lesson1);
      case 'unit1_lesson2':
        return InputLessonScreen(data: unit1_lesson2_data.lesson2);
      case 'unit1_lesson3':
        return InputLessonScreen(data: unit1_lesson3_data.lesson3);
      case 'unit1_lesson4':
        return InputLessonScreen(data: unit1_lesson4_data.lesson4);
      case 'unit1_lesson5':
        return InputLessonScreen(data: unit1_lesson5_data.lesson5);
      case 'unit2_lesson1':
        return InputLessonScreen(data: unit2_lesson1_data.lesson1);
      case 'unit2_lesson2':
        return InputLessonScreen(data: unit2_lesson2_data.lesson2);
      case 'unit2_lesson3':
        return InputLessonScreen(data: unit2_lesson3_data.lesson3);
      case 'unit2_lesson4':
        return InputLessonScreen(data: unit2_lesson4_data.lesson4);
      default:
        return null;
    }
  }

  Future<void> resumeCurrentLesson() async {
    final lessonId = currentLessonId;

    if (lessonId == null) {
      return;
    }

    final screen = getResumeLessonScreen(lessonId);

    if (screen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not resume this lesson. Please open it manually.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );

    await loadUnitProgress();
  }

  @override
  Widget build(BuildContext context) {
    final unit1Status = getUnitStatus(unit1CompletedItems, 6);
    final unit2Status = getUnitStatus(unit2CompletedItems, 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Learner Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Welcome, ${widget.studentName}',
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              'Class: ${widget.studentClass}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            if (currentLessonId != null) ...[
              Card(
                color: Colors.amber.shade100,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: resumeCurrentLesson,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 38,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resume unfinished lesson',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                getCurrentLessonTitle(currentLessonId!),
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Continue where you left off',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
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
              ),
            ],

            LearnerUnitCard(
              title: '🗣 Unit 1',
              subtitle: 'How people communicate',
              status: unit1Status,
              progressValue: getUnitProgressValue(unit1CompletedItems, 6),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnitOneOverviewScreen(),
                  ),
                );

                loadUnitProgress();
              },
            ),

            LearnerUnitCard(
              title: '📘 Unit 2',
              subtitle: 'The World Around Us',
              status: unit2Status,
              progressValue: getUnitProgressValue(unit2CompletedItems, 5),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnitTwoOverviewScreen(),
                  ),
                );

                loadUnitProgress();
              },
            ),

            LearnerUnitCard(
              title: 'Unit 3',
              subtitle: 'This unit will be added soon',
              status: 'Coming soon',
              progressValue: 0.0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ComingSoonScreen(unitTitle: 'Unit 3'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  final String unitTitle;

  const ComingSoonScreen({
    super.key,
    required this.unitTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unitTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$unitTitle is coming soon.\n\nFor the beta version, units will not be permanently locked until progress saving is fully tested.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class LearnerUnitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final double progressValue;
  final VoidCallback onTap;

  const LearnerUnitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progressValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComingSoon = status == 'Coming soon';
    final bool isCompleted = status == 'Unit completed';

    return Card(
      color: isComingSoon
          ? Colors.orange.shade50
          : isCompleted
              ? Colors.green.shade100
              : Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                isComingSoon
                    ? Icons.hourglass_empty
                    : isCompleted
                        ? Icons.check_circle_outline
                        : Icons.menu_book,
                size: 36,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isComingSoon
                            ? Colors.orange
                            : isCompleted
                                ? Colors.green
                                : Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: progressValue,
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
