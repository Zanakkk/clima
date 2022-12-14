// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../api/AuthServices.dart';
import '../../app/HalamanRumah/HalamanRumah.dart';
import 'isidata.dart';

class RegisEmailScreen extends StatefulWidget {
  const RegisEmailScreen({Key? key}) : super(key: key);

  @override
  _RegisEmailScreenState createState() => _RegisEmailScreenState();
}

class _RegisEmailScreenState extends State<RegisEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            minimumSize: Size(((MediaQuery.of(context).size.width) - 100), 48),
            elevation: 20,

            backgroundColor: Colors.black, // background (button) color
            foregroundColor: Colors.white, // foreground (text) color
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.black,
          ),
          body: Container(
              color: Colors.black,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: (MediaQuery.of(context).size.height -
                                      MediaQuery.of(context).size.width) /
                                  3),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Image.asset(
                              'assets/onboard/Halaman3.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          StreamBuilder(
                              stream: FirebaseAuth.instance.authStateChanges(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  return Builder(
                                    builder: (context) {
                                      final GlobalKey<SlideActionState> key =
                                          GlobalKey();
                                      return Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SlideAction(
                                          outerColor: Colors.teal.shade900,
                                          innerColor: Colors.white,
                                          key: key,
                                          text: 'Lanjut ke Aplikasi',
                                          textStyle: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                          onSubmit: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return const IsiData();
                                            }));
                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () => key.currentState?.reset(),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return ElevatedButton(
                                      onPressed: () {
                                        AuthServices.signInWithGoogle();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HalamanRumah()));
                                      },
                                      child: const Text('Masuk dengan Akun Google'));
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}
