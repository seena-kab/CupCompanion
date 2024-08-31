import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Enter Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility),
              ),
              obscureText: true,
        ),
        const SizedBox(height: 24.0,),
        ElevatedButton(
          onPressed: () {
            //Handle Sign Up Logic
          },
          child: const Icon(Icons.arrow_forward),
      ),
      const SizedBox(height:24.0),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signin');
        },
        child: const Text('Already a member? Sign in'),
      ),
    ],
   ),
    ),
    );
  }
}