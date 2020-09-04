import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/ui/screen/task_editor_screen.dart';
import 'package:task_manager/ui/screen/detail_screen.dart';
import 'package:task_manager/ui/screen/menu_dashboard_screen.dart';

import '../../main.dart';

class RouteGenerator {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return CupertinoPageRoute(
            builder: (_) => MenuDashboard(currentIndexPage: 0),
            settings: settings);
        break;
      case allTaskRoute:
        return CupertinoPageRoute(
            builder: (_) => MenuDashboard(currentIndexPage: 1),
            settings: settings);
        break;
      case pinnedRoute:
        return CupertinoPageRoute(
            builder: (_) => MenuDashboard(currentIndexPage: 2),
            settings: settings);
        break;
      case taskEditorRoute:
        var args = settings.arguments as TaskEditorArguments;
        return CupertinoPageRoute(
            builder: (_) => TaskEditor(
                isNew: args.isNew,
                function: args.function,
                fromHome: args.fromHome,
                fromTaskPage: args.fromTaskPage),
            settings: settings,
            fullscreenDialog: true);
        break;
      case detailTaskRoute:
        var args = settings.arguments as DetailTaskArguments;
        return CupertinoPageRoute(
            builder: (_) => DetailTask(
                tasks: args.tasks,
                function: args.function,
                fromNotification: args.fromNotification,
                fromEditor: args.fromEditor),
            settings: settings,
            fullscreenDialog: true);
        break;
      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ),
            settings: settings);
    }
  }
}
