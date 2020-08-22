import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

StatelessWidget cardLayout(
    String title,
    String description,
    List<String> participants,
    TimeOfDay startTime,
    int status,
    Function function) {
  if (status == 0)
    return CardLayout1(
      title: title,
      description: description,
      participants: participants,
      startTime: startTime,
      tapDoneFunction: function,
    );
  else if (status == 1)
    return CardLayout2(
        title: title,
        description: description,
        participants: participants,
        startTime: startTime);
  else
    return CardLayout3(
        title: title,
        description: description,
        participants: participants,
        startTime: startTime);
}

class CardLayout1 extends StatelessWidget {
  final String title;
  final String description;
  final List<String> participants;
  final TimeOfDay startTime;
  final Function tapDoneFunction;

  CardLayout1(
      {@required this.title,
      @required this.description,
      @required this.participants,
      @required this.startTime,
      this.tapDoneFunction});

  String convertToString() {
    var temp = participants.toString();
    temp = temp.replaceAll('[', '');
    temp = temp.replaceAll(']', '');
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 4),
            )
          ],
          color: Theme.of(context).primaryColor,
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30)))),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    title != null ? title : "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        color: Colors.black87,
                        fontSize: 16.0),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(20),
                ),
                Text(startTime != null ? '${startTime.format(context)}' : "",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontFamily: 'Roboto-Medium'))
              ],
            ),
            SizedBox(
              height: ScreenUtil().setHeight(15),
            ),
            Flexible(
              child: Text(description != null ? description : "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFFa27c17), fontSize: 14.0)),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(participants != null ? convertToString() : "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87, fontSize: 13.0)),
                InkWell(
                  onTap: tapDoneFunction,
                  child: Container(
                    height: ScreenUtil().setHeight(70),
                    width: ScreenUtil().setHeight(70),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 17.0,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CardLayout2 extends StatelessWidget {
  final String title;
  final String description;
  final List<String> participants;
  final TimeOfDay startTime;

  CardLayout2(
      {@required this.title,
      @required this.description,
      @required this.participants,
      @required this.startTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.6), width: 1.5),
          color: Colors.white,
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30)))),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    title != null ? title : "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Roboto-Medium',
                        color: Colors.black,
                        fontSize: 15.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(30)),
                Text(startTime != null ? '${startTime.format(context)}' : "",
                    style: TextStyle(
                        color: Colors.grey.withOpacity(0.9),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700))
              ],
            ),
            SizedBox(
              height: ScreenUtil().setHeight(30),
            ),
            Flexible(
              child: Text(description != null ? description : "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 13.0)),
            ),
          ],
        ),
      ),
    );
  }
}

class CardLayout3 extends StatelessWidget {
  final String title;
  final String description;
  final List<String> participants;
  final TimeOfDay startTime;

  CardLayout3(
      {@required this.title,
      @required this.description,
      @required this.participants,
      @required this.startTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.6), width: 1.5),
          color: Colors.white,
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30)))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                child: Center(
                  child: Text("DONE",
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.4),
                          fontSize: 30,
                          fontFamily: 'Roboto-Bold')),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title != null ? title : "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Roboto-Medium',
                            color: Colors.black,
                            fontSize: 15.0),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(30)),
                    Text(
                        startTime != null ? '${startTime.format(context)}' : "",
                        style: TextStyle(
                            color: Colors.grey.withOpacity(0.9),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Flexible(
                  child: Text(description != null ? description : "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 13.0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
