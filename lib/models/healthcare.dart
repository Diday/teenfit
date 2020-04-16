import 'package:firebase_database/firebase_database.dart';

class HealthCare {
  String key;
  int beratBadan;
  int tinggiBadan;
  double lingkarLenganAtas;
  double kadarHB;
  String tanggalMens;
  String keluhan;
  String tanggalDataDiri;
  String userId;

  HealthCare(
    this.userId, 
    this.beratBadan, 
    this.tinggiBadan, 
    this.lingkarLenganAtas, 
    this.kadarHB, 
    this.tanggalMens,
    this.keluhan,
    this.tanggalDataDiri
  );

  HealthCare.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    beratBadan = snapshot.value["beratBadan"],
    tinggiBadan = snapshot.value["tinggiBadan"],
    lingkarLenganAtas = snapshot.value["lingkarLenganAtas"],
    kadarHB = snapshot.value["kadarHB"],
    tanggalMens = snapshot.value["tanggalMens"],
    keluhan = snapshot.value["keluhan"],
    tanggalDataDiri = snapshot.value["tanggalDataDiri"];

  toJson() {
    return {
      "userId": userId,
      "beratBadan": beratBadan,
      "tinggiBadan": tinggiBadan,
      "lingkarLenganAtas": lingkarLenganAtas,
      "kadarHB": kadarHB,
      "tanggalMens": tanggalMens,
      "keluhan": keluhan,
      "tanggalDataDiri": tanggalDataDiri
    };
  }
}