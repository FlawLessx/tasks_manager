import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:task_manager/core/model/card_color_data_model.dart';
import 'package:task_manager/core/model/category_model.dart';
import 'package:task_manager/core/model/task_model.dart';
import 'package:task_manager/ui/widget/popup_menu.dart';

class CustomCard extends StatelessWidget {
  final Tasks tasks;
  final Function function;
  final int colorIndex;
  CustomCard(
      {@required this.tasks,
      @required this.function,
      @required this.colorIndex});

  int _getMaxvalue(Tasks tasks) {
    int result;
    if (tasks.subtask == null || tasks.subtask.length == 0) {
      result = 10;
    } else {
      result = tasks.subtask.length;
    }

    return result;
  }

  int _getCurrentValue(Tasks tasks) {
    int result = 0;
    for (var item in tasks.subtask) {
      if (item.isDone == true) result++;
    }

    return result;
  }

  double _getPercentage(int maxValue, int currentValue) {
    return (currentValue / maxValue) * 100;
  }

  @override
  Widget build(BuildContext context) {
    //
    // VARIABLES
    CardColorList cardColorData = CardColorList();
    Category category = Category();
    int maxValue = _getMaxvalue(tasks);
    int currentValue = _getCurrentValue(tasks);
    double percentage = _getPercentage(maxValue, currentValue);

    return Container(
      decoration: BoxDecoration(
          color: cardColorData.listCardColorData[colorIndex].cardColor,
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setHeight(30))),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ]),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setHeight(30)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          tasks.taskName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: cardColorData
                                  .listCardColorData[colorIndex].fontColor,
                              fontFamily: 'Roboto-Medium',
                              fontSize: 14.0),
                        ),
                      ),
                      Container(
                          height: 30,
                          width: 20,
                          child: PopupMenu(
                              tasks: tasks,
                              color: cardColorData
                                  .listCardColorData[colorIndex].fontColor))
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(20)),
                  Flexible(
                    child: Text(
                      tasks.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 13.0),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  category.icon[tasks.category],
                  color: cardColorData.listCardColorData[colorIndex].fontColor,
                  size: ScreenUtil().setWidth(60),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Progress',
                      style: TextStyle(
                          color: cardColorData
                              .listCardColorData[colorIndex].fontColor,
                          fontFamily: 'Roboto-Medium',
                          fontSize: 13.0),
                    ),
                    Text(
                      '$percentage',
                      style: TextStyle(
                          color: cardColorData
                              .listCardColorData[colorIndex].progressColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.0),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(15)),
                FAProgressBar(
                    size: ScreenUtil().setHeight(30),
                    maxValue: maxValue,
                    currentValue: currentValue,
                    progressColor: cardColorData
                        .listCardColorData[colorIndex].progressColor,
                    backgroundColor: cardColorData
                        .listCardColorData[colorIndex].backgroundProgressColor)
              ],
            )
          ],
        ),
      ),
    );
  }
}
