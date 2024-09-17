import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:cup_companion/services/auth_services.dart'; // Import AuthService for Firebase interactions

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  SurveyScreenState createState() => SurveyScreenState();
}

class SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Firebase AuthService instance
  final AuthService _authServices = AuthService();

  // Variables to hold the selected answers
  final List<String> _coffeeChoice = []; // Allow multiple selections for coffee
  String? _alcoholChoice;
  String? _coffeeFrequency;
  String? _alcoholFrequency;
  String? _dietaryPreference;
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _alcoholOtherController = TextEditingController();

  // List of questions to show the progress
  final List<String> _questions = [
    "What is your coffee of choice?",
    "What type of Alcohol do you prefer?",
    "How often do you order coffee?",
    "How often do you order Alcohol?",
    "Enter Zip Code to filter shops in your area",
    "Do you have any dietary preferences?",
  ];

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _pageController.dispose();
    _zipCodeController.dispose();
    _alcoholOtherController.dispose();
    super.dispose();
  }

  // Method to handle "Next" button
  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Handle form submission after the last question
      _submitSurvey();
    }
  }

  // Method to handle "Back" button
  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to submit the survey and save to Firebase using AuthServices
  Future<void> _submitSurvey() async {
    try {
      final userId = _authServices.auth.currentUser?.uid;

      if (userId != null) {
        // Data to be saved in Firebase
        final surveyData = {
          'coffeeChoice': _coffeeChoice,
          'alcoholChoice': _alcoholChoice ?? '',
          'alcoholOther': _alcoholOtherController.text,
          'coffeeFrequency': _coffeeFrequency ?? '',
          'alcoholFrequency': _alcoholFrequency ?? '',
          'dietaryPreference': _dietaryPreference ?? '',
          'zipCode': _zipCodeController.text.trim(),
        };

        // Save the survey data to Firebase under the user's ID using databaseRef getter
        await _authServices.databaseRef.child(userId).child('surveyData').set(surveyData);

        // Mark survey as completed using AuthServices
        await _authServices.completeSurvey(userId);

        // Log the data (for debugging, use log instead of print in production)
        developer.log("Survey Data Saved: $surveyData", name: 'Survey');

        // After saving, navigate to the home screen and pass data for personalization
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home', arguments: surveyData);
        }
      }
    } catch (e) {
      developer.log('Error submitting survey: $e', name: 'Survey');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting survey: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Exit survey
          },
        ),
        title: const Text('Survey'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _questions.length,
              minHeight: 5,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: Colors.amber,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                // Dynamically build each question page
                switch (index) {
                  case 0:
                    return _buildMultiSelectQuestion(
                      question: _questions[0],
                      options: ["Latte", "Espresso", "Black coffee", "Cappuccino", "Other"],
                      selectedValues: _coffeeChoice,
                      onChanged: (value) => setState(() {
                        if (_coffeeChoice.contains(value)) {
                          _coffeeChoice.remove(value);
                        } else {
                          _coffeeChoice.add(value);
                        }
                      }),
                    );
                  case 1:
                    return _buildSingleSelectQuestion(
                      question: _questions[1],
                      options: ["Seltzer", "Vodka", "Whiskey", "Tequila", "Rum", "Scotch"],
                      selectedValue: _alcoholChoice,
                      onChanged: (value) => setState(() {
                        _alcoholChoice = value;
                      }),
                      showOtherField: true,
                      otherController: _alcoholOtherController,
                    );
                  case 2:
                    return _buildSingleSelectQuestion(
                      question: _questions[2],
                      options: ["Very often", "Often", "Sometimes", "Rarely", "Never"],
                      selectedValue: _coffeeFrequency,
                      onChanged: (value) => setState(() {
                        _coffeeFrequency = value;
                      }),
                    );
                  case 3:
                    return _buildSingleSelectQuestion(
                      question: _questions[3],
                      options: ["Very often", "Often", "Sometimes", "Rarely", "Never"],
                      selectedValue: _alcoholFrequency,
                      onChanged: (value) => setState(() {
                        _alcoholFrequency = value;
                      }),
                    );
                  case 4:
                    return _buildZipCodeQuestion();
                  case 5:
                    return _buildSingleSelectQuestion(
                      question: _questions[5],
                      options: ["Vegan", "Vegetarian", "Gluten-Free", "None"],
                      selectedValue: _dietaryPreference,
                      onChanged: (value) => setState(() {
                        _dietaryPreference = value;
                      }),
                    );
                  default:
                    return const SizedBox(); // Handle unexpected cases
                }
              },
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (only visible if not on the first page)
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _prevPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                // Next or Submit button
                ElevatedButton(
                  onPressed: _currentPage == _questions.length - 1 ? _submitSurvey : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  ),
                  child: _currentPage == _questions.length - 1
                      ? const Text('Submit', style: TextStyle(color: Colors.white))
                      : const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for multiple selections (checkboxes)
  Widget _buildMultiSelectQuestion({
    required String question,
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          for (var option in options)
            CheckboxListTile(
              title: Text(option),
              value: selectedValues.contains(option),
              onChanged: (bool? value) {
                onChanged(option);
              },
            ),
        ],
      ),
    );
  }

  // Widget for single selections (radio buttons)
  Widget _buildSingleSelectQuestion({
    required String question,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool showOtherField = false,
    TextEditingController? otherController,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          for (var option in options)
            RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
          if (showOtherField)
            TextField(
              controller: otherController,
              decoration: const InputDecoration(
                labelText: "Other",
                border: OutlineInputBorder(),
              ),
            ),
        ],
      ),
    );
  }

  // Widget for Zip Code input
  Widget _buildZipCodeQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Enter Zip Code to filter shops in your area",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _zipCodeController,
            decoration: const InputDecoration(
              labelText: 'Enter Zip code',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}