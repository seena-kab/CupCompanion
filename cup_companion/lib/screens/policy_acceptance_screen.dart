// lib/screens/policy_acceptance_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cup_companion/l10n/app_localizations.dart'; // For localization
import 'package:flutter_svg/flutter_svg.dart'; // For SVG illustrations
import 'package:google_fonts/google_fonts.dart'; // For Google Fonts

class PolicyAcceptanceScreen extends StatefulWidget {
  const PolicyAcceptanceScreen({super.key});

  @override
  _PolicyAcceptanceScreenState createState() => _PolicyAcceptanceScreenState();
}

class _PolicyAcceptanceScreenState extends State<PolicyAcceptanceScreen> {
  bool _isLoading = false;

  Future<void> _acceptPolicy() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('policyAccepted', true);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _declinePolicy() {
    // Handle the decline action as needed
    // For now, we will still route to the home page
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!; // For localization

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFC3A0), Color(0xFFFDF3E7)], // Same gradient as SignInScreen
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Playful SVG Illustration
                SvgPicture.asset(
                  'assets/illustrations/privacy_policy_illustration.svg', // Use a relevant SVG illustration
                  height: 200,
                ),
                const SizedBox(height: 30.0),

                // Title Text
                Text(
                  appLocalizations.privacyPolicy,
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Privacy Policy Content
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    appLocalizations.privacyPolicyContent,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // Accept and Decline Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decline Button
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _declinePolicy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          appLocalizations.decline,
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    // Accept Button
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _acceptPolicy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                appLocalizations.accept,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}