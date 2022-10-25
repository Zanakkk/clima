// ignore_for_file: non_constant_identifier_names, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'HalamanPerawatan.dart';

class Perawatan extends StatefulWidget {
  const Perawatan({Key? key}) : super(key: key);

  @override
  State<Perawatan> createState() => _PerawatanState();
}

class _PerawatanState extends State<Perawatan> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference Klinik = firestore.collection('Klinik');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final email = user!.email;

    return ListView(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: Klinik.doc(email)
              .collection('RekamMedis')
              .where("Done", isNotEqualTo: true)
              .snapshots(),
          builder: (_, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Column(
                  children: snapshot.data.docs
                      .map<Widget>((e) => KerjaCard(
                            e.data()['IDRM'],
                            e.data()['Nama'],
                            e.data()['perawatan'],
                          ))
                      .toList());
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Center(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget KerjaCard(
    String noRM,
    String nama,
    int perawatanno,
  ) =>
      Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      nama,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    Text(noRM.toString()),
                  ],
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      minimumSize:
                          Size(((MediaQuery.of(context).size.width) / 3), 36),
                      elevation: 20,

                      backgroundColor:
                          Colors.black, // background (button) color
                      foregroundColor: Colors.white, // foreground (text) color
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HalamanPerawatan(noRM, perawatanno)));
                    },
                    child: const Text('Kerja')),
              ],
            ),
          ));
}
