import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';
import '../model/notification_model.dart';
import '../model/task_model.dart';

class NotificationPlugin {
  NotificationPlugin._() {
    _requestIOSPermissions();
  }

  //
  // REQUEST PERMISSION
  //
  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  //
  // SELECTED NOTIFICATION
  //
  void configureSelectNotificationSubject(Function onSelectNotification) async {
    selectNotification.listen((payload) {
      onSelectNotification(payload);
    });
  }

  void configureDidReceiveLocalNotificationSubject(
      Function onDidReceiveNotification) {
    didReceiveLocalNotificationSubject
        .listen((ReceivedNotification receivedNotification) async {
      onDidReceiveNotification(receivedNotification);
    });
  }

  //
  // SCHEDULE NOTIFICATION
  //
  Future<void> scheduleNotification(DateTime date, Tasks tasks) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        playSound: true,
        icon: 'app_icon',
        sound: RawResourceAndroidNotificationSound('google_event'),
        vibrationPattern: vibrationPattern,
        priority: Priority.High,
        importance: Importance.Max,
        autoCancel: true,
        enableLights: true,
        color: Color(0xFFfabb18),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0, tasks.taskName, tasks.description, date, platformChannelSpecifics,
        payload: tasks.taskId);
  }

  Future<void> showNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Title',
      'Test Body', //null
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();
