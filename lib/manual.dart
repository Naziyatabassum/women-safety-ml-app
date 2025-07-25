import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const <Widget>[
            Text(
              'Welcome to the Women Safety App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'How to use the app:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '1. After registering or logging in, you will be directed to the home screen.\n'
              '2. You can view motivational quotes and access emergency buttons for alert, contacting police, or relatives.\n'
              '3. The "Risk" button will allow the app to assess the situation and provide a risk prediction.\n'
              '4. If the app detects high risk, it can notify your saved contacts automatically.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '- Emergency alert system with one-tap buttons.\n'
              '- Location-based risk prediction using machine learning.\n'
              '- Nearby hospital and police station info.\n'
              '- Ability to save and notify trusted contacts.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}