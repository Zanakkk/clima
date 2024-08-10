// ignore_for_file: file_names, non_constant_identifier_names, equal_keys_in_map

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static CollectionReference userdata = firestore.collection('user');
  static CollectionReference RSGM = firestore.collection('RSGM');
  static CollectionReference console = firestore.collection('console');
  static CollectionReference Eksekutif = firestore.collection('Eksekutif');
  static CollectionReference AntrianPasien = firestore.collection('Antrian');

  static CollectionReference Alat = firestore.collection('Alat');
  static CollectionReference Bahan = firestore.collection('Bahan');
  static CollectionReference Dosen = firestore.collection('Dosen');

  static Future<void> AccMahasiswaKoas(
    String email,
    bool acc,
  ) async {
    await userdata.doc(email).update(
      {
        'ACCADMIN': acc,
      },
    );
  }

  static Future<void> updateakun(
    String? email,
    String nama,
    String NIM,
    String gender,
    String? tanggal,
    String? bulan,
    String? tahun,
    String alamat,
    String noHP,
    String? imageUrl,
    String namarsgm,
  ) async {
    await userdata.doc(email).set(
      {
        'email': email,
        'nama': nama,
        'NIM': NIM,
        'gender': gender,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        'alamat': alamat,
        'noHP': noHP,
        'imageurl': imageUrl,
        'StatusAkun': 'Koas',
        'StatusAkunPrakarsa': 'RSGM',
        'Fasyankes': namarsgm,
        'RSGM': namarsgm,
      },
    );

    await userdata.doc(email).update(
      {
        'saldo': 0,
        'uangmasuk': 0,
        'uangkeluar': 0,
        'ACCADMIN': false,
      },
    );
  }
}
