import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:task_manager/core/model/notification_model.dart';
import 'package:task_manager/ui/screen/detail_screen.dart';
import 'package:task_manager/ui/screen/pinned_task_screen.dart';
import 'package:task_manager/ui/screen/tasks_page_screen.dart';
import 'homepage_screen.dart';
import 'package:task_manager/main.dart';

class MenuDashboard extends StatefulWidget {
  final int currentIndexPage;
  MenuDashboard({@required this.currentIndexPage});

  @override
  _MenuDashboardState createState() => _MenuDashboardState();
}

class _MenuDashboardState extends State<MenuDashboard>
    with TickerProviderStateMixin {
  FancyDrawerController drawerController;
  int currentIndexPage;

  @override
  void initState() {
    drawerController = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {}); // Must call setState
      });
    currentIndexPage = widget.currentIndexPage;

    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    super.initState();
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    drawerController.dispose();
    super.dispose();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
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
                      taskId: receivedNotification.payload,
                      tasks: null,
                      fromNotification: true,
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

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailTask(
                  taskId: payload,
                  tasks: null,
                  fromNotification: true,
                )),
      );
    });
  }

  Widget page(
    int index,
    Function function,
  ) {
    if (index == 0)
      return Home(
        onMenuTap: function,
      );
    else if (index == 1)
      return TasksPage(
        onMenuTap: function,
      );
    else
      return PinnedTaskPage(
        onMenuTap: function,
      );
  }

  onMenuTap() {
    drawerController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);

    return Material(
      child: FancyDrawerWrapper(
          backgroundColor: Colors.black.withOpacity(0.9),
          drawerItems: [
            menuItems(() {
              setState(() {
                currentIndexPage = 0;
              });
            }, Icons.home, "Home"),
            menuItems(() {
              setState(() {
                currentIndexPage = 1;
              });
            }, Icons.home, "All Tasks"),
            menuItems(() {
              setState(() {
                currentIndexPage = 2;
              });
            }, FontAwesomeIcons.pinterest, "Pinned Tasks")
          ],
          child: page(currentIndexPage, onMenuTap),
          controller: drawerController),
    );
  }

  Widget menuItems(Function function, IconData icons, String title) {
    return GestureDetector(
      onTap: function,
      child: Row(children: [
        Container(
          height: ScreenUtil().setHeight(80),
          width: ScreenUtil().setWidth(20),
          color: currentIndexPage == 0 ? Colors.white : Colors.transparent,
        ),
        SizedBox(
          width: ScreenUtil().setWidth(40),
        ),
        Icon(
          icons,
          color: Colors.white,
          size: 22,
        ),
        SizedBox(
          width: ScreenUtil().setWidth(50),
        ),
        Text(
          title,
          style: TextStyle(
              color: Colors.white, fontFamily: 'Roboto-Medium', fontSize: 18),
        )
      ]),
    );
  }
}
