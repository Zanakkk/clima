// ignore_for_file: file_names, non_constant_identifier_names

import 'package:clima/api/DatabaseServices.dart';
import 'package:clima/app/HalamanRumah/HalamanRumah.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataMedikPasien extends StatefulWidget {
  const DataMedikPasien(this.IDRekamMedis, {Key? key}) : super(key: key);
  final int IDRekamMedis;
  @override
  State<DataMedikPasien> createState() => _DataMedikPasienState();
}

class _DataMedikPasienState extends State<DataMedikPasien> {
  TextEditingController Nama = TextEditingController();
  TextEditingController TekananDarah = TextEditingController();
  TextEditingController Alamat = TextEditingController();
  TextEditingController Pekerjaan = TextEditingController();
  TextEditingController NoTelepon = TextEditingController();

  String? _valuegoldar = 'pilih';
  bool _switchJantung = false;
  bool _switchDiabetes = false;
  bool _switchHepatitis = false;
  bool _switchPenyakitLainnya = false;
  bool _switchAlergiObat = false;
  bool _switchAlergiMakanan = false;

  TextEditingController PenyakitLainnya = TextEditingController();
  TextEditingController AlergiObat = TextEditingController();
  TextEditingController AlergiMakanan = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final email = user!.email;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Medik Pasien'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: ListView(
                padding: const EdgeInsets.only(top: 12),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Golongan Darah : ',
                        textAlign: TextAlign.left,
                      ),
                      DropdownButton(
                          value: _valuegoldar,
                          elevation: 10,
                          items: const [
                            DropdownMenuItem(
                              value: 'pilih',
                              child: Text("pilih"),
                            ),
                            DropdownMenuItem(
                              value: 'A',
                              child: Text("A"),
                            ),
                            DropdownMenuItem(
                              value: 'B',
                              child: Text("B"),
                            ),
                            DropdownMenuItem(
                              value: 'AB',
                              child: Text("AB"),
                            ),
                            DropdownMenuItem(
                              value: 'O',
                              child: Text("O"),
                            ),
                          ],
                          onChanged: (dynamic value) {
                            setState(() {
                              _valuegoldar = value;
                            });
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penyakit Jantung : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchJantung,
                        onChanged: (value) {
                          setState(() {
                            _switchJantung = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penyakit Diabetes : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchDiabetes,
                        onChanged: (value) {
                          setState(() {
                            _switchDiabetes = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penyakit Hepatitis : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchHepatitis,
                        onChanged: (value) {
                          setState(() {
                            _switchHepatitis = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penyakit Lainnya : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchPenyakitLainnya,
                        onChanged: (value) {
                          setState(() {
                            _switchPenyakitLainnya = value;
                          });
                        },
                      ),
                    ],
                  ),
                  (_switchPenyakitLainnya == true)
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: TextFormField(
                            controller: AlergiObat,
                            maxLines: 1,
                            decoration: InputDecoration(
                              focusColor: Colors.white,

                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.grey,

                              hintText: "Penyakit Lainnya",

                              //make hint text
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),

                              //create lable
                              labelText: "Penyakit Lainnya",
                              //lable style
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alergi Obat : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchAlergiObat,
                        onChanged: (value) {
                          setState(() {
                            _switchAlergiObat = value;
                          });
                        },
                      ),
                    ],
                  ),
                  (_switchAlergiObat == true)
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: TextFormField(
                            controller: AlergiObat,
                            maxLines: 1,
                            decoration: InputDecoration(
                              focusColor: Colors.white,

                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.grey,

                              hintText: "Alergi Obat",

                              //make hint text
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),

                              //create lable
                              labelText: "Alergi Obat",
                              //lable style
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alergi Makanan : ',
                        textAlign: TextAlign.left,
                      ),
                      CupertinoSwitch(
                        value: _switchAlergiMakanan,
                        onChanged: (value) {
                          setState(() {
                            _switchAlergiMakanan = value;
                          });
                        },
                      ),
                    ],
                  ),
                  (_switchAlergiMakanan == true)
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: TextFormField(
                            controller: AlergiMakanan,
                            maxLines: 1,
                            decoration: InputDecoration(
                              focusColor: Colors.white,

                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.grey,

                              hintText: "Alergi Makanan",

                              //make hint text
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),

                              //create lable
                              labelText: "Alergi Makanan",
                              //lable style
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      minimumSize: Size(
                          ((MediaQuery.of(context).size.width - 48) / 2), 36),
                      elevation: 2,

                      backgroundColor:
                          Colors.white, // background (button) color
                      foregroundColor: Colors.black, // foreground (text) color
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Kembali')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      minimumSize: Size(
                          ((MediaQuery.of(context).size.width - 48) / 2), 36),
                      elevation: 2,

                      backgroundColor:
                          Colors.black, // background (button) color
                      foregroundColor: Colors.white, // foreground (text) color
                    ),
                    onPressed: () {
                      DatabaseServices.DataMedikPasien(
                          email!,
                          widget.IDRekamMedis.toString(),
                          _valuegoldar.toString(),
                          _switchJantung,
                          _switchDiabetes,
                          _switchHepatitis,
                          _switchPenyakitLainnya,
                          PenyakitLainnya.text,
                          _switchAlergiObat,
                          AlergiObat.text,
                          _switchAlergiMakanan,
                          AlergiMakanan.text,
                          1);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HalamanRumah()));
                    },
                    child: const Text('Lanjut')),
              ],
            ),
          ],
        ));
  }
}
