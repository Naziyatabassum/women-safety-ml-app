import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For periodic updates
import 'package:percent_indicator/percent_indicator.dart';

class RiskPage extends StatefulWidget {
  const RiskPage({super.key});

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> {
  Position? _currentPosition;
  double _riskPercentage = 0.0; // Store risk percentage as a double
  Timer? _timer; // Timer for periodic location updates

  // Method to get the current location
  Future<void> _getCurrentLocation() async {
    print('Getting location permissions...');
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return Future.error('Location permissions are denied');
    }

    try {
      print('Fetching current location...');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      print(
          'Current position: ${position.latitude}, ${position.longitude}'); // Debug: Print the current position
      _fetchRiskPercentage(position.latitude,
          position.longitude); // Fetch the risk percentage from API
    } catch (e) {
      print('Error occurred while getting location: $e');
    }
  }

  // Method to call Flask API and get the risk percentage
  Future<void> _fetchRiskPercentage(double latitude, double longitude) async {
    try {
      print('Sending request to Flask API...');
      final response = await http.post(
        Uri.parse(
            'http://172.19.25.214:5000/predict_risk'), // Replace with actual Flask API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response body: $data'); // Debug: Print the response body
        setState(() {
          _riskPercentage = (data['risk_percentage'] / 100); // Convert to 0-1 range
        });
        print(
            'Risk percentage: $_riskPercentage'); // Debug: Print the received risk percentage
      } else {
        print(
            'Error: ${response.statusCode} - ${response.body}'); // Log error details
        setState(() {
          _riskPercentage = 0.0; // Set 0.0 on error
        });
      }
    } catch (e) {
      print('Error during API call: $e');
      setState(() {
        _riskPercentage = 0.0; // Set 0.0 on error
      });
    }
  }

  // Method to start periodic location updates
  void _startLocationUpdates() {
    const updateInterval = Duration(seconds: 10); // Update every 10 seconds
    _timer = Timer.periodic(updateInterval, (timer) {
      _getCurrentLocation(); // Fetch new location and update risk percentage
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch location when the screen loads
    _startLocationUpdates(); // Start periodic location updates
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Page'),
      ),
      body: Center(
        child: _currentPosition == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  // Circular progress indicator for risk percentage
                  CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 13.0,
                    percent: _riskPercentage, // Display percentage as 0-1 value
                    center: Text(
                      "${(_riskPercentage * 100).toStringAsFixed(1)}%", // Show percentage as a string
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: _getRiskColor(_riskPercentage),
                    backgroundColor: Colors.grey[300]!,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Risk Percentage: ${(_riskPercentage * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }

  // Method to change the color of the circle based on risk percentage
  Color _getRiskColor(double percentage) {
    if (percentage < 0.33) {
      return Colors.green;
    } else if (percentage < 0.66) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
