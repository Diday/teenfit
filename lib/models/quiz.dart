import 'package:firebase_database/firebase_database.dart';

class Quiz {
  String key;
  String pertanyaan;
  int jawaban;

  Quiz({this.pertanyaan, this.jawaban});

  Quiz.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    pertanyaan = snapshot.value["pertanyaan"],
    jawaban = snapshot.value["jawaban"];

  toJson() {
    return {
      "pertanyaan": pertanyaan,
      "jawaban": jawaban,
    };
  }
}