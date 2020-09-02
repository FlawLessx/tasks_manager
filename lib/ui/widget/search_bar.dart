import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/core/model/task_model.dart';
import 'package:task_manager/ui/screen/detail_screen.dart';

class SearchBar extends SearchDelegate<Tasks> {
  final Bloc<DatabaseEvent, DatabaseState> databaseBloc;
  final Function function;
  SearchBar({@required this.databaseBloc, @required this.function});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
          function.call();
          FocusScope.of(context).unfocus();
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    databaseBloc.add(SearchTask(taskName: query));

    return body();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    databaseBloc.add(SearchTask(taskName: query));

    return body();
  }

  Widget body() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is SearchTaskLoaded)
          return ListView.builder(
              itemCount: state.list.length,
              itemBuilder: (context, index) => ListTile(
                    onTap: () {
                      print(state.list[index].taskName);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailTask(
                                  fromNotification: false,
                                  fromEditor: false,
                                  function: function,
                                  taskId: null,
                                  tasks: state.list[index])));
                    },
                    leading: Icon(
                      Icons.description,
                      size: ScreenUtil().setHeight(90),
                    ),
                    title: RichText(
                        text: TextSpan(
                            text: state.list[index].taskName
                                .substring(0, query.length),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                            children: [
                          TextSpan(
                              text: state.list[index].taskName
                                  .substring(query.length),
                              style: TextStyle(color: Colors.grey))
                        ])),
                    subtitle: Text(state.list[index].description),
                  ));
        else
          return Container();
      },
    );
  }
}
