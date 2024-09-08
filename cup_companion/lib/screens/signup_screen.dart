import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';  // Correct path  // Import your AuthService class

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService(); // Instance of your AuthService class
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
            Image.asset('assets/images/logo.png',
            height: 200,),
            const SizedBox(height: 30.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _mobileNumberController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            _isLoading
                ? const CircularProgressIndicator() // Show a loader while waiting
                : ElevatedButton(
                    onPressed: _signUp, // Trigger sign up logic
                    child: const Text('Sign Up'),
                  ),
            const SizedBox(height: 24.0),
            if (_errorMessage != null) // Display error message if present
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24.0),
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

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the AuthService to create a user with email and password
      await _authService.createUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Navigate to a different screen (e.g., home page) after successful sign-up
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Catch and display any errors during the sign-up process
      setState(() {
        _errorMessage = e.toString(); // Show error message
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }
}
