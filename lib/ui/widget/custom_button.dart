import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingBottomButton extends StatelessWidget {
  final Function buttonFunction;
  final String title;
  FloatingBottomButton({@required this.buttonFunction, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 50, right: 50.0, bottom: 20.0),
        child: GestureDetector(
          onTap: buttonFunction,
          child: Container(
              height: ScreenUtil().setHeight(140),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 4), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              child: Center(
                  child: Text(
                title,
                style: TextStyle(
                    fontFamily: 'Roboto-Bold',
                    color: Colors.black87,
                    fontSize: 15.0),
              ))),
        ));
  }
}
