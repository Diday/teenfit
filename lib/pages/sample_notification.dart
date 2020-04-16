import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class NotificationHomePage extends StatefulWidget {
  @override
  _NotificationHomePageState createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime_channel_id_ielts',
      'repeatDailyAtTime_channel_name_ielts',
      'repeatDailyAtTime_description_ielts');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics;
  @override
  void initState() {
    super.initState();
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin
        .initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    )
        .then((init) {
      setupNotification();
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    } else {
      print('null payload');
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('dont forget'),
              actions: [
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> createNotifications() async {
    var time = Time(20, 15, 10);
    var time2 = Time(21, 00, 10);

    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0, 'IELTS ', 'Time to learn', time, platformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        1, 'IELTS', 'Time to learn', time2, platformChannelSpecifics);
  }

  Future<void> createDailyNotification() async {
    var time = new Time(09, 00, 00);

    try {
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          1,
          'show daily title',
          'Daily notification shown at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
          time,
          platformChannelSpecifics);
    } catch (e) {
      print(e.toString());
    }

    print(time.toString() +
        androidPlatformChannelSpecifics.toString() +
        iOSPlatformChannelSpecifics.toString() +
        platformChannelSpecifics.toString());
  }

  Future<void> createWeeklyNotification() async {
    var time = new Time(10, 0, 0);

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'show weekly title',
        'Weekly notification shown on Monday at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
        Day.Monday,
        time,
        platformChannelSpecifics);
  }

  Future<void> createScheduledNotification() async {
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 5));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Minerva Time',
        'Minerva Time!!!',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> createPerNotification() async {
    // Show a notification every minute with the first appearance happening a minute after invoking the method

    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.EveryMinute, platformChannelSpecifics);
  }

  showNotification() async {
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> setupNotification() async {
    try {
      //await createScheduledNotification();

      //await createDailyNotification();
      //await showNotification();
      //await createNotifications();
    } catch (e) {
      print(e.toString());
    }

    /*createDailyNotification();
    //createWeeklyNotification();
    createScheduledNotification();*/
  }

  cancellAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hi'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'hello world notifi',
                style: TextStyle(fontSize: 25),
              ),
              FlatButton(
                child: Text('press'),
                onPressed: () {
                  createDailyNotification();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}