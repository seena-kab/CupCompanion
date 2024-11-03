import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart'; // Correct path
import 'package:flutter_svg/flutter_svg.dart'; // For SVG illustrations
import 'package:google_fonts/google_fonts.dart'; // For Google Fonts

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService(); // Instance of your AuthService class
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool isPasswordVisible = false; // Password visibility tracker

  // Animation Controller for form animations
  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define fade-in animation
    fadeInAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);

    // Start the animation
    animationController.forward();
  }

  // Method to validate email format
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9._-]+\.[a-zA-Z]+$",
    );
    return emailRegex.hasMatch(email);
  }

  // Method to validate mobile number format
  bool _isValidMobileNumber(String number) {
    return RegExp(r'^\d{10}$').hasMatch(number);
  }

  // Method to show inline error messages
  Widget _buildErrorMessage() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Trim and validate the input
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();
    final String mobileNumber = _mobileNumberController.text.trim();

    // Input validation
    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        mobileNumber.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
        _isLoading = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
      });
      return;
    }

    if (!_isValidMobileNumber(mobileNumber)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
        _isLoading = false;
      });
      return;
    }

    try {
      // Call the AuthService to create a user with email, password, username, and mobile number
      await _authService.createUser(
        email,
        password,
        username,
        mobileNumber,
      );

      // Navigate to a different screen (e.g., sign-in page) after successful sign-up
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } catch (e) {
      // Catch and display any errors during the sign-up process
      setState(() {
        _errorMessage = e.toString(); // Show error message
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _mobileNumberController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Gradient background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFC3A0), Color(0xFFFDF3E7)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: FadeTransition(
              opacity: fadeInAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SVG Illustration Only
                  SvgPicture.asset(
                    'assets/illustrations/signup_illustration.svg',
                    height: 100,
                  ),
                  const SizedBox(height: 30.0),

                  // Welcome Text
                  Text(
                    'Create Your Account',
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Username Field
                  _buildTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    icon: Icons.person,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16.0),

                  // Mobile Number Field
                  _buildTextField(
                    controller: _mobileNumberController,
                    labelText: 'Mobile Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16.0),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),

                  // Password Field
                  _buildPasswordField(),
                  const SizedBox(height: 24.0),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Replaced 'primary' with 'backgroundColor'
                        foregroundColor: Colors.black87, // Replaced 'onPrimary' with 'foregroundColor'
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black54),
                            )
                          : Text(
                              'Sign Up',
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
                  _buildErrorMessage(),
                  const SizedBox(height: 20.0),

                  // Sign In Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a member?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Decorative Bottom Element
                  const SizedBox(height: 15.0),
                  SvgPicture.asset(
                    'assets/illustrations/bottom_decor.svg',
                    width: screenSize.width * 0.5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields with icons
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
        textStyle: const TextStyle(color: Colors.white),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide:
              const BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide:
              const BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
    );
  }

  // Helper method to build password field with visibility toggle
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !isPasswordVisible, // Controls password visibility
      style: GoogleFonts.montserrat(
        textStyle: const TextStyle(color: Colors.black),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.black),
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide:
              const BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide:
              const BorderSide(color: Colors.black, width: 2.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible; // Toggle visibility
            });
          },
        ),
      ),
    );
  }
}