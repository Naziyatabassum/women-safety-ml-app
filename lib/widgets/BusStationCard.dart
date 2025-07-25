import 'package:flutter/material.dart';

class BusStationCard extends StatelessWidget {
  final VoidCallback onMapFunction;

  const BusStationCard({super.key, required this.onMapFunction});

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
              Icon(Icons.directions_bus, size: 30, color: Colors.green), // Set consistent size
              SizedBox(height: 5),
              Text('Bus Station', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
