import 'package:flutter/material.dart';
import 'unit_one_overview_screen.dart';

class LearnerDashboard extends StatelessWidget {
  final String studentName;
  final String studentClass;

  const LearnerDashboard({
    super.key,
    required this.studentName,
    required this.studentClass,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Welcome, $studentName',
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              'Class: $studentClass',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            LearnerUnitCard(
              title: 'Unit 1',
              subtitle: 'How people communicate',
              status: 'Available',
              isLocked: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UnitOneOverviewScreen(),
                  ),
                );
              },
            ),

            LearnerUnitCard(
              title: 'Unit 2',
              subtitle: 'Coming soon',
              status: 'Locked',
              isLocked: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ComingSoonScreen(
                      unitTitle: 'Unit 2',
                    ),
                  ),
                );
              },
            ),

            LearnerUnitCard(
              title: 'Unit 3',
              subtitle: 'Coming soon',
              status: 'Locked',
              isLocked: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ComingSoonScreen(
                      unitTitle: 'Unit 3',
                    ),
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
        child: Text(
          '$unitTitle is coming soon.',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
  final bool isLocked;
  final VoidCallback onTap;

  const LearnerUnitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                isLocked
                    ? Icons.lock_outline
                    : Icons.menu_book,
                size: 36,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isLocked
                            ? Colors.grey
                            : Colors.green,
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