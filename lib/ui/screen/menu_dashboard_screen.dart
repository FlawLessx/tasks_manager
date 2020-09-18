import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_manager/core/model/notification_model.dart';
import 'package:task_manager/core/util/local_notification_helper.dart';

import '../../main.dart';
import 'detail_screen.dart';
import 'homepage_screen.dart';
import 'pinned_task_screen.dart';
import 'all_task_screen.dart';

class MenuDashboard extends StatefulWidget {
  final int currentIndexPage;
  MenuDashboard({@required this.currentIndexPage});

  @override
  _MenuDashboardState createState() => _MenuDashboardState();
}

class _MenuDashboardState extends State<MenuDashboard>
    with TickerProviderStateMixin {
  //
  //  VARIABLE
  //
  FancyDrawerController drawerController;
  int currentIndexPage;

  //
  // INITSTATE & DISPOSE
  //
  @override
  void initState() {
    requestPermission();
    notificationPlugin.requestIOSPermissions();
    if (didReceiveLocalNotificationSubject.isClosed == false)
      configureDidReceiveLocalNotificationSubject();
    if (selectNotification.isClosed == false)
      configureSelectNotificationSubject();
    drawerController = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {}); // Must call setState
      });
    currentIndexPage = widget.currentIndexPage;

    super.initState();
  }

  @override
  void dispose() {
    drawerController.dispose();
    //didReceiveLocalNotificationSubject.close();
    //selectNotification.close();
    super.dispose();
  }

  //
  // SELECTED NOTIFICATION
  //
  void configureSelectNotificationSubject() {
    selectNotification.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailTask(
                taskId: payload,
                tasks: null,
                function: null,
                fromNotification: true,
                fromEditor: false)),
      );
    });
  }

  void configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailTask(
                      function: null,
                      taskId: receivedNotification.payload,
                      tasks: null,
                      fromNotification: true,
                      fromEditor: false,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      );
    });
  }

  //
  // PERMISSION HANDLER
  //
  void requestPermission() async {
    await [
      Permission.notification,
      Permission.storage,
    ].request();
  }

  //
  // PAGE FUNCTION
  //
  StatefulWidget page(
    int index,
    Function function,
  ) {
    if (index == 0)
      return Home(
        onMenuTap: function,
      );
    else if (index == 1)
      return AllTask(
        onMenuTap: function,
        fromMenu: true,
      );
    else
      return PinnedTaskPage(
        onMenuTap: function,
      );
  }

  onMenuTap() {
    drawerController.toggle();
  }

  //
  // PAGE BUILDER
  //
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);

    return Material(
      child: FancyDrawerWrapper(
          backgroundColor: Colors.black.withOpacity(0.92),
          drawerItems: [
            menuItems(70, () {
              setState(() {
                currentIndexPage = 0;
              });
            }, Icons.home, "Home", 0),
            menuItems(60, () {
              setState(() {
                currentIndexPage = 1;
              });
            }, FontAwesomeIcons.tasks, "All Tasks", 1),
            menuItems(60, () {
              setState(() {
                currentIndexPage = 2;
              });
            }, FontAwesomeIcons.thumbtack, "Pinned Tasks", 2)
          ],
          child: page(currentIndexPage, onMenuTap),
          controller: drawerController),
    );
  }

  Widget menuItems(double iconSize, Function function, IconData icons,
      String title, int index) {
    return InkWell(
      onTap: function,
      child: Row(children: [
        Container(
          height: ScreenUtil().setHeight(80),
          width: ScreenUtil().setWidth(15),
          color: currentIndexPage == index ? Colors.white : Colors.transparent,
        ),
        SizedBox(
          width: ScreenUtil().setWidth(40),
        ),
        Icon(
          icons,
          color: Colors.white,
          size: ScreenUtil().setWidth(iconSize),
        ),
        SizedBox(
          width: ScreenUtil().setWidth(50),
        ),
        Text(title,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Roboto-Medium', fontSize: 16))
      ]),
    );
  }
}
