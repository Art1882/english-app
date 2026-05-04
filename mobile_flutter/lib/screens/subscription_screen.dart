import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
Z
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Unlock AI Writing Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
             onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                    content: Text('Subscription system will be added later.'),
                    ),
                );
                },
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }
}