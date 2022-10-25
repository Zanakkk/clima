import 'package:flutter/material.dart';

import 'package:clima/api/DatabaseServices.dart';
import 'package:clima/app/Halaman%201/DataPasien/DataMedikPasien.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasienLama extends StatefulWidget {
  const PasienLama({Key? key}) : super(key: key);

  @override
  State<PasienLama> createState() => _PasienLamaState();
}

class _PasienLamaState extends State<PasienLama> {
  @override
  TextEditingController Nama = TextEditingController();
  TextEditingController TempatLahir = TextEditingController();
  TextEditingController Alamat = TextEditingController();
  TextEditingController Pekerjaan = TextEditingController();
  TextEditingController NoTelepon = TextEditingController();

  late int tanggal, bulan, tahun;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference Klinik = firestore.collection('Klinik');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final email = user!.email;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pasien Lama'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: ListView(
                padding: const EdgeInsets.only(top: 12),
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextFormField(
                      controller: Nama,
                      maxLines: 1,
                      decoration: InputDecoration(
                        focusColor: Colors.white,

                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.grey,

                        hintText: "Nama",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Nama",
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
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        Klinik.doc(email).collection('RekamMedis').snapshots(),
                    builder: (_, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                            children: snapshot.data.docs
                                .map<Widget>((e) => SubmitButtonR(
                                      Nama.text,
                                      e.data()['Nama'],
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
                  Divider(
                    height: 12,
                    thickness: 12,
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: StreamBuilder<DocumentSnapshot>(
                stream: Klinik.doc(email.toString())
                    .collection('Console')
                    .doc('Console')
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;

                    int IDRekamMedis = data['RekamMedis'];

                    IDRekamMedis += 10000000;

                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          minimumSize: Size(
                              ((MediaQuery.of(context).size.width - 96)), 36),
                          elevation: 2,

                          backgroundColor: Colors.black,
                          // background (button) color
                          foregroundColor:
                              Colors.white, // foreground (text) color
                        ),
                        onPressed: () {
                          DatabaseServices.incremetnRekamMedis(
                            email!,
                            IDRekamMedis.toString(),
                          );
                          DatabaseServices.RegistrasiPasien(
                            email,
                            IDRekamMedis.toString(),
                            Nama.text,
                            tanggal,
                            bulan,
                            tahun,
                            TempatLahir.text,
                            Pekerjaan.text,
                            Alamat.text,
                            NoTelepon.text,
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DataMedikPasien(IDRekamMedis)));
                        },
                        child: const Text('Lanjut'));
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            )
          ],
        ));
  }

  Widget SubmitButtonR(
    String controllernama,
    String nama,
  ) =>
      (controllernama == nama)
          ? ElevatedButton(
              onPressed: () {},
              child: Text('Cek'),
            )
          : Container();
}
