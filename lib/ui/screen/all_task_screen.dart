import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/main.dart';
import 'package:timeline_node/timeline_node.dart';

import '../../core/bloc/database_bloc/database_bloc.dart';
import '../../core/util/tasks_util.dart';
import '../widget/date_picker.dart';
import '../widget/taskpage_card_layout.dart';
import 'task_editor_screen.dart';
import 'detail_screen.dart';

class AllTask extends StatefulWidget {
  final Function function;
  final Function onMenuTap;
  AllTask({Key key, this.function, this.onMenuTap}) : super(key: key);

  _AllTaskState createState() => _AllTaskState();
}

class _AllTaskState extends State<AllTask> {
  var _date = DateTime.now();
  TasksUtil _tasksUtil = TasksUtil();

  @override
  void initState() {
    refreshUI();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refreshUI() {
    BlocProvider.of<DatabaseBloc>(context).add(GetTaskByDate(date: _date));
  }

  _navigator() {
    Navigator.pushNamed(context, homeRoute);
    if (widget.function != null) widget.function.call();
  }

  @override
  Widget build(BuildContext context) {
    /*Timer.periodic(Duration(seconds: 1), (timer) {
      BlocProvider.of<DatabaseBloc>(context).add(GetTaskByDate(_date));
    });*/

    return WillPopScope(
      onWillPop: () async {
        _navigator();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.black),
                onPressed: _navigator),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  widget.onMenuTap.call();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              )
            ],
          ),
          body: body()),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[dateNow(), addNewTask()],
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(child: calendarTimeline()),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.date_range,
                          size: 40, color: Colors.black87),
                      onPressed: () async {
                        var date = await selectDate(context);
                        if (date != null) {
                          setState(() {
                            _date = date;
                            BlocProvider.of<DatabaseBloc>(context)
                                .add(GetTaskByDate(date: date));
                            print(_date);
                          });
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(child: listTask())
        ],
      ),
    );
  }

  Widget dateNow() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(DateFormat('dd MMMM yyyy').format(DateTime.now()),
            style:
                TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 15.0)),
        Text("Today",
            style: TextStyle(
                color: Colors.black, fontSize: 22.0, fontFamily: 'Roboto-Bold'))
      ],
    );
  }

  Widget addNewTask() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, taskEditorRoute,
          arguments: TaskEditorArguments(
              isNew: true,
              function: refreshUI,
              fromHome: false,
              fromTaskPage: true)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil().setWidth(30)),
            ),
            color: Colors.black),
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(25)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.white,
                size: ScreenUtil().setWidth(45),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text('Add Task',
                  style: TextStyle(color: Colors.white, fontSize: 13.0))
            ],
          ),
        ),
      ),
    );
  }

  Widget calendarTimeline() {
    return DatePicker(
      _date.subtract(Duration(days: 2)),
      initialSelectedDate: _date,
      selectionColor: Theme.of(context).primaryColor,
      selectedTextColor: Colors.black87,
      dateTextStyle: TextStyle(color: Colors.black54),
      dayTextStyle: TextStyle(color: Colors.black54),
      monthTextStyle: TextStyle(color: Colors.black54),
      width: ScreenUtil().setWidth(180),
      height: ScreenUtil().setHeight(240),
      onDateChange: (date) {
        setState(() {
          _date = date;
          BlocProvider.of<DatabaseBloc>(context).add(GetTaskByDate(date: date));
        });
      },
    );
  }

  Widget listTask() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is TaskByDateLoaded) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: state.list.length,
            itemBuilder: (context, index) {
              var taskName = state.list[index].tasks.taskName;
              var description = state.list[index].tasks.description;
              var startTime = state.list[index].tasks.startTime;
              var participants = state.list[index].tasks.participants;
              var status = state.list[index].status;
              var nodeStyle = state.list[index].nodeStyle;

              return TimelineNode(
                  style: nodeStyle,
                  indicator: status == 0
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor))
                      : Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.grey, width: 2)),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                  child: Padding(
                      padding: EdgeInsets.all(4),
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, detailTaskRoute,
                                arguments: DetailTaskArguments(
                                  tasks: state.list[index].tasks,
                                  function: refreshUI,
                                  fromNotification: false,
                                  fromEditor: false,
                                )),
                        child: cardLayout(taskName, description, participants,
                            startTime, status, () {
                          setState(() {
                            BlocProvider.of<DatabaseBloc>(context).add(
                                UpdateTask(
                                    tasks: _tasksUtil.saveTasks(
                                        state.list[index].tasks, true, null)));
                            refreshUI();
                          });
                        }),
                      )));
            },
          );
        } else if (state is DatabaseEmpty) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: ScreenUtil().setWidth(600),
                            width: ScreenUtil().setWidth(600),
                            child: SvgPicture.asset('src/img/empty_task.svg')),
                        Text("Currently no tasks, add new one (+)",
                            style: TextStyle(color: Colors.grey, fontSize: 15))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}
