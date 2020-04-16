import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:teenfit/services/authentication.dart';
import 'package:teenfit/pages/navigation_page.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new GradientAppBar(
          title: Text('TeenFit'),
          backgroundColorStart: Colors.cyan,
          backgroundColorEnd: Colors.indigo,
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 14.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: ChangeNotifierProvider<NavigationPageProvider>(
          child: NavigationPage(userId: widget.userId),
          create: (BuildContext context) => NavigationPageProvider(),
        ),
      );
  }
}
