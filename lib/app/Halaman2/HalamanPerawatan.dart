// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously, avoid_print, depend_on_referenced_packages

import 'dart:typed_data';

import 'package:clima/app/HalamanRumah/HalamanRumah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/DatabaseServices.dart';

class HalamanPerawatan extends StatefulWidget {
  const HalamanPerawatan(this.noRM, this.perawatanno, {Key? key})
      : super(key: key);
  final String noRM;
  final int perawatanno;

  @override
  State<HalamanPerawatan> createState() => _HalamanPerawatanState();
}

class _HalamanPerawatanState extends State<HalamanPerawatan> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
  );

  TextEditingController Keluhan = TextEditingController();
  TextEditingController Perawatan = TextEditingController();
  TextEditingController Biaya = TextEditingController();
  TextEditingController Namadrg = TextEditingController();

  TextEditingController Nama = TextEditingController();
  TextEditingController TempatLahir = TextEditingController();
  TextEditingController Alamat = TextEditingController();
  TextEditingController Pekerjaan = TextEditingController();
  TextEditingController NoTelepon = TextEditingController();

  bool submit = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  uploadImage(String email) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    PickedFile? image;

    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image

      var image = await _controller.toImage();

      Uint8List? data = await _controller.toPngBytes();
      Uint8List? listData = data!.buffer.asUint8List();

      final FirebaseStorage storage = FirebaseStorage.instance;
      final String picture =
          "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      var snapshot =
          await storage.ref().child('$email/ttd/$picture').putData(listData);

      var downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl;
      });
    }
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No content')));
      return;
    }

    final Uint8List? data = await _controller.toPngBytes();
    if (data == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.yellow,
                child: Image.memory(data),
              ),
            ),
          );
        },
      ),
    );
  }

  String? imageUrl;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference Klinik = firestore.collection('Klinik');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final email = user!.email;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Perawatan'),
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
                      controller: Keluhan,
                      maxLines: 3,
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

                        hintText: "Keluhan",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Keluhan",
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
                      controller: Perawatan,
                      maxLines: 3,
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

                        hintText: "Perawatan",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Perawatan",
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
                      controller: Biaya,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
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

                        hintText: "Biaya",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Biaya",
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
                      controller: Namadrg,
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

                        hintText: "Nama Dokter Gigi",

                        //make hint text
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: "Nama Dokter Gigi",
                        prefixText: 'drg ',
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
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Container(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Signature(
                                controller: _controller,
                                height: MediaQuery.of(context).size.width,
                                width: MediaQuery.of(context).size.width,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Colors.black),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() => _controller.redo());
                                  },
                                  child: Text('Submit')),
                              //CLEAR CANVAS
                              IconButton(
                                icon: const Icon(Icons.clear),
                                color: Colors.blue,
                                onPressed: () {
                                  setState(() => _controller.clear());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            (_controller.isEmpty != true)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: Klinik.doc(email.toString())
                          .collection('Console')
                          .doc('Console')
                          .snapshots(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                alignment: Alignment.center,
                                minimumSize: Size(
                                    ((MediaQuery.of(context).size.width - 96)),
                                    36),
                                elevation: 2,

                                backgroundColor:
                                    Colors.black, // background (button) color
                                foregroundColor:
                                    Colors.white, // foreground (text) color
                              ),
                              onPressed: () {
                                uploadImage(email!);
                                DatabaseServices.PerawatanPasien(
                                    email,
                                    widget.noRM,
                                    widget.perawatanno,
                                    Keluhan.text,
                                    Perawatan.text,
                                    int.tryParse(Biaya.text)!,
                                    Namadrg.text,
                                    imageUrl!);

                                DatabaseServices.incrementPerawatanPasien(
                                  email,
                                  widget.noRM,
                                  widget.perawatanno,
                                );
                                DatabaseServices.perawatansetdone(
                                  email,
                                  widget.noRM,
                                  widget.perawatanno,
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HalamanRumah()));
                              },
                              child: const Text('Lanjut'));
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ));
  }
}
