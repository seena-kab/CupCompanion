import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cup Companion'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference _nameRef;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      _nameRef = FirebaseDatabase.instance.reference().child('names');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter your name:',
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveName();
        },
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveName() {
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      _nameRef.push().set({'name': name}).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Name saved successfully!'),
        ));
        _nameController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save name: $error'),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a name!'),
      ));
    }
  }
}
