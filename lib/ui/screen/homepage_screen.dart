import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/core/bloc/database_bloc/database_bloc.dart';
import 'package:task_manager/core/model/card_color_data_model.dart';
import 'package:task_manager/core/model/task_model.dart';
import 'package:task_manager/core/model/text_time_category_model.dart';
import 'package:task_manager/core/resources/local_notification_helper.dart';
import 'package:task_manager/ui/screen/menu_dashboard_screen.dart';
import 'package:task_manager/ui/widget/custom_card.dart';
import 'package:task_manager/ui/widget/search_bar.dart';
import 'package:route_transitions/route_transitions.dart';
import 'add_task_screen.dart';
import 'detail_screen.dart';

class Home extends StatefulWidget {
  final Function onMenuTap;
  Home({this.onMenuTap});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _currentIndex;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Tasks> recentlyList = List();
  List<Tasks> todayList = List();
  List<Tasks> upcomingList = List();
  List<Tasks> laterList = List();
  int selectedDrawerIndex = 0;
  AnimationController animationController;
  CardColorList cardColorData = CardColorList();
  List<TextTimeCategory> textTimeCategoryItems = [
    TextTimeCategory(
      title: "Recently",
      index: 0,
    ),
    TextTimeCategory(
      title: "Today",
      index: 1,
    ),
    TextTimeCategory(
      title: "Upcoming",
      index: 2,
    ),
    TextTimeCategory(
      title: "Later",
      index: 3,
    )
  ];

  @override
  void initState() {
    _currentIndex = 0;
    refreshUI();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void refreshUI() {
    BlocProvider.of<DatabaseBloc>(context).add(GetHomePageTask());
  }

  //
  // REPLAY BLOC CURRENTLY NOT IMPLEMENTED DUE TO PLUGIN RESTRICTIVE
  /*
  void returnFunction() {
    final databaseBloc = BlocProvider.of<DatabaseBloc>(context);
    refreshUI();

    _scaffoldKey.currentState.showSnackBar(undoStateSnackBar("", () {
      databaseBloc
    }));
  }
  */

  @override
  Widget build(BuildContext context) {
    /*Timer.periodic(Duration(minutes: 1), (timer) {
      BlocProvider.of<DatabaseBloc>(context).add(GetHomePageTask());
    });*/

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => AddTask(
                      isNew: true,
                      function: refreshUI,
                      fromHome: true,
                      fromTaskPage: false,
                    )));
          },
          child: Icon(Icons.create),
        ),
        body: body());
  }

  Widget body() {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(60),
        right: ScreenUtil().setWidth(60),
        bottom: ScreenUtil().setHeight(40),
        top: ScreenUtil().setHeight(80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              profileImageMenu(),
              SizedBox(height: ScreenUtil().setHeight(50)),
              profileName(),
              SizedBox(height: ScreenUtil().setHeight(10)),
              sumTaskToday(),
              SizedBox(height: ScreenUtil().setHeight(70)),
              searchTask(),
            ],
          ),
          pinnedTask(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              showAllText(),
              SizedBox(height: ScreenUtil().setHeight(30)),
              rowTextTimeCategory(),
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              taskByCategory()
            ],
          )
        ],
      ),
    );
  }

  Widget profileImageMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(onTap: () => widget.onMenuTap.call(), child: Icon(Icons.sort)),
        GestureDetector(
          onTap: () {
            testNotification();
          },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(70)),
              child: Image.asset(
                'src/img/pic.jpg',
                height: ScreenUtil().setWidth(120),
                width: ScreenUtil().setWidth(120),
                filterQuality: FilterQuality.high,
                fit: BoxFit.fill,
              )),
        ),
      ],
    );
  }

  Widget profileName() {
    return Text('Hello, Yanuar',
        style: TextStyle(color: Color(0xFF3a3959), fontSize: 15));
  }

  Widget sumTaskToday() {
    return Row(
      children: <Widget>[
        BlocBuilder<DatabaseBloc, DatabaseState>(
          builder: (context, state) {
            if (state is HomePageTaskLoaded) {
              return Text(
                  state.todayList.length == 0
                      ? "No tasks for today"
                      : "You've got ${state.todayList.length} \ntasks today",
                  textScaleFactor: 1,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 27.0,
                      fontFamily: 'Roboto-Bold'));
            } else {
              return Text("No tasks for today",
                  textScaleFactor: 1,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 27.0,
                      fontFamily: 'Roboto-Bold'));
            }
          },
        ),
        SizedBox(
          width: ScreenUtil().setWidth(20),
        ),
        Container(
          height: ScreenUtil().setWidth(90),
          width: ScreenUtil().setWidth(90),
          child: Image.asset(
            'src/img/notepad.png',
            filterQuality: FilterQuality.high,
          ),
        )
      ],
    );
  }

  Widget searchTask() {
    return Container(
      height: ScreenUtil().setHeight(150),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(40)))),
      child: Center(
        child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Colors.black.withOpacity(0.7),
                  size: ScreenUtil().setWidth(80),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(15),
                ),
                Flexible(
                  child: TextField(
                      style: TextStyle(fontSize: 17),
                      cursorColor: Colors.black,
                      onTap: () {
                        showSearch(
                            context: context,
                            delegate: SearchBar(
                                function: refreshUI,
                                databaseBloc:
                                    BlocProvider.of<DatabaseBloc>(context)));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        border: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding:
                            EdgeInsets.only(bottom: 11, top: 10, right: 15),
                      )),
                ),
              ],
            )),
      ),
    );
  }

  Widget pinnedTask() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is HomePageTaskLoaded) {
          if (state.pinnedList == null || state.pinnedList.length == 0)
            return Container();
          else
            return GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => DetailTask(
                            tasks: state.pinnedList[0],
                            function: refreshUI,
                            fromNotification: false,
                          ))),
              child: Container(
                height: ScreenUtil().setHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 7,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(40),
                        horizontal: ScreenUtil().setWidth(60)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Text(state.pinnedList[0].taskName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto-Medium')),
                              ),
                              Text("You can start tracking",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                  ))
                            ],
                          ),
                        ),
                        Container(
                            width: 40,
                            height: 40.0,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Center(
                                child: Icon(
                              Icons.play_arrow,
                              color: Colors.black87,
                            )))
                      ],
                    )),
              ),
            );
        } else {
          return Container();
        }
      },
    );
  }

  Widget rowTextTimeCategory() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: textTimeCategoryItems
            .map((item) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = item.index;
                  });
                },
                child: Text(item.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: item.index == _currentIndex
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        fontSize: 16))))
            .toList());
  }

  Widget showAllText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'My Tasks',
          style: TextStyle(
              color: Colors.black, fontFamily: 'Roboto-Bold', fontSize: 22.0),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(PageRouteTransition(
                animationType: AnimationType.slide_right,
                curves: Curves.easeInOut,
                builder: (context) => MenuDashboard(currentIndexPage: 1)));
          },
          child: Text(
            'Show All',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto-Medium',
                fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  Widget taskByCategory() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is HomePageTaskLoaded) {
          recentlyList = state.recentlyList;
          todayList = state.todayList;
          upcomingList = state.upcomingList;
          laterList = state.laterList;

          return Container(
              height: ScreenUtil().setHeight(550),
              child: IndexedStack(
                index: _currentIndex,
                children: <Widget>[
                  listCard(recentlyList),
                  listCard(todayList),
                  listCard(upcomingList),
                  listCard(laterList)
                ],
              ));
        } else
          return Container();
      },
    );
  }

  Widget listCard(List<Tasks> listTasks) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(0.0),
        itemCount: listTasks.length,
        itemBuilder: (context, index) {
          int colorIndex = cardColorData.getIndex(index);

          return Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(15)),
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => DetailTask(
                            tasks: listTasks[index],
                            fromNotification: false,
                            taskId: null,
                          ))),
              child: Container(
                height: ScreenUtil().setWidth(500),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  child: CustomCard(
                    tasks: listTasks[index],
                    returnFunction: refreshUI,
                    colorIndex: colorIndex,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
