class Procedure {
  final String procedure;
  final int price;
  final String? explanation;

  Procedure({required this.procedure, required this.price, this.explanation});

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      procedure: json['procedure'],
      price: json['price'],
      explanation: json['explanation'],
    );
  }
}

class Treatment {
  final String doctor;
  final String idpasien;
  final String namapasien;
  final List<Procedure> procedures;
  final String timestamp;

  Treatment({required this.doctor, required this.idpasien, required this.namapasien, required this.procedures, required this.timestamp});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    var proceduresJson = json['procedures'] as List;
    List<Procedure> proceduresList = proceduresJson.map((i) => Procedure.fromJson(i)).toList();

    return Treatment(
      doctor: json['doctor'],
      idpasien: json['idpasien'],
      namapasien: json['namapasien'],
      procedures: proceduresList,
      timestamp: json['timestamp'],
    );
  }
}

class Patient {
  final String fullName;
  final String address;
  final String dob;
  final String email;
  final String gender;
  final String imageUrl;
  final String phone;
  final String religion;
  final String suku;

  Patient({required this.fullName, required this.address, required this.dob, required this.email, required this.gender, required this.imageUrl, required this.phone, required this.religion, required this.suku});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      fullName: json['fullName'],
      address: json['address'],
      dob: json['dob'],
      email: json['email'],
      gender: json['gender'],
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      religion: json['religion'],
      suku: json['suku'],
    );
  }
}
