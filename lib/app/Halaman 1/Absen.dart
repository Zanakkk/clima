// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../HalamanRumah/HalamanRumah.dart';

class Absen extends StatefulWidget {
  const Absen({Key? key}) : super(key: key);

  @override
  State<Absen> createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  bool _switchLainlain = false;
  TextEditingController NamaAsop = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            minimumSize:
                Size(((MediaQuery.of(context).size.width - 48) / 2), 36),
            elevation: 20,

            backgroundColor: Colors.black, // background (button) color
            foregroundColor: Colors.white, // foreground (text) color
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        appBar: AppBar(
          title: const Text('Absen'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: Container(
            color: Colors.grey.shade50,
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bubun'),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Absen')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Natasha'),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Absen')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Neta'),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Absen')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Eca'),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Absen')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lain - Lain : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchLainlain,
                        onChanged: (value) {
                          setState(() {
                            _switchLainlain = value;
                          });
                        },
                      ),
                    ],
                  ),
                  (_switchLainlain == true)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: TextFormField(
                                    controller: NamaAsop,
                                    decoration: InputDecoration(
                                      focusColor: Colors.white,

                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.blue, width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.grey,

                                      hintText: "Saya Yakin",

                                      //make hint text
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),

                                      //create lable
                                      labelText: "Saya Yakin",
                                      //lable style
                                      labelStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const HalamanRumah();
                                        }));
                                      },
                                      child: const Text(
                                        'Kirim',
                                      ))),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ))),
      ),
    );
  }
}
