import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'Provider/RCTProvider.dart';
import 'UserView/LandingPage.dart';
import 'UserView/ManagementPage/HomePage.dart';
import 'firebase_options.dart';

String ENDPOINT = '';
String URL = '';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const LandingPage(),
          );
        } else if (settings.name != null && settings.name!.startsWith('/')) {
          String parameterFromUrl =
          settings.name!.substring(1); // Extracts the path segment

          // Update the global variables outside of setState
          ENDPOINT = parameterFromUrl;
          URL =
          'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/$ENDPOINT';

          // You can add custom logic based on the extracted segment
          if (parameterFromUrl.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => HomePage(),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => LandingPage(),
            );
          }
        }
        return null;
      },
    );
  }
}
