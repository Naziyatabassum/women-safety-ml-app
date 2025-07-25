import 'package:url_launcher/url_launcher.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'relative_entry_page.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  bool _shakeDetected = false;
  DateTime? _lastShakeTime;
  int shakeCount = 0;
  bool _isCallingInProgress = false;
  Timer? _callTimer;
  Timer? _sequenceTimer;
  BuildContext? _context;

  void initialize(BuildContext context) {
    _context = context;
    _initShakeDetection(context);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.sms.request();
    await Permission.location.request();
    await Permission.phone.request();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _initShakeDetection(BuildContext context) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > 12 || event.y.abs() > 12 || event.z.abs() > 12) {
        final now = DateTime.now();

        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(milliseconds: 500)) {
          _lastShakeTime = now;
          shakeCount++;

          if (shakeCount >= 3) {
            triggerEmergency(context);
            shakeCount = 0;
          }
        }
      }
    });
  }

  Future<void> triggerEmergency(BuildContext context) async {
    if (!_shakeDetected && RelativeEntryPage.relatives.isNotEmpty) {
      _shakeDetected = true;
      _isCallingInProgress = false;

      try {
        final locationUrl = await _getCurrentLocation();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency sequence initiated!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Send messages to all contacts first
        await _sendEmergencyMessages(
          RelativeEntryPage.relatives,
          'EMERGENCY! I need help! My location: $locationUrl',
          context,
        );

        // Start sequential calling process
        await _startSequentialCalls(context);

      } catch (e) {
        debugPrint('Emergency sequence error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        Future.delayed(const Duration(seconds: 5), () {
          _shakeDetected = false;
        });
      }
    }
  }

  Future<String> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location access denied';
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return 'http://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Location error: $e');
      return 'Location unavailable';
    }
  }

  Future<void> _sendEmergencyMessages(
      List<Map<String, String>> contacts, String message, BuildContext context) async {
    for (var contact in contacts) {
      try {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: contact['phone'],
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          await Future.delayed(const Duration(milliseconds: 500));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Message sent to ${contact['name']}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('SMS error for ${contact['name']}: $e');
      }
    }
  }

  Future<void> _startSequentialCalls(BuildContext context) async {
    if (_isCallingInProgress) return;
    _isCallingInProgress = true;

    int currentIndex = 0;

    Future<void> callNextContact() async {
      if (currentIndex >= RelativeEntryPage.relatives.length || !_isCallingInProgress) {
        _isCallingInProgress = false;
        _callTimer?.cancel();
        _sequenceTimer?.cancel();
        return;
      }

      final contact = RelativeEntryPage.relatives[currentIndex];

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling ${contact['name']}...'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Start call timeout timer
      _callTimer?.cancel();
      _callTimer = Timer(const Duration(seconds: 5), () {
        debugPrint('Call timeout for ${contact['name']}');
        currentIndex++;
        callNextContact();
      });

      try {
        // Using await on makeCall to properly handle the result
        bool success = await _makeCall(contact['phone']!, context);

        if (success) {
          _callTimer?.cancel();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected with ${contact['name']}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          // Wait before moving to next contact
          _sequenceTimer = Timer(const Duration(seconds: 5), () {
            currentIndex++;
            callNextContact();
          });
        } else {
          debugPrint('Call failed for ${contact['name']}');
          currentIndex++;
          callNextContact();
        }
      } catch (e) {
        debugPrint('Call error for ${contact['name']}: $e');
        currentIndex++;
        callNextContact();
      }
    }

    // Start the sequential calling process
    await callNextContact();
  }

  Future<bool> _makeCall(String phoneNumber, BuildContext context) async {
    try {
      // Handle the nullable boolean return type properly
      bool? result = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      return result ?? false;  // Return false if result is null
    } catch (e) {
      debugPrint('Direct call error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  void dispose() {
    _isCallingInProgress = false;
    _callTimer?.cancel();
    _sequenceTimer?.cancel();
    _shakeDetected = false;
  }
}