import 'package:flutter/material.dart';
import 'package:teenfit/services/authentication.dart';
import 'package:teenfit/pages/root_page.dart';
import 'package:flutter/services.dart' ;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

    return new MaterialApp(
        title: 'TeenFit',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
