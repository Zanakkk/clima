// ignore_for_file: file_names, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static CollectionReference klinik = firestore.collection('Klinik');
  static CollectionReference console = firestore.collection('console');

  static Future<void> updateakun(
      String? email,
      String ID,
      String Nama,
      String Alamat,
      String username,
      String password,
      int tanggal,
      int bulan,
      int tahun,
      String NomorTelepon,
      String? imageUrl) async {
    await klinik.doc(email).set(
      {
        'Email': email,
        'ID': ID,
        'Nama': Nama,
        'username': username,
        'password': password,
        'JoinTanggal': tanggal,
        'JoinBulan': bulan,
        'JoinTahun': tahun,
        'NomorTelepon': NomorTelepon,
        'GambarKlinik': imageUrl,
      },
    );
  }

  static Future<void> RegistrasiPasien(
    String email,
    String ID,
    String Nama,
    int tanggal,
    int bulan,
    int tahun,
    String TempatLahir,
    String Pekerjaan,
    String Alamat,
    String NomorTelepon,
  ) async {
    await klinik.doc(email).collection('RekamMedis').doc(ID).set(
      {
        'IDRM': ID,
        'Nama': Nama,
        'JoinTanggal': tanggal,
        'JoinBulan': bulan,
        'JoinTahun': tahun,
        'TempatLahir': TempatLahir,
        'Pekerjaan': Pekerjaan,
        'Alamat': Alamat,
        'NomorTelepon': NomorTelepon,
        'Done': false,
      },
    );
  }

  static Future<void> incremetnRekamMedis(
    String email,
    String ID,
  ) async {
    await klinik.doc(email).collection('Console').doc('Console').update(
      {'RekamMedis': FieldValue.increment(1)},
    );
  }

  static Future<void> DataMedikPasien(
    String email,
    String ID,
    String goldar,
    bool Jantung,
    bool Diabetes,
    bool Hepatitis,
    bool Lainnya,
    String PenyakitLainnya,
    bool AlergiObat,
    String AlergiObats,
    bool AlergiMakanan,
    String AlergiMakanans,
    int perawatan,
  ) async {
    await klinik.doc(email).collection('RekamMedis').doc(ID).update(
      {
        'GolonganDarah': goldar,
        'DataMedikJantung': Jantung,
        'DataMedikDiabetes': Diabetes,
        'DataMedikHepatitis': Hepatitis,
        'DataMedikLainnya': Lainnya,
        'DataMedikLainnyaPenjelasan': PenyakitLainnya,
        'DataMedikAlergiObat': AlergiObat,
        'DataMedikAlergiObatPenjelasan': AlergiObats,
        'DataMedikAlergiMakanan': AlergiMakanan,
        'DataMedikAlergiMakananPenjelasan': AlergiMakanans,
        'perawatan': perawatan,
      },
    );
  }

  static Future<void> PerawatanPasien(
    String email,
    String ID,
    int perawatanno,
    String Keluhan,
    String Perawatan,
    int Biaya,
    String NamaDokterGigi,
    String TTD,
  ) async {
    await klinik
        .doc(email)
        .collection('RekamMedis')
        .doc(ID)
        .collection('Perawatan')
        .doc(perawatanno.toString())
        .set(
      {
        'PerawatanKe': perawatanno,
        'Keluhan': Keluhan,
        'Perawatan': Perawatan,
        'Biaya': Biaya,
        'DokterGigi': NamaDokterGigi,
        'TTD': TTD,
      },
    );
  }

  static Future<void> incrementPerawatanPasien(
    String email,
    String ID,
    int perawatanno,
  ) async {
    await klinik.doc(email).collection('RekamMedis').doc(ID).update(
      {'perawatan': FieldValue.increment(1)},
    );
  }

  static Future<void> perawatansetdone(
    String email,
    String ID,
    int perawatanno,
  ) async {
    await klinik.doc(email).collection('RekamMedis').doc(ID).update(
      {'Done': true},
    );
  }

  static Future<void> perawatansetfalse(
      String email,
      String ID,
      int perawatanno,
      ) async {
    await klinik.doc(email).collection('RekamMedis').doc(ID).update(
      {'Done': false},
    );
  }


}
