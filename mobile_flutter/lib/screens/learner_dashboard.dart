import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unit_one_overview_screen.dart';

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

  @override
  void initState() {
    super.initState();
    loadUnitProgress();
  }

  Future<void> loadUnitProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final completed = [
      prefs.getBool('unit1_lesson1_complete') ?? false,
      prefs.getBool('unit1_lesson2_complete') ?? false,
      prefs.getBool('unit1_lesson3_complete') ?? false,
      prefs.getBool('unit1_lesson4_complete') ?? false,
      prefs.getBool('unit1_lesson5_complete') ?? false,
      prefs.getBool('unit1_test_complete') ?? false,
    ].where((item) => item).length;

    setState(() {
      unit1CompletedItems = completed;
    });
  }

  String get unit1Status {
    if (unit1CompletedItems == 6) {
      return 'Unit completed';
    }

    if (unit1CompletedItems > 0) {
      return 'In progress';
    }

    return 'Start learning';
  }

  double get unit1ProgressValue {
    return unit1CompletedItems / 6;
  }

  @override
  Widget build(BuildContext context) {
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

            LearnerUnitCard(
              title: '🗣 Unit 1',
              subtitle: 'How people communicate',
              status: unit1Status,
              progressValue: unit1ProgressValue,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UnitOneOverviewScreen(),
                  ),
                );

                loadUnitProgress();
              },
            ),

            LearnerUnitCard(
              title: 'Unit 2',
              subtitle: 'This unit will be added soon',
              status: 'Coming soon',
              progressValue: 0.0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ComingSoonScreen(unitTitle: 'Unit 2'),
                  ),
                );
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