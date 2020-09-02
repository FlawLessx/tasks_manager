import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/bloc/database_bloc/database_bloc.dart';
import '../../core/model/popup_items_model.dart';
import '../../core/model/task_model.dart';
import '../../core/util/tasks_util.dart';

class PopupMenu extends StatelessWidget {
  final Tasks tasks;
  final Color color;
  final Function returnFunction;
  PopupMenu(
      {@required this.tasks,
      @required this.color,
      @required this.returnFunction});

  @override
  Widget build(BuildContext context) {
    //
    // VARIABLES
    List<PopupItems> listItem = [
      PopupItems(value: 0, icons: Icons.check, title: "Done"),
      PopupItems(value: 1, icons: Icons.delete, title: "Delete")
    ];
    TasksUtil _tasksUtil = TasksUtil();

    //
    // FUNCTION
    void onSelectedPopupMenuItems(Tasks tasks, int value) {
      if (value == 0) {
        BlocProvider.of<DatabaseBloc>(context)
            .add(UpdateTask(tasks: _tasksUtil.saveTasks(tasks, true, null)));
      } else {
        BlocProvider.of<DatabaseBloc>(context)
            .add(DeleteTask(tasksID: tasks.taskId));
      }
      //Navigator.pop(context);
      returnFunction.call();
    }

    return PopupMenuButton<int>(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30)))),
        onSelected: (value) => onSelectedPopupMenuItems(tasks, value),
        padding: EdgeInsets.zero,
        offset: Offset.zero,
        icon: Icon(Icons.more_vert, color: color),
        itemBuilder: (context) => listItem
            .map(
              (items) => PopupMenuItem(
                  value: items.value,
                  child: Row(
                    children: [
                      Icon(
                        items.icons,
                        color: Colors.grey,
                        size: ScreenUtil().setWidth(60),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(20),
                      ),
                      Text(
                        items.title,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      )
                    ],
                  )),
            )
            .toList());
  }
}
