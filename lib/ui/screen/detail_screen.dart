import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/core/model/reorder_list_model.dart';
import 'package:task_manager/ui/screen/add_task_screen.dart';
import 'package:task_manager/ui/widget/custom_button.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:task_manager/core/model/task_detail_model.dart';
import 'package:task_manager/core/model/task_model.dart';
import 'package:task_manager/ui/widget/detail_task.dart';
import 'package:task_manager/ui/widget/reorderable_item.dart';

import 'menu_dashboard_screen.dart';

class DetailTask extends StatefulWidget {
  final Tasks tasks;
  final String taskId;
  final Function function;
  final bool fromNotification;
  DetailTask(
      {@required this.tasks,
      this.function,
      this.taskId,
      @required this.fromNotification});

  @override
  _DetailTaskState createState() => _DetailTaskState();
}

class _DetailTaskState extends State<DetailTask> {
  ScrollController _scrollController;
  bool lastStatus = true;
  List<String> data = List();
  Tasks _tasks = Tasks();
  List<ItemData> reoderableItems = List();
  List<TextEditingController> listController = [];

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    refreshUI();
    super.initState();
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

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

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
        subtask: getSubtask(),
        isDone: isDone);
  }

  void deleteSubtask(Key key) {
    int index = _indexOfKey(key);
    setState(() {
      reoderableItems.removeAt(index);
    });
  }

  List<Subtask> getSubtask() {
    List<Subtask> subtaskList = List();
    for (var item in reoderableItems) {
      subtaskList.add(item.subtask);
    }
    return subtaskList;
  }

  int _indexOfKey(Key key) {
    return reoderableItems.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = reoderableItems[draggingIndex];
    setState(() {
      reoderableItems.removeAt(draggingIndex);
      reoderableItems.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (widget.fromNotification == false) {
            BlocProvider.of<DatabaseBloc>(context)
                .add(UpdateTask(tasks: _saveTasks(_tasks, _tasks.isDone)));
            Navigator.pop(context);
            widget.function.call();
          } else {
            BlocProvider.of<DatabaseBloc>(context).add(GetHomePageTask());
            Navigator.of(context).push(PageRouteTransition(
                animationType: AnimationType.slide_left,
                curves: Curves.easeInOut,
                fullscreenDialog: true,
                maintainState: true,
                builder: (context) => MenuDashboard(currentIndexPage: 0)));
          }

          return true;
        },
        child: Scaffold(
            body: BlocListener<DatabaseBloc, DatabaseState>(
          listener: (context, state) {
            if (state is TaskLoaded) {
              for (var i = 0; i < state.tasks.subtask.length; i++) {
                setState(() {
                  _tasks = state.tasks;
                  reoderableItems
                      .add(ItemData(state.tasks.subtask[i], ValueKey(i)));
                });
              }
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
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(60),
                  vertical: ScreenUtil().setHeight(60)),
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
                participantsTags(),
                SizedBox(height: ScreenUtil().setHeight(30)),
                subtaskText(),
                SizedBox(height: ScreenUtil().setHeight(30)),
                listSubtask(),
                SizedBox(height: ScreenUtil().setHeight(250)),
              ],
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
        onTap: () {
          if (widget.fromNotification == false) {
            BlocProvider.of<DatabaseBloc>(context)
                .add(UpdateTask(tasks: _saveTasks(_tasks, _tasks.isDone)));
            Navigator.pop(context);
            widget.function.call();
          } else {
            BlocProvider.of<DatabaseBloc>(context).add(GetHomePageTask());
            Navigator.of(context).push(PageRouteTransition(
                animationType: AnimationType.slide_left,
                curves: Curves.easeInOut,
                fullscreenDialog: true,
                maintainState: true,
                builder: (context) => MenuDashboard(currentIndexPage: 0)));
          }
        },
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
        IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
        IconButton(
            icon: Icon(Icons.mode_edit),
            onPressed: () {
              reoderableItems.clear();
              Navigator.of(context).push(PageRouteTransition(
                  animationType: AnimationType.slide_right,
                  curves: Curves.easeInOut,
                  builder: (context) => AddTask(
                        isNew: false,
                        function: refreshUI,
                        task: _tasks,
                        fromHome: false,
                        fromTaskPage: false,
                      )));
            }),
        IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              BlocProvider.of<DatabaseBloc>(context)
                  .add(DeleteTask(tasks: widget.tasks));
              widget.function.call();
              Navigator.pop(context);
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
                    left: 20,
                    top: 90,
                    child: Container(
                      height: ScreenUtil().setHeight(600),
                      width: ScreenUtil().setWidth(1000),
                      child: Text(
                        state.tasks.taskName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                            fontFamily: 'Roboto-Bold',
                            fontSize: 20,
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
          fontSize: 16.0),
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
          fontSize: 16.0),
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
                      combine: ItemTagsCombine.withTextBefore,
                      color: Theme.of(context).primaryColor,
                      activeColor: Theme.of(context).primaryColor,
                      removeButton: ItemTagsRemoveButton(
                        backgroundColor: Colors.white,
                        color: Theme.of(context).primaryColor,
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
              : Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(60)),
                  child: Text(
                      state.tasks.description != ""
                          ? state.tasks.description
                          : "No Description",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                );
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
          fontSize: 16.0),
    );
  }

  Widget descriptionText() {
    return Text(
      'Description',
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'Roboto-Medium',
          decoration: TextDecoration.none,
          fontSize: 16.0),
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
                style: TextStyle(
                  color: Colors.black,
                )),
          );
        } else
          return Container();
      },
    );
  }

  Widget listSubtask() {
    return ListView.builder(
        padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: reoderableItems.length,
        itemBuilder: (context, index) {
          listController.add(TextEditingController());

          return ReoderableItem(
            data: reoderableItems[index],
            isFirst: index == 0,
            isLast: index == reoderableItems.length - 1,
            draggingMode: DraggingMode.iOS,
            deleteCallback: deleteSubtask,
            controller: listController[index],
          );
        });
  }

  Widget button() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: FloatingBottomButton(
            buttonFunction: () {
              getSubtask();
              BlocProvider.of<DatabaseBloc>(context).add(UpdateTask(
                  tasks: _tasks.saveTasks(
                      _tasks, _tasks.isDone == false ? true : false, null)));
              widget.function.call();
              Navigator.pop(context);
            },
            title: _tasks.isDone == false ? "MARK AS DONE" : "UNDONE TASKS"));
  }
}
