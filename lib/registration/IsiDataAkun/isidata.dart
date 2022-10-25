// ignore_for_file: avoid_print, non_constant_identifier_names, deprecated_member_use, unnecessary_null_comparison, avoid_types_as_parameter_names, depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path/path.dart';
import '../../api/DatabaseServices.dart';
import '../../app/HalamanRumah/HalamanRumah.dart';

class IsiData extends StatefulWidget {
  const IsiData({Key? key}) : super(key: key);

  @override
  _IsiDataState createState() => _IsiDataState();
}

class _IsiDataState extends State<IsiData> {
  int currentstep = 0;

  TextEditingController nama = TextEditingController();
  TextEditingController Username = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController NomorTelepon = TextEditingController();
  TextEditingController Alamat = TextEditingController();
  String? tanggal, bulan, tahun;
  String? gender;

  String? genderr;

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              'upload : $percentage %',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return const SizedBox(
              width: 0,
              height: 0,
            );
          }
        },
      );

  String? imageUrl;
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final email = user!.email;

    bool isCompleted = false;

    var cekstep = [false, false, false, false, false, false, false, false];

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference Console = firestore.collection('Console');
    List<Step> getSteps() => [
          Step(
              state: currentstep > 0 ? StepState.complete : StepState.indexed,
              isActive: currentstep >= 0,
              title: const Text('Nama Klinik'),
              content: TextFormField(
                controller: nama,
              ),
              subtitle: const Text('Nama Klinik')),
          Step(
              state: currentstep > 1 ? StepState.complete : StepState.indexed,
              isActive: currentstep >= 1,
              title: const Text('Alamat Klinik'),
              content: TextFormField(
                controller: Alamat,
                keyboardType: TextInputType.streetAddress,
              ),
              subtitle: const Text('Nama Klinik')),
          Step(
            state: currentstep > 2 ? StepState.complete : StepState.indexed,
            isActive: currentstep >= 2,
            title: const Text('Username'),
            content: TextFormField(
              controller: Username,
              keyboardType: TextInputType.text,
            ),
            subtitle: const Text('Untuk Pemulihan Akun'),
          ),
          Step(
            state: currentstep > 3 ? StepState.complete : StepState.indexed,
            isActive: currentstep >= 3,
            title: const Text('Password'),
            content: TextFormField(
              controller: Password,
              keyboardType: TextInputType.text,
            ),
            subtitle: const Text('Untuk Pemulihan Akun'),
          ),
          Step(
            state: currentstep > 4 ? StepState.complete : StepState.indexed,
            isActive: currentstep >= 4,
            title: const Text('Nomor HP'),
            content: TextFormField(
              controller: NomorTelepon,
              keyboardType: TextInputType.phone,
            ),
          ),
          Step(
            state: currentstep > 5 ? StepState.complete : StepState.indexed,
            isActive: currentstep >= 5,
            title: const Text('Upload Foto'),
            content: Column(
              children: <Widget>[
                (imageUrl != null)
                    ? Card(
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Ink.image(
                                  image: NetworkImage(imageUrl!),
                                  height: MediaQuery.of(context).size.width,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        width: MediaQuery.of(context).size.width - 100,
                        height: MediaQuery.of(context).size.width - 100,
                        child: InkWell(
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 10, top: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Upload Foto',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'Tap Here',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87),
                                  ),
                                ],
                              )),
                          onTap: () {
                            uploadImage();
                          },
                        ),
                      ),
              ],
            ),
          ),
        ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Isi Data'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal.shade900,
      ),
      body: Theme(
        data: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: Colors.teal.shade900)),
        child: Stepper(
            type: StepperType.vertical,
            currentStep: currentstep,
            steps: getSteps(),
            onStepContinue: () {
              final isLastStep = currentstep == getSteps().length - 1;
              if (isLastStep) {
                isCompleted = true;
                print(isCompleted);
              } else {
                setState(() {
                  currentstep += 1;
                });
              }
            },
            onStepTapped: (step) => setState(() {
                  currentstep = step;
                }),
            onStepCancel: currentstep == 0
                ? null
                : () {
                    setState(() {
                      currentstep -= 1;
                    });
                  },
            controlsBuilder: (context, details) {
              final isLastStep = currentstep == getSteps().length - 1;
              return Container(
                margin: const EdgeInsets.only(top: 50),
                child: Row(
                  children: [

                    (isLastStep == true)
                        ? Expanded(
                            child:  StreamBuilder<DocumentSnapshot>(
                              stream: Console.doc('klinik').snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;

                                  int ID = data['BanyakKlinik'];

                                  ID += 10000000;

                                  return ElevatedButton(
                                    onPressed: () {
                                      DatabaseServices.updateakun(
                                        email,
                                        nama.text,
                                        ID.toString(),
                                        Alamat.text,
                                        Username.text,
                                        Password.text,
                                        DateTime.now().day,
                                        DateTime.now().month,
                                        DateTime.now().year,
                                        NomorTelepon.text,
                                        imageUrl.toString(),
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const HalamanRumah()),
                                      );
                                    },
                                    child: const Text('Konfirmasi'),
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          )
                        : (cekstep[currentstep] == false)
                            ? Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  child: const Text('lanjut'),
                                ),
                              )
                            : Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Kembali'),
                                ),
                              ),
                    const SizedBox(
                      width: 20,
                    ),
                    if (currentstep != 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Kembali'),
                        ),
                      ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  uploadImage() async {
    final storage = FirebaseStorage.instance;
    final picker = ImagePicker();
    PickedFile? image;

    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      image = await picker.getImage(source: ImageSource.gallery);

      var file = File(image!.path);

      final fileName = basename(file.path);
      final destination = 'userprofile/$fileName';

      if (image != null) {
        // Upload to Firebase
        var snapshot = await storage
            .ref()
            .child(destination)
            .putFile(file)
            .whenComplete(() => null);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Path Received');
      }
    } else {
      print('Grant Permissions and try again');
    }
  }
}
