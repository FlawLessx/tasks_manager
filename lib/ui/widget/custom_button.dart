import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingBottomButton extends StatelessWidget {
  final Function buttonFunction;
  final String title;
  FloatingBottomButton({@required this.buttonFunction, @required this.title});

  @override
  Widget build(BuildContext context) {
    return DoughRecipe(
      data: DoughRecipeData(
        viscosity: 3000,
        expansion: 1.025,
      ),
      child: PressableDough(
        child: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(140),
                right: ScreenUtil().setWidth(140),
                bottom: ScreenUtil().setHeight(60)),
            child: GestureDetector(
              onTap: buttonFunction,
              child: Container(
                  height: ScreenUtil().setHeight(140),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(40)))),
                  child: Center(
                      child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        color: Colors.black,
                        fontSize: 15.0),
                  ))),
            )),
      ),
    );
  }
}
