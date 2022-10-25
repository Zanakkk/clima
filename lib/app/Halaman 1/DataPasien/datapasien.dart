// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:clima/api/DatabaseServices.dart';
import 'package:clima/app/Halaman%201/DataPasien/DataMedikPasien.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class InputDataPasien extends StatefulWidget {
  const InputDataPasien({Key? key}) : super(key: key);

  @override
  State<InputDataPasien> createState() => _InputDataPasienState();
}

class _InputDataPasienState extends State<InputDataPasien> {
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
          title: const Text('Data Pasien'),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: DateTimePicker(
                      type: DateTimePickerType.date,
                      dateMask: 'd MMM, yyyy',
                      initialValue: DateTime.now().toString(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      icon: const Icon(Icons.event),
                      dateLabelText: 'Tanggal Lahir',
                      selectableDayPredicate: (date) {
                        // Disable weekend days to select from the calendar

                        tanggal = date.day;
                        bulan = date.month;
                        tahun = date.year;
                        return true;
                      },
                      validator: (val) {
                        return null;
                      },
                      onSaved: (val) => print(val),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextFormField(
                      controller: TempatLahir,
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

                        hintText: "Tempat Lahir",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Tempat Lahir",
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
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextFormField(
                      controller: Pekerjaan,
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

                        hintText: "Pekerjaan",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Pekerjaan",
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
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextFormField(
                      controller: Alamat,
                      maxLines: 2,
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

                        hintText: "Alamat",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Alamat",
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
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextFormField(
                      controller: NoTelepon,
                      maxLines: 1,

                      keyboardType: TextInputType.phone,

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

                        hintText: "No Telepon / WA",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "No Telepon / WA",
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

                          backgroundColor:
                              Colors.black, // background (button) color
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
}
