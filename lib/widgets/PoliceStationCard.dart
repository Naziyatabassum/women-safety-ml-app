import 'package:flutter/material.dart';

class PoliceStationCard extends StatelessWidget {
  final VoidCallback onMapFunction;

  const PoliceStationCard({super.key, required this.onMapFunction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMapFunction,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_police, size: 30, color: Colors.blue), // Set consistent size
              SizedBox(height: 5),
              Text('Police', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
