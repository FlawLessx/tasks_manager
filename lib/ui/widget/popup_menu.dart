import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/core/model/task_model.dart';

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
    // FUNCTION
    void onSelectedPopupMenuItems(Tasks tasks, int value) {
      if (value == 0) {
        BlocProvider.of<DatabaseBloc>(context)
            .add(UpdateTask(tasks: tasks.saveTasks(tasks, true, null)));
        Navigator.pop(context);
        returnFunction.call();
      } else {
        BlocProvider.of<DatabaseBloc>(context).add(DeleteTask(tasks: tasks));
        Navigator.pop(context);
        returnFunction.call();
      }
    }

    return PopupMenuButton<int>(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30)))),
        onSelected: (value) => onSelectedPopupMenuItems(tasks, value),
        padding: EdgeInsets.zero,
        offset: Offset.zero,
        icon: Icon(Icons.more_vert, color: color),
        itemBuilder: (context) => [
              PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.grey,
                        size: ScreenUtil().setWidth(30),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(20),
                      ),
                      Text(
                        "Done",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.grey,
                        size: ScreenUtil().setWidth(30),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(20),
                      ),
                      Text(
                        "Delete",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    ],
                  )),
            ]);
  }
}
