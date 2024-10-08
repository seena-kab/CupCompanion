import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart'; // Import AuthService class
import 'package:flutter_svg/flutter_svg.dart'; // For SVG illustrations
import 'package:google_fonts/google_fonts.dart'; // For Google Fonts

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool isPasswordVisible = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
        _isLoading = false;
      });
      return;
    }

    try {
      final UserCredential userCredential = await _authService.signIn(email, password);
      final String uid = userCredential.user!.uid;

      // Check if the user has completed the survey
      bool hasCompletedSurvey = await _authService.hasCompletedSurvey(uid);

      if (!hasCompletedSurvey) {
        // Redirect to the survey screen if the survey is not completed
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/survey');
        }
      } else {
        // Redirect to home screen if survey is already completed
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFC3A0), Color(0xFFFDF3E7)], // Same gradient as SignUpScreen
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Playful SVG Illustration
                SvgPicture.asset(
                  'assets/illustrations/signin_illustration.svg', // Use a relevant SVG illustration
                  height: 200,
                ),
                const SizedBox(height: 30.0),

                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Change to black for consistency
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Email Text Field
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),

                // Password Text Field
                _buildPasswordField(),
                const SizedBox(height: 24.0),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),

                // Error Message
                const SizedBox(height: 16.0),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 24.0),

                // Sign Up and Forgot Password Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New member? ',
                      style: TextStyle(color: Colors.black), // Changed to black for consistency
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: Colors.black, // Changed to black for consistency
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.black)), // Changed to black for consistency
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(
        textStyle: const TextStyle(color: Colors.black), // Changed to black for consistency
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black87), // Changed to dark color for consistency
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black87), // Changed to dark color for consistency
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black54, width: 1.0), // Changed to dark color for consistency
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0), // Changed to dark color for consistency
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      style: GoogleFonts.montserrat(
        textStyle: const TextStyle(color: Colors.black), // Changed to black for consistency
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.black87), // Changed to dark color for consistency
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.black87), // Changed to dark color for consistency
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black54, width: 1.0), // Changed to dark color for consistency
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0), // Changed to dark color for consistency
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black87, // Changed to dark color for consistency
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}