import 'package:firebase_database/firebase_database.dart';

class Rapor {
  String key;
  String userId;
  int nilaiPengetahuan;
  int nilaiSikap;
  int nilaiKepatuhan;
  String grade;
  String tanggalQuiz;
  
  Rapor(this.userId, this.nilaiPengetahuan, this.nilaiSikap, this.nilaiKepatuhan, this.grade, this.tanggalQuiz);

  Rapor.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    nilaiPengetahuan = snapshot.value["nilaiPengetahuan"],
    nilaiSikap = snapshot.value["nilaiSikap"],
    nilaiKepatuhan = snapshot.value["nilaiKepatuhan"],
    grade = snapshot.value["grade"],
    tanggalQuiz = snapshot.value["tanggalQuiz"];

  toJson() {
    return {
      "userId": userId,
      "nilaiPengetahuan": nilaiPengetahuan,
      "nilaiSikap": nilaiSikap,
      "nilaiKepatuhan": nilaiKepatuhan,
      "grade": grade,
      "tanggalQuiz": tanggalQuiz,
    };
  }
}