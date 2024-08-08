// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RekamMedis extends StatefulWidget {
  const RekamMedis({
    super.key,
  });

  @override
  _RekamMedisState createState() => _RekamMedisState();
}

class _RekamMedisState extends State<RekamMedis> {
  @override
  void initState() {
    super.initState();
    readData();
  }

  int currentstep = 0;

  TextEditingController emailpasien = TextEditingController();
  TextEditingController Nama = TextEditingController();
  TextEditingController NIK = TextEditingController();
  TextEditingController TempatLahir = TextEditingController();
  TextEditingController Alamat = TextEditingController();
  TextEditingController pekerjaan = TextEditingController();
  TextEditingController noHP = TextEditingController();
  TextEditingController agama = TextEditingController();
  TextEditingController suku = TextEditingController();

  bool switchidentitas = false;
  bool switchnama = false;
  bool switchgender = false;
  bool switchumur = false;
  bool switchnotelepon = false;
  bool switchalamat = false;
  bool switchnikah = false;
  bool switchagama = false;
  bool switchgoldar = false;
  bool switchstatusmahasiswa = false;
  bool switchpendidikan = false;
  bool switchWNIWNA = false;
  bool switchmetodepembayaran = false;
  bool switchpekerjaan = false;

  String? tanggal, bulan, tahun;
  String? gender;
  String? genderr;
  int? umur;
  int? tanggalawal = 0, bulanawal = 0, tahunawal = 0;

  bool isLastStep2 = false;
  String imageUrlKRS = '';

  bool ceknama = false;

  String cekdatapasien = '';

  int countdatavalid = 0;
  int idnama = 0;
  bool isLoading = true;

  List<String> listpasiennew = [];
  List listemailpasiennew = [];
  List listtagihanpasien = [];
  List listtotal_tagihanpasien = [];
  List listnominal_tagihanpasien = [];
  List listidentitaspasien = [];
  List listnamapasiennew = [];
  List listidrmpasiennew = [];
  List listinstansipasiennew = [];
  List listpasiennewmaster = [];
  List listnomoridentitaspasiennew = [];

  Future<void> readData() async {
    var url =
        "https://rekammedis-b4f1a-default-rtdb.asia-southeast1.firebasedatabase.app/Fasyankes/RSGMUNAND/Inquiry.json?auth=zX21lpnCjn14CfbxDDfuAFFsmebMldynDvH5Xxg6";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        extractedData.forEach((Id, Data) {
          listemailpasiennew.add(Data["emailuser"]);
          listnamapasiennew.add(Data["nama"]);
          listidrmpasiennew.add(Data["idrm"]);
          listinstansipasiennew.add(Data['instansi']);
          listidentitaspasien.add(Data['identitas']);
          listnomoridentitaspasiennew.add(Data['no_identitas']);
          listtagihanpasien.add(Data['list_tagihan']);
          listtotal_tagihanpasien.add(Data['total_tagihan']);
          listnominal_tagihanpasien.add(Data['nominal_tagihan']);
        });
        listpasiennewmaster = [
          for (int i = 0; i < listnamapasiennew.length; i++)
            {
              'emailuser': listemailpasiennew[i],
              'nama': listnamapasiennew[i],
              'idRM': listidrmpasiennew[i],
              'instansi': listinstansipasiennew[i],
              'identitas': listidentitaspasien[i],
              'no_identitas': listnomoridentitaspasiennew[i],
              'list_tagihan': listtagihanpasien[i],
              'total_tagihan': listtotal_tagihanpasien[i],
              'nominal_tagihan': listnominal_tagihanpasien[i],
            }
        ];
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      rethrow;
    }
  }

  Future<void> postData(
      String NoRM,
      String emailuser,
      String nama,
      String idRM,
      String instansi,
      String identitas,
      String no_identitas,
      int total_tagihan,
      int nominal_tagihan,
      List list_tagihan) async {
    var url =
        "https://rekammedis-b4f1a-default-rtdb.asia-southeast1.firebasedatabase.app/Fasyankes/RSGMUNAND/Inquiry/$NoRM.json?auth=zX21lpnCjn14CfbxDDfuAFFsmebMldynDvH5Xxg6";
    var urlpayment =
        "https://rekammedis-b4f1a-default-rtdb.asia-southeast1.firebasedatabase.app/Fasyankes/RSGMUNAND/Payment/$NoRM.json?auth=zX21lpnCjn14CfbxDDfuAFFsmebMldynDvH5Xxg6";
    var reqbody = {
      'emailuser': emailuser,
      'nama': nama,
      'idRM': idRM,
      'instansi': instansi,
      'identitas': identitas,
      'no_identitas': no_identitas,
      'list_tagihan': list_tagihan,
      'total_tagihan': total_tagihan,
      'nominal_tagihan': nominal_tagihan,
    };
    try {
      http.Response response = await http.put(
        Uri.parse(url),
        body: json.encode(reqbody),
      );
      http.Response responsepayment = await http.put(
        Uri.parse(urlpayment),
        body: json.encode(reqbody),
      );
      if (kDebugMode) {
        print(response);
        print(responsepayment);
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: Nama,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: NIK,
                decoration: InputDecoration(
                  labelText: 'NIK',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: TempatLahir,
                decoration: InputDecoration(
                  labelText: 'Tempat Lahir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: Alamat,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pekerjaan,
                decoration: InputDecoration(
                  labelText: 'Pekerjaan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noHP,
                decoration: InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: agama,
                decoration: InputDecoration(
                  labelText: 'Agama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: suku,
                decoration: InputDecoration(
                  labelText: 'Suku',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: listpasiennewmaster.map((pasien) {
                        return ListTile(
                          title: Text(pasien['nama']),
                          subtitle: Text(pasien['emailuser']),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
