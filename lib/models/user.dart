import 'package:firebase_database/firebase_database.dart';

class User {
  String key;
  String name;
  String birthDate;
  int pendidikan;
  String userId;

  User(this.userId, this.name, this.birthDate, this.pendidikan);

  User.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    name = snapshot.value["name"],
    birthDate = snapshot.value["birthDate"],
    pendidikan = snapshot.value["pendidikan"];

  toJson() {
    return {
      "userId": userId,
      "name": name,
      "birthDate": birthDate,
      "pendidikan": pendidikan,
    };
  }
}