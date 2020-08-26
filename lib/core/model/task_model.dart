// To parse this JSON data, do
//
//     final tasks = tasksFromMap(jsonString);

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
part 'task_model.g.dart';

// To parse this JSON data, do
//
//     final tasks = tasksFromMap(jsonString);

@HiveType(typeId: 1)
class Tasks {
  Tasks(
      {this.id,
      @required this.taskId,
      @required this.taskName,
      this.description,
      this.place,
      this.category,
      @required this.date,
      @required this.startTime,
      @required this.endTime,
      this.participants,
      this.subtask,
      this.isDone,
      this.pinned})
      : assert(taskId != null &&
            taskName != null &&
            date != null &&
            startTime != null &&
            endTime != null);

  @HiveField(0)
  int id;
  @HiveField(1)
  String taskId;
  @HiveField(2)
  String taskName;
  @HiveField(3)
  String description;
  @HiveField(4)
  String place;
  @HiveField(5)
  int category;
  @HiveField(6)
  DateTime date;
  @HiveField(7)
  TimeOfDay startTime;
  @HiveField(8)
  TimeOfDay endTime;
  @HiveField(9)
  List<String> participants;
  @HiveField(10)
  List<Subtask> subtask;
  @HiveField(11)
  bool isDone;
  @HiveField(12)
  bool pinned;
}

@HiveType(typeId: 2)
class Subtask {
  Subtask({
    this.subtaskName,
    this.isDone,
  });

  @HiveField(0)
  String subtaskName;
  @HiveField(1)
  bool isDone;
}
