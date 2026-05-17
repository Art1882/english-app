class TeacherAnalyticsScreen extends StatelessWidget {
  const TeacherAnalyticsScreen({super.key});

  final List<Map<String, dynamic>> students = const [
    {
      'name': 'Demo Student',
      'class': '8A',
      'lessonsCompleted': 6,
      'averageScore': 84,
      'unitReviewScore': 78,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Analytics'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(student['name']),
              subtitle: Text(
                'Class: ${student['class']}\n'
                'Lessons completed: ${student['lessonsCompleted']}\n'
                'Average score: ${student['averageScore']}%\n'
                'Unit review: ${student['unitReviewScore']}%',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // later: open individual student work
              },
            ),
          );
        },
      ),
    );
  }
}