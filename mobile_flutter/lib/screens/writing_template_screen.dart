import 'package:flutter/material.dart';

class WritingTemplateScreen extends StatefulWidget {
  const WritingTemplateScreen({super.key});

  @override
  State<WritingTemplateScreen> createState() => _WritingTemplateScreenState();
}

class _WritingTemplateScreenState extends State<WritingTemplateScreen> {
  final TextEditingController controller = TextEditingController();
  String feedback = '';

  void submitWriting() {
    setState(() {
      feedback = 'Feedback will appear here (AI later)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Writing Task')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Write 3–5 sentences about why people learn languages.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitWriting,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            Text(feedback),
          ],
        ),
      ),
    );
  }
}