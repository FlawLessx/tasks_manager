import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/ui/widget/custom_card.dart';

class PinnedTaskPage extends StatefulWidget {
  final Function onMenuTap;
  PinnedTaskPage({@required this.onMenuTap});

  @override
  _PinnedTaskPageState createState() => _PinnedTaskPageState();
}

class _PinnedTaskPageState extends State<PinnedTaskPage> {
  @override
  void initState() {
    BlocProvider.of<DatabaseBloc>(context).add(GetPinnedTask());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.menu), onPressed: () => widget.onMenuTap.call()),
          elevation: 0.0,
          title: Text("Pinned Tasks"),
        ),
        body: BlocBuilder<DatabaseBloc, DatabaseState>(
          builder: (context, state) {
            if (state is PinnedTaskLoaded) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(30)),
                  child: GridView.builder(
                      itemCount: state.listTasks.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        return CustomCard(
                            tasks: state.listTasks[index],
                            function: null,
                            colorIndex: 0);
                      }),
                ),
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
                            child: SvgPicture.asset(
                                'src/img/empty_task_person.svg')),
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
        ));
  }
}
