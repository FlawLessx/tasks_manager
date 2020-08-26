import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/core/model/task_model.dart';

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

Future<void> testNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var date = DateTime.now().add(Duration(seconds: 5));

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
      0, "taskName", "Description", date, platformChannelSpecifics,
      payload: "test");
}
