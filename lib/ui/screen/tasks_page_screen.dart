import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/core/model/task_model.dart';
import 'package:task_manager/ui/screen/add_task_screen.dart';
import 'package:task_manager/ui/screen/menu_dashboard_screen.dart';
import 'package:task_manager/ui/widget/date_picker.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:timeline_node/timeline_node.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'detail_screen.dart';
import '../widget/taskpage_card_layout.dart';

class TasksPage extends StatefulWidget {
  final Function function;
  final Function onMenuTap;
  TasksPage({Key key, this.function, this.onMenuTap}) : super(key: key);

  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  var _date = DateTime.now();
  AnimationController animationController;
  Tasks tasks = Tasks();

  @override
  void initState() {
    refreshUI();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void refreshUI() {
    BlocProvider.of<DatabaseBloc>(context).add(GetTaskByDate(date: _date));
  }

  @override
  Widget build(BuildContext context) {
    /*Timer.periodic(Duration(seconds: 1), (timer) {
      BlocProvider.of<DatabaseBloc>(context).add(GetTaskByDate(_date));
    });*/

    return WillPopScope(
      onWillPop: () async {
        widget.function != null ?? widget.function.call();

        Navigator.of(context).push(PageRouteTransition(
            animationType: AnimationType.slide_left,
            curves: Curves.easeInOut,
            fullscreenDialog: true,
            maintainState: true,
            builder: (context) => MenuDashboard(currentIndexPage: 0)));
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.black),
                onPressed: () {
                  widget.function != null ?? widget.function.call();

                  Navigator.of(context).push(PageRouteTransition(
                      animationType: AnimationType.slide_left,
                      curves: Curves.easeInOut,
                      fullscreenDialog: true,
                      maintainState: true,
                      builder: (context) =>
                          MenuDashboard(currentIndexPage: 0)));
                }),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  widget.onMenuTap.call();
                },
                icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: animationController),
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
        Text(
            _date == DateTime.now()
                ? "Today"
                : DateFormat('EEEE').format(_date),
            style: TextStyle(
                color: Colors.black, fontSize: 22.0, fontFamily: 'Roboto-Bold'))
      ],
    );
  }

  Widget addNewTask() {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => AddTask(
                    function: refreshUI,
                    isNew: true,
                    fromHome: false,
                    fromTaskPage: true,
                  ))),
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
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailTask(
                                    tasks: state.list[index].tasks,
                                    function: refreshUI,
                                    fromNotification: false,
                                  )));
                        },
                        child: cardLayout(taskName, description, participants,
                            startTime, status, () {
                          setState(() {
                            BlocProvider.of<DatabaseBloc>(context).add(
                                UpdateTask(
                                    tasks: tasks.saveTasks(
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
                    child: Container(
                        height: ScreenUtil().setWidth(300),
                        width: ScreenUtil().setWidth(300),
                        child: SvgPicture.asset('src/img/empty_task.svg')),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: Container(
                  child: Center(
                    child: Container(
                        height: ScreenUtil().setWidth(300),
                        width: ScreenUtil().setWidth(300),
                        child: SvgPicture.asset('src/img/error.svg')),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
