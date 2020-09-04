import 'package:dough/dough.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/main.dart';

import '../../core/bloc/database_bloc/database_bloc.dart';
import '../../core/model/reorder_list_model.dart';
import '../../core/model/task_detail_model.dart';
import '../../core/model/task_model.dart';
import '../../core/util/tasks_util.dart';
import '../widget/custom_button.dart';
import '../widget/detail_task.dart';
import '../widget/reorderable_item.dart';
import '../widget/toast.dart';
import 'task_editor_screen.dart';
import 'menu_dashboard_screen.dart';

class DetailTaskArguments {
  final Tasks tasks;
  final String taskId;
  final Function function;
  final bool fromNotification;
  final bool fromEditor;
  DetailTaskArguments(
      {@required this.tasks,
      @required this.function,
      this.taskId,
      @required this.fromNotification,
      @required this.fromEditor});
}

class DetailTask extends StatefulWidget {
  final Tasks tasks;
  final String taskId;
  final Function function;
  final bool fromNotification;
  final bool fromEditor;
  DetailTask(
      {@required this.tasks,
      @required this.function,
      this.taskId,
      @required this.fromNotification,
      @required this.fromEditor});

  @override
  _DetailTaskState createState() => _DetailTaskState();
}

class _DetailTaskState extends State<DetailTask> {
  //
  // VARIABLES
  //
  ScrollController _scrollController;
  bool lastStatus = true;
  List<String> data = List();
  Tasks _tasks = Tasks(
      taskId: "initial",
      taskName: "initial",
      date: DateTime.now(),
      endTime: TimeOfDay.now(),
      startTime: TimeOfDay.now());
  TasksUtil _tasksUtil = TasksUtil();
  List<ItemData> _reoderableItems = List();
  List<TextEditingController> textControllerList = [];
  List<FocusNode> focusNodeList = [];
  bool _showButton;

  //
  // INIT STATE
  //
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    KeyboardVisibility.onChange.listen((bool visible) {
      if (visible == true) {
        if (mounted) {
          setState(() {
            _showButton = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _showButton = true;
          });
          FocusScope.of(context).unfocus();
        }
      }
    });
    refreshUI();
    super.initState();
  }

  //
  // DISPOSE
  //
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    for (var item in textControllerList) {
      item.dispose();
    }
    super.dispose();
  }

  //
  // PAGE FUNCTION
  //
  void refreshUI() {
    if (widget.fromNotification == true) {
      BlocProvider.of<DatabaseBloc>(context)
          .add(GetTask(tasks: null, taskId: widget.taskId));
    } else {
      BlocProvider.of<DatabaseBloc>(context)
          .add(GetTask(tasks: widget.tasks, taskId: null));
    }
  }

  Tasks _saveTasks(Tasks tasks, bool isDone) {
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
        subtask: getSubtask(_reoderableItems),
        isDone: isDone,
        pinned: tasks.pinned);
  }

  List<Subtask> getSubtask(List<ItemData> reoderableItems) {
    List<Subtask> subtaskList = List();
    for (var item in reoderableItems) {
      subtaskList.add(item.subtask);
    }
    return subtaskList;
  }

  void addData(Tasks tasks) {
    data.add(tasks.date != null
        ? DateFormat('EEEE dd, MMMM yyyy').format(tasks.date)
        : '-');
    data.add(
        '''${tasks.startTime != null ? tasks.startTime.format(context) : "-"} - ${tasks.endTime != null ? tasks.endTime.format(context) : "-"}''');
    data.add('${tasks.place != "" ? tasks.place : "-"}');
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - (kToolbarHeight + 20));
  }

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  _navigator() {
    BlocProvider.of<DatabaseBloc>(context)
        .add(UpdateTask(tasks: _saveTasks(_tasks, _tasks.isDone)));

    if (widget.fromNotification == false) {
      Navigator.pop(context);
      if (widget.function != null) widget.function.call();
    } else if (widget.fromEditor == true) {
      Navigator.pushNamed(context, homeRoute);
    } else {
      BlocProvider.of<DatabaseBloc>(context).add(GetHomePageTask());

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(homeRoute, (route) => false);
      });
    }
  }

  _bottomButtonFunction() {
    BlocProvider.of<DatabaseBloc>(context).add(UpdateTask(
        tasks: _tasksUtil.saveTasks(
            _tasks, _tasks.isDone == false ? true : false, _tasks.pinned)));
    if (widget.fromNotification == false) {
      if (widget.function != null) widget.function.call();
      Navigator.pop(context);
    } else {
      BlocProvider.of<DatabaseBloc>(context).add(GetHomePageTask());
      Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) => MenuDashboard(currentIndexPage: 0)));
    }
  }

  //
  // REORDERABLE LIST FUNCTION
  //
  void deleteSubtask(Key key) {
    int index = _indexOfKey(key);
    setState(() {
      _reoderableItems.removeAt(index);
      textControllerList.removeAt(index);
      focusNodeList.removeAt(index);
    });
  }

  int _indexOfKey(Key key) {
    return _reoderableItems.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = _reoderableItems[draggingIndex];
    final controller = textControllerList[draggingIndex];
    final focusNode = focusNodeList[draggingIndex];

    setState(() {
      _reoderableItems.removeAt(draggingIndex);
      _reoderableItems.insert(newPositionIndex, draggedItem);
      textControllerList.removeAt(draggingIndex);
      textControllerList.insert(newPositionIndex, controller);
      focusNodeList.removeAt(draggingIndex);
      focusNodeList.insert(newPositionIndex, focusNode);
    });
    return true;
  }

  //
  // PAGE BUILDER
  //

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _navigator();

          return true;
        },
        child: Scaffold(
            body: BlocListener<DatabaseBloc, DatabaseState>(
          listener: (context, state) {
            if (state is TaskLoaded) {
              setState(() {
                _tasks = state.tasks;
              });
              for (var i = 0; i < state.tasks.subtask.length; i++) {
                setState(() {
                  _reoderableItems
                      .add(ItemData(state.tasks.subtask[i], ValueKey(i)));
                });
              }
            } else if (state is TaskNotFound) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(homeRoute, (route) => false);
            }
          },
          child: ReorderableList(
            onReorder: this._reorderCallback,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxScrolled) {
                return <Widget>[sliverAppbar()];
              },
              body: body(),
            ),
          ),
        )));
  }

  Widget body() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(80)),
                topRight: Radius.circular(ScreenUtil().setWidth(80)))),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(60),
                    vertical: ScreenUtil().setHeight(60)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    taskDetailText(),
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    detailTask(),
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    descriptionText(),
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    description(),
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    participantsText(),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(60)),
                      child: participantsTags(),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    subtaskText(),
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    listSubtask(),
                    SizedBox(height: ScreenUtil().setHeight(250)),
                  ],
                ),
              ),
            ),
            button()
          ],
        ),
      ),
    );
  }

  Widget sliverAppbar() {
    return SliverAppBar(
      title: isShrink == true
          ? Text(
              _tasks.taskName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Roboto-Bold',
                  fontSize: 16,
                  color: Colors.black87),
            )
          : null,
      leading: GestureDetector(
        onTap: _navigator,
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
          child: Container(
            decoration: BoxDecoration(
                color: Color(0xFF18130E),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil().setHeight(30)))),
            child: Center(
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      expandedHeight: ScreenUtil().setHeight(450),
      floating: false,
      pinned: true,
      actions: <Widget>[
        BlocBuilder<DatabaseBloc, DatabaseState>(
          builder: (context, state) {
            if (state is TaskLoaded) {
              return IconButton(
                icon: Icon(
                    state.tasks.pinned == true ? Icons.star : Icons.star_border,
                    size: ScreenUtil().setWidth(90),
                    color: Colors.black),
                onPressed: () {
                  setState(() {
                    if (state.tasks.pinned == true) {
                      state.tasks.pinned = false;
                      _tasks.pinned = false;
                      toastWidget("Unpinned Tasks");
                    } else {
                      _tasks.pinned = true;
                      state.tasks.pinned = true;
                      toastWidget("Tasks Pinned");
                    }
                  });
                },
                tooltip: "Pin Tasks",
              );
            } else {
              return Container();
            }
          },
        ),
        BlocBuilder<DatabaseBloc, DatabaseState>(
          builder: (context, state) {
            if (state is TaskLoaded) {
              return IconButton(
                  icon: Icon(Icons.mode_edit,
                      color: Colors.black, size: ScreenUtil().setWidth(90)),
                  tooltip: "Edit Tasks",
                  onPressed: () {
                    var savedTasks = _saveTasks(_tasks, _tasks.isDone);

                    BlocProvider.of<DatabaseBloc>(context)
                        .add(UpdateTask(tasks: savedTasks));
                    _reoderableItems.clear();

                    Navigator.pushNamed(context, taskEditorRoute,
                        arguments: TaskEditorArguments(
                          isNew: false,
                          function: refreshUI,
                          task: savedTasks,
                          fromHome: false,
                          fromTaskPage: false,
                        ));
                  });
            } else {
              return Container();
            }
          },
        ),
        IconButton(
            icon: Icon(
              Icons.delete_forever,
              size: ScreenUtil().setWidth(90),
              color: Colors.black,
            ),
            tooltip: 'Delete Tasks',
            onPressed: () {
              BlocProvider.of<DatabaseBloc>(context).add(DeleteTask(
                  tasksID: widget.fromNotification != true
                      ? widget.tasks.taskId
                      : widget.taskId));
              if (widget.function != null) widget.function.call();
              Navigator.pushNamedAndRemoveUntil(
                  context, homeRoute, (route) => false);
            }),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        background: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.topRight,
                child: ClipPath(
                  clipper: WaveClipperTwo(reverse: false, flip: false),
                  child: Container(
                    height: ScreenUtil().setHeight(280),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Color(0xFFfcd12a)),
                  ),
                )),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(30)),
                  child: Container(
                      height: ScreenUtil().setHeight(140),
                      width: ScreenUtil().setHeight(140),
                      decoration: ShapeDecoration(
                          shape: CircleBorder(), color: Color(0xFFfcd12a))),
                )),
            BlocBuilder<DatabaseBloc, DatabaseState>(
              builder: (context, state) {
                if (state is TaskLoaded)
                  return Positioned(
                    left: ScreenUtil().setWidth(60),
                    top: ScreenUtil().setWidth(280),
                    child: Container(
                      height: ScreenUtil().setHeight(600),
                      width: ScreenUtil().setWidth(1000),
                      child: Text(
                        state.tasks.taskName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            fontFamily: 'Roboto-Bold',
                            fontSize: 21,
                            color: Colors.black87),
                      ),
                    ),
                  );
                else
                  return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget taskDetailText() {
    return Text(
      'Task Detail',
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'Roboto-Medium',
          decoration: TextDecoration.none,
          fontSize: 17.0),
    );
  }

  Widget detailTask() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is TaskLoaded) {
          addData(state.tasks);
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(60)),
              itemCount: listWidget.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(30)),
                  child: DetailTaskWidget(
                    icon: listWidget[index].icon,
                    iconColor: listWidget[index].color,
                    text: data[index],
                  ),
                );
              });
        } else
          return Container();
      },
    );
  }

  Widget participantsText() {
    return Text(
      'Participants',
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'Roboto-Medium',
          decoration: TextDecoration.none,
          fontSize: 17.0),
    );
  }

  Widget participantsTags() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is TaskLoaded) {
          return state.tasks.participants.length != 0
              ? Tags(
                  itemCount: _tasks.participants.length,
                  itemBuilder: (index) {
                    return ItemTags(
                      key: Key(index.toString()),
                      index: index,
                      title: _tasks.participants[index],
                      active: true,
                      textStyle: TextStyle(fontSize: 16),
                      combine: ItemTagsCombine.withTextBefore,
                      color: Theme.of(context).primaryColor,
                      activeColor: Theme.of(context).primaryColor,
                      textActiveColor: Colors.black,
                      removeButton: ItemTagsRemoveButton(
                        backgroundColor: Colors.white,
                        color: Colors.black,
                        onRemoved: () {
                          setState(() {
                            _tasks.participants.removeAt(index);
                          });

                          return true;
                        },
                      ),
                    );
                  },
                )
              : Text("No Participants",
                  style: TextStyle(color: Colors.black, fontSize: 16));
        } else
          return Container();
      },
    );
  }

  Widget subtaskText() {
    return Text(
      'SubTask',
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'Roboto-Medium',
          decoration: TextDecoration.none,
          fontSize: 17.0),
    );
  }

  Widget descriptionText() {
    return Text(
      'Description',
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'Roboto-Medium',
          decoration: TextDecoration.none,
          fontSize: 17.0),
    );
  }

  Widget description() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is TaskLoaded) {
          return Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(60)),
            child: Text(
                state.tasks.description != ""
                    ? state.tasks.description
                    : "No Description",
                style: TextStyle(color: Colors.black, fontSize: 16)),
          );
        } else
          return Container();
      },
    );
  }

  Widget listSubtask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
            padding: EdgeInsets.all(0.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _reoderableItems.length,
            itemBuilder: (context, index) {
              textControllerList.add(TextEditingController());
              focusNodeList.add(FocusNode());

              return ReoderableItem(
                data: _reoderableItems[index],
                controller: textControllerList[index],
                focusNode: focusNodeList[index],
                isFirst: index == 0,
                isLast: index == _reoderableItems.length - 1,
                draggingMode: DraggingMode.iOS,
                deleteCallback: deleteSubtask,
              );
            }),
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        DoughRecipe(
          data: DoughRecipeData(
            viscosity: 3000,
            expansion: 1.025,
          ),
          child: PressableDough(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _reoderableItems.add(ItemData(
                      Subtask(subtaskName: "", isDone: false),
                      ValueKey(_reoderableItems == null
                          ? 1
                          : _reoderableItems.length + 1)));
                });
              },
              child: Container(
                height: ScreenUtil().setWidth(100),
                width: ScreenUtil().setWidth(100),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(15)))),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget button() {
    return Visibility(
      visible: _showButton != null ? _showButton : true,
      child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingBottomButton(
              buttonFunction: _bottomButtonFunction,
              title: _tasks.isDone == false ? "MARK AS DONE" : "UNDONE TASKS")),
    );
  }
}
