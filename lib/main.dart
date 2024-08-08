// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'Provider/RCTProvider.dart';
import 'UserView/LandingPage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => RCTProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tambahkan baris ini
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const LandingPage(),
          );
        } else if (settings.name != null && settings.name!.startsWith('/')) {
          String parameterFromUrl = settings.name!.substring(1);
          // Output: displayhealth/iDent

          String displaymana = '';
          List<String> parts = parameterFromUrl.split('/');
          if (parts.length > 1) {
            displaymana = parts[0]; // Mengambil bagian pertama dari array parts
            // Output: Display Mana: displayhealth

            // Selanjutnya, Anda bisa melakukan apa yang perlu dilakukan dengan displaymana ini.
          }

          if (displaymana == 'display') {
            return MaterialPageRoute(
              builder: (context) => Container(),
            );
          } else if (displaymana == 'displayhealth') {
            return MaterialPageRoute(
              builder: (context) => Container(),
            );
          } else
            return MaterialPageRoute(
              builder: (context) => Container(),
            );
        }
        return null;
      },
    );
  }
}
