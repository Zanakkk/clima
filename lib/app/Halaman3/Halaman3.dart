// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../registration/IsiDataAkun/isidata.dart';

class Tab3 extends StatefulWidget {
  const Tab3({Key? key}) : super(key: key);

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference Klinik = firestore.collection('Klinik');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final emaila = user!.email;

    return Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Akun',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),

                      // ignore: deprecated_member_use
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => IsiData()),
                            );
                          },
                          child: Text('Edit')),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'email: ',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300, fontSize: 16),
                        ),
                        Text(
                          emaila.toString(),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: Klinik.doc(emaila.toString()).snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        String Nama = data['Nama'];
                        String noHP = data['NomorTelepon'];

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nama :  ',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    Nama,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'nomor HP: ',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    noHP,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )));
  }
}
