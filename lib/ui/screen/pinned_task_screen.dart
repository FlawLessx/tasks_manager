import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/ui/widget/custom_card.dart';

import 'detail_screen.dart';

class PinnedTaskPage extends StatefulWidget {
  final Function onMenuTap;
  PinnedTaskPage({@required this.onMenuTap});

  @override
  _PinnedTaskPageState createState() => _PinnedTaskPageState();
}

class _PinnedTaskPageState extends State<PinnedTaskPage> {
  @override
  void initState() {
    refreshUI();
    super.initState();
  }

  void refreshUI() {
    BlocProvider.of<DatabaseBloc>(context).add(GetPinnedTask());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon: Icon(Icons.sort), onPressed: () => widget.onMenuTap.call()),
          elevation: 0.0,
          centerTitle: true,
          title: Text("Pinned Tasks"),
        ),
        body: BlocBuilder<DatabaseBloc, DatabaseState>(
          builder: (context, state) {
            if (state is PinnedTaskLoaded) {
              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
                child: GridView.builder(
                    itemCount: state.listTasks.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          //top: ScreenUtil().setWidth(20)
                        ),
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true)
                                  .push(CupertinoPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) => DetailTask(
                                            function: refreshUI,
                                            tasks: state.listTasks[index],
                                            fromNotification: false,
                                            taskId: null,
                                            fromEditor: false,
                                          ))),
                          child: CustomCard(
                              tasks: state.listTasks[index],
                              returnFunction: refreshUI,
                              colorIndex: 0),
                        ),
                      );
                    }),
              );
            } else if (state is DatabaseEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Center(
                        child: Container(
                            height: ScreenUtil().setWidth(600),
                            width: ScreenUtil().setWidth(600),
                            child: SvgPicture.asset(
                                'src/img/empty_task_person.svg')),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
