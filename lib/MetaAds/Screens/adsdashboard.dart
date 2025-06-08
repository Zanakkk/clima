import 'package:flutter/material.dart';

import 'CampaignScreens.dart';
import 'addashboard.dart';
import 'analitic screen.dart';
import 'clinicsetup.dart';
import 'targeting screen.dart';

class AdsDashboard extends StatefulWidget {
  const AdsDashboard({super.key});

  @override
  State<AdsDashboard> createState() => _AdsDashboardState();
}

class _AdsDashboardState extends State<AdsDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdsDashboardScreen(
                              clinicId: '',
                            )));
              },
              child: const Text('ads dashboard')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClinicSetupScreen()));
              },
              child: const Text('Clinic Setup')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(
                              clinicId: '',
                            )));
              },
              child: const Text('Analitic Screen')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TargetingScreen()));
              },
              child: const Text('Targeting Screen')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CampaignScreen(
                              clinicId: '',
                            )));
              },
              child: const Text('Campaign Screen')),
        ],
      ),
    );
  }
}
