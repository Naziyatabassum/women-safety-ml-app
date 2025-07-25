import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  final VoidCallback onMapFunction;

  const HospitalCard({super.key, required this.onMapFunction});

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
              Icon(Icons.local_hospital, size: 30, color: Colors.red), // Set consistent size
              SizedBox(height: 5),
              Text('Hospital', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
