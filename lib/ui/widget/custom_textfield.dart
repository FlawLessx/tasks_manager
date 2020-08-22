import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final IconData icon;
  final String hintText;
  final Function onTap;

  CustomTextfield(
      {@required this.textEditingController,
      @required this.focusNode,
      @required this.hintText,
      @required this.icon,
      @required this.onTap});

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            height: ScreenUtil().setWidth(100),
            child: TextField(
              focusNode: widget.focusNode,
              controller: widget.textEditingController,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.justify,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(fontSize: 14.0),
                contentPadding: EdgeInsets.only(top: 5, left: 5.0),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(60)),
            child: Container(
              color: Colors.amber,
              height: ScreenUtil().setWidth(110),
              width: ScreenUtil().setWidth(110),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: ScreenUtil().setWidth(60),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
