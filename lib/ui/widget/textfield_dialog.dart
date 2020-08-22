import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextfieldDialog extends StatefulWidget {
  final Function function;
  TextfieldDialog({@required this.function});

  @override
  _TextfieldDialogState createState() => _TextfieldDialogState();
}

class _TextfieldDialogState extends State<TextfieldDialog> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40))),
        child: Container(
          height: ScreenUtil().setHeight(700),
          width: ScreenUtil().setWidth(700),
          child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(60)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Description',
                        style:
                            TextStyle(fontFamily: 'Roboto-Bold', fontSize: 17),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(30)),
                  TextFormField(
                    controller: controller,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Insert description here...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Color(0xFFfabb18),
                                  fontFamily: "Roboto-Medium"))),
                      SizedBox(
                        width: ScreenUtil().setWidth(40),
                      ),
                      GestureDetector(
                          onTap: () {
                            widget.function.call(controller.text);
                            Navigator.pop(context);
                          },
                          child: Text('OK',
                              style: TextStyle(
                                  color: Color(0xFFfabb18),
                                  fontFamily: "Roboto-Medium"))),
                    ],
                  )
                ],
              )),
        ));
  }
}
