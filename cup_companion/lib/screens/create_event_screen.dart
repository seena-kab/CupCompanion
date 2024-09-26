import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDrink;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function to save event to Firestore
  Future<void> _saveEventToFirestore() async {
    try {
      // Combine the selected date and time into a single DateTime object
      final DateTime eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Save event to Firestore
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': eventDateTime,
        'drinkOption': _selectedDrink,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Created Successfully!')),
      );

      // You can navigate back or clear the form after successful creation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description Input
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date Picker
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Date'
                    : 'Selected Date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Time Picker
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Select Time'
                    : 'Selected Time: ${_selectedTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),

              // Drink Options
              const Text('Are you getting Coffee, Tea, or Drinks?'),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedDrink,
                hint: const Text('Select Option'),
                items: ['Coffee', 'Tea', 'Drinks']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDrink = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Create Event Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDate == null ||
                        _selectedTime == null ||
                        _selectedDrink == null ||
                        _titleController.text.isEmpty ||
                        _descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all the fields'),
                        ),
                      );
                    } else {
                      _saveEventToFirestore();
                    }
                  },
                  child: const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
