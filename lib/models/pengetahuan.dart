import 'package:firebase_database/firebase_database.dart';

class Pengetahuan {
  String key;
  String picture;
  String title;
  String description;
  
  Pengetahuan({this.picture, this.title, this.description});

  Pengetahuan.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        title = snapshot.value["title"],
        picture = snapshot.value["picture"],
        description = snapshot.value["description"];

  toJson() {
    return {
      "title": title,
      "picture": picture,
      "description": description,
    };
  }
}