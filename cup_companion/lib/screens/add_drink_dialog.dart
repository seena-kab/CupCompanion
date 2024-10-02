import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io'; // Needed for File on mobile platforms
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class AddDrinkDialog extends StatefulWidget {
  const AddDrinkDialog({super.key});

  @override
  _AddDrinkDialogState createState() => _AddDrinkDialogState();
}

class _AddDrinkDialogState extends State<AddDrinkDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  double price = 0.0;
  XFile? imageFile; // Changed to XFile?
  bool isAlcoholic = false; // New field to hold alcoholic status

  bool isLoading = false;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile; // Now using XFile
      });
    }
  }

  Future<void> addDrink() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for the drink.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Sign in anonymously if not already signed in
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      // Verify that the user is authenticated
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      // Proceed with uploading the image and adding the drink
      String imageUrl = await uploadImage(imageFile!);

      // Add the new drink to Firestore
      await FirebaseFirestore.instance.collection('drinks').add({
        'averageRating': 0,
        'description': description,
        'imageUrl': imageUrl,
        'name': name,
        'price': price,
        'isAlcoholic': isAlcoholic,
        'reviews': [],
      });

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop(); // Close the dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drink added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add drink: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> uploadImage(XFile image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child('drink_images/$fileName');

    UploadTask uploadTask;

    if (kIsWeb) {
      // For web platform
      Uint8List imageData = await image.readAsBytes();
      uploadTask = storageRef.putData(imageData);
    } else {
      // For mobile platforms (Android/iOS)
      File file = File(image.path);
      uploadTask = storageRef.putFile(file);
    }

    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add a New Drink',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Drink Image Picker
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        image: imageFile != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(imageFile!.path)
                                    : FileImage(File(imageFile!.path))
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageFile == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tap to add an image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name Field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Drink Name',
                      prefixIcon: Icon(Icons.local_drink),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the drink name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!.trim();
                    },
                  ),
                  const SizedBox(height: 15),
                  // Description Field
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!.trim();
                    },
                  ),
                  const SizedBox(height: 15),
                  // Price Field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      price = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 15),
                  // Alcoholic Status Field
                  // Using ToggleButtons for selection
                  Row(
                    children: [
                      const Text(
                        'Alcohol Content:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ToggleButtons(
                          isSelected: [!isAlcoholic, isAlcoholic],
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: Colors.white,
                          fillColor: Theme.of(context).primaryColor,
                          color: Colors.grey,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Non-Alcoholic'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Alcoholic'),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              isAlcoholic = index == 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        addDrink();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add Drink'),
            ),
          ],
        ),
        // Loading Indicator
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}