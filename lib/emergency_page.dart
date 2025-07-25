import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  // List of emergency contacts with name and phone number
  final List<Map<String, String>> emergencyContacts = [
    {'name': 'Police Station', 'phone': '100'},
    {'name': 'Hospital', 'phone': '102'},
    {'name': 'Fire Brigade', 'phone': '101'},
    {'name': 'Women’s Helpline', 'phone': '1091'},
    {'name': 'Ambulance', 'phone': '108'},
    {'name': 'Bus Stand Helpline', 'phone': '1800-XYZ-XYZ'},
  ];

  EmergencyPage({super.key});

  // Function to launch the dialer with a phone number
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView.builder(
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return ListTile(
            leading: const Icon(Icons.phone, color: Colors.red),
            title: Text(contact['name']!),
            subtitle: Text(contact['phone']!),
            onTap: () => _makePhoneCall(contact['phone']!), // Dial on tap
          );
        },
      ),
    );
  }
}