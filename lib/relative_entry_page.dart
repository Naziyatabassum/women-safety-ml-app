import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RelativeEntryPage extends StatefulWidget {
  // Move the static list here
  static final List<Map<String, String>> relatives = [];

  const RelativeEntryPage({super.key});

  @override
  State<RelativeEntryPage> createState() => _RelativeEntryPageState();
}

class _RelativeEntryPageState extends State<RelativeEntryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _storeDataInFirebase() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty) {
      try {
        // Storing data in Firebase Firestore
        await FirebaseFirestore.instance.collection('Store Data').add({
          'name': name,
          'phone': phone,
        });

        // Add to the static list
        RelativeEntryPage.relatives.add({'name': name, 'phone': phone});

        // Update the UI
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relative added successfully')),
        );
        _nameController.clear();
        _phoneController.clear();
      } catch (e) {
        debugPrint('Error storing data: $e'); // Print error details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add relative')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Relative"),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _storeDataInFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                ),
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
