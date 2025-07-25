import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/BusStationCard.dart';
import 'widgets/HospitalCard.dart';
import 'widgets/PoliceStationCard.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  static Future<void> openMap(String location) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';

    if (await canLaunch(googleUrl)) {
      await launchUrl(Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(
        msg: 'Could not launch $googleUrl. Please check your connection.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PoliceStationCard(onMapFunction: () => openMap("Police Station")),
            const SizedBox(width: 10), // Add some spacing between icons
            HospitalCard(onMapFunction: () => openMap("Hospital")),
            const SizedBox(width: 10), // Add some spacing between icons
            BusStationCard(onMapFunction: () => openMap("Bus Station")),
          ],
        ),
      ),
    );
  }
}
