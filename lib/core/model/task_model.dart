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
      this.taskId,
      this.taskName,
      this.description,
      this.place,
      this.category,
      this.date,
      this.startTime,
      this.endTime,
      this.participants,
      this.subtask,
      this.isDone,
      this.pinned});

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

  bool checkTaskIfNow(Tasks tasks) {
    bool status;
    final now = DateTime.now();
    final taskStartTime = DateTime(tasks.date.year, tasks.date.month,
        tasks.date.day, tasks.startTime.hour, tasks.startTime.minute);
    final tasksEndTime = DateTime(tasks.date.year, tasks.date.month,
        tasks.date.day, tasks.endTime.hour, tasks.endTime.minute);

    if (now.isAfter(taskStartTime) && now.isBefore(tasksEndTime))
      status = true;
    else
      status = false;

    return status;
  }

  bool checkTimeBasedTasks(DateTime startDate, DateTime endDate, Tasks tasks) {
    bool status;

    if (tasks.date.isAfter(startDate) && tasks.date.isBefore(endDate))
      status = true;
    else
      status = false;

    return status;
  }

  Tasks saveTasks(Tasks tasks, bool isDone, bool pinned) {
    return Tasks(
        taskId: tasks.taskId,
        taskName: tasks.taskName,
        description: tasks.description,
        place: tasks.place,
        category: tasks.category,
        date: tasks.date,
        startTime: tasks.startTime,
        endTime: tasks.endTime,
        participants: tasks.participants,
        subtask: tasks.subtask,
        isDone: isDone,
        pinned: pinned != null ?? tasks.pinned);
  }
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
