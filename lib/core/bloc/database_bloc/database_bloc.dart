import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/resources/hive_repository.dart';
import 'package:task_manager/core/model/task_model.dart';
import 'package:task_manager/core/model/timeline_object_model.dart';
import 'package:task_manager/core/util/tasks_util.dart';
import 'package:timeline_node/timeline_node.dart';

part 'database_event.dart';
part 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final HiveRepository hiveRepository;
  DatabaseBloc(this.hiveRepository) : super(null);
  TasksUtil _tasksUtil = TasksUtil();

  DatabaseState get initialState => DatabaseInitial();

  //
  // MAP STATE
  @override
  Stream<DatabaseState> mapEventToState(
    DatabaseEvent event,
  ) async* {
    if (event is CreateTask)
      yield* _mapCreateTaskToState(event);
    else if (event is GetAllTask)
      yield* _mapGetAllTaskToState(event);
    else if (event is GetTask)
      yield* _mapGetTaskToState(event);
    else if (event is UpdateTask)
      yield* _mapUpdateTaskToState(event);
    else if (event is DeleteTask)
      yield* _mapDeleteTaskToState(event);
    else if (event is GetTaskByDate)
      yield* _mapTaskByDateToState(event);
    else if (event is GetHomePageTask)
      yield* _mapHomePageToState(event);
    else if (event is SearchTask)
      yield* _mapSearchTaskToState(event);
    else if (event is GetPinnedTask) yield* _mapGetPinnedTaskToState(event);
  }

  Stream<DatabaseState> _mapCreateTaskToState(CreateTask event) async* {
    await hiveRepository.createTask(event.tasks);
    yield TaskCreated();
  }

  Stream<DatabaseState> _mapGetAllTaskToState(GetAllTask event) async* {
    var data = await hiveRepository.getAllTask();
    if (data == null || data.length == 0)
      yield DatabaseEmpty();
    else
      yield DatabaseLoaded(list: data);
  }

  Stream<DatabaseState> _mapGetTaskToState(GetTask event) async* {
    var data = await hiveRepository.getAllTask();
    Tasks result;
    int index;

    if (event.taskId != null) {
      index = _tasksUtil.getIndex(data, event.taskId);
      result = await hiveRepository.getTaskByID(index);
    } else {
      index = _tasksUtil.getIndex(data, event.tasks.taskId);
      result = await hiveRepository.getTaskByID(index);
    }

    if (result != null)
      yield TaskLoaded(tasks: result);
    else
      yield TaskNotFound();
  }

  Stream<DatabaseState> _mapUpdateTaskToState(UpdateTask event) async* {
    var data = await hiveRepository.getAllTask();
    int index = _tasksUtil.getIndex(data, event.tasks.taskId);

    await hiveRepository.updateTasks(index, event.tasks);
    yield TaskUpdated();
  }

  Stream<DatabaseState> _mapDeleteTaskToState(DeleteTask event) async* {
    var data = await hiveRepository.getAllTask();
    int index = _tasksUtil.getIndex(data, event.tasksID);

    await hiveRepository.deleteTasks(index);
    yield TaskDeleted();
  }

  Stream<DatabaseState> _mapTaskByDateToState(GetTaskByDate event) async* {
    var data = await hiveRepository.getAllTask();
    List<TimelineObject> list = List();
    List<Tasks> tempList = List();

    if (data == null || data.length == 0)
      yield DatabaseEmpty();
    else {
      for (int i = 0; i < data.length; i++) {
        if (data[i].date.day == event.date.day) tempList.add(data[i]);
      }

      tempList.sort((a, b) {
        final taskStartTime = DateTime(a.date.year, a.date.month, a.date.day,
            a.startTime.hour, a.startTime.minute);
        final tasksEndTime = DateTime(b.date.year, b.date.month, b.date.day,
            b.endTime.hour, b.endTime.minute);

        return taskStartTime.compareTo(tasksEndTime);
      });

      for (int i = 0; i < tempList.length; i++) {
        bool isNow = _tasksUtil.checkTaskIfNow(tempList[i]);
        int status;

        if (tempList[i].isDone == true)
          status = 2;
        else if (isNow == false)
          status = 1;
        else
          status = 0;

        if (i == 0) {
          list.add(
            TimelineObject(
                TimelineNodeStyle(
                    lineType: TimelineNodeLineType.BottomHalf,
                    lineColor: status == 0 ? Color(0xFFfabb18) : Colors.grey),
                tempList[i],
                status),
          );
        } else if (i == data.length - 1 || tempList.length == 2) {
          list.add(
            TimelineObject(
                TimelineNodeStyle(
                    lineType: TimelineNodeLineType.TopHalf,
                    lineColor: status == 0 ? Color(0xFFfabb18) : Colors.grey),
                tempList[i],
                status),
          );
        } else {
          list.add(
            TimelineObject(
                TimelineNodeStyle(
                    lineType: TimelineNodeLineType.Full,
                    lineColor: status == 0 ? Color(0xFFfabb18) : Colors.grey),
                tempList[i],
                status),
          );
        }
      }

      if (list == null || list.length == 0) {
        yield DatabaseEmpty();
      } else {
        yield TaskByDateLoaded(list: list);
      }
    }
  }

  Stream<DatabaseState> _mapHomePageToState(GetHomePageTask event) async* {
    List<Tasks> pinnedList = List();
    List<Tasks> recentlyList = List();
    List<Tasks> todayList = List();
    List<Tasks> upcomingList = List();
    List<Tasks> laterList = List();
    var now = DateTime.now();
    var upcomingStartDate = now.add(Duration(days: 1));
    var upcomingEndDate = now.add(Duration(days: 3));
    var laterStartDate = now.add(Duration(days: 4));
    var laterEndDate = now.add(Duration(days: 30));

    var data = await hiveRepository.getAllTask();

    if (data == null || data.length == 0)
      yield DatabaseEmpty();
    else {
      for (int i = 0; i < data.length; i++) {
        if (data[i].isDone == true) {
          continue;
        } else {
          //
          // GET PINNED TASKS
          if (data[i].pinned == true) pinnedList.add(data[i]);

          //
          // GET RECENTLY TASKS
          bool recentlyStatus = _tasksUtil.checkTaskIfNow(data[i]);
          if (recentlyStatus == true) recentlyList.add(data[i]);

          //
          // GET TODAY TASKS
          if (data[i].date.day == now.day) todayList.add(data[i]);

          //
          // GET UPCOMING TASKS
          bool upcomingStatus = _tasksUtil.checkTimeBasedTasks(
              upcomingStartDate, upcomingEndDate, data[i]);
          if (upcomingStatus == true) upcomingList.add(data[i]);

          //
          // GET LATER TASKS
          bool laterStatus = _tasksUtil.checkTimeBasedTasks(
              laterStartDate, laterEndDate, data[i]);
          if (laterStatus == true) laterList.add(data[i]);
        }
      }
    }

    yield HomePageTaskLoaded(
        pinnedList: pinnedList.length != 0 ? pinnedList : data,
        recentlyList: recentlyList,
        todayList: todayList,
        upcomingList: upcomingList,
        laterList: laterList);
  }

  Stream<DatabaseState> _mapSearchTaskToState(SearchTask event) async* {
    var data = await hiveRepository.getAllTask();
    List<Tasks> resultTasksList = List();

    for (var tasks in data) {
      RegExp exp = new RegExp(
        event.taskName,
        caseSensitive: false,
      );

      if (exp.hasMatch(tasks.taskName)) resultTasksList.add(tasks);
    }

    if (event.taskName == null || event.taskName == "")
      yield DatabaseInitial();
    else
      yield SearchTaskLoaded(list: resultTasksList, listAllTasks: data);
  }

  Stream<DatabaseState> _mapGetPinnedTaskToState(GetPinnedTask event) async* {
    var data = await hiveRepository.getAllTask();
    List<Tasks> pinnedList = List();

    for (var item in data) {
      if (item.pinned == true) pinnedList.add(item);
    }

    if (pinnedList.length != 0)
      yield PinnedTaskLoaded(listTasks: pinnedList);
    else
      yield DatabaseEmpty();
  }
}
