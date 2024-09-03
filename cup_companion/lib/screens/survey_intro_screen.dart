import 'package:flutter/material.dart';

class SurveyIntroScreen extends StatelessWidget {
  const SurveyIntroScreen({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 24.0),
            const Text(
              "Let's Get to know you!",
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height:16.0),
            const Text(
              'Complete this survey to start discovering',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height:24.0),
            ElevatedButton(onPressed: () {
              //naviagte to Survey Screen
            },
            child: const Text('Start Survey'),
            ),
          ],
        ),
      ),
    );
  }
}