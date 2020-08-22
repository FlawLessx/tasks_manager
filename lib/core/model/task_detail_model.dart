import 'package:flutter/material.dart';

class TaskDetailWidget {
  final IconData icon;
  final String text;
  final Color color;

  TaskDetailWidget(
      {@required this.icon, @required this.text, @required this.color});
}

List<TaskDetailWidget> listWidget = [
  TaskDetailWidget(
      icon: Icons.date_range, text: 'Pick date', color: Colors.orangeAccent),
  TaskDetailWidget(
      icon: Icons.access_time, text: 'Pick time', color: Colors.pinkAccent),
  TaskDetailWidget(
      icon: Icons.place, text: 'Insert Location', color: Colors.blueAccent),
];
