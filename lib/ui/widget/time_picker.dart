import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';

class TimePicker extends StatefulWidget {
  final Function function;
  TimePicker(this.function);

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay now = TimeOfDay.now();
  TimeOfDay startTime;
  TimeOfDay endTime;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final formal = DateFormat.jm();

  Future<TimeOfDay> _selectTime(BuildContext context, bool isEndTime) async {
    if (startTime != null) {
      var hour = startTime.hour + 1;
      endTime = TimeOfDay(hour: hour, minute: startTime.minute);
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: (isEndTime == false) ? now : endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFfabb18),
            accentColor: const Color(0xFFfabb18),
            colorScheme: ColorScheme.light(primary: const Color(0xFFfabb18)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child,
        );
      },
    );

    if (picked != null && picked != TimeOfDay.now()) setState(() {});

    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40))),
      child: Container(
        height: ScreenUtil().setHeight(700),
        width: ScreenUtil().setHeight(700),
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(60)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add Time',
                style: TextStyle(fontFamily: 'Roboto-Bold', fontSize: 17),
              ),
              TextField(
                controller: startTimeController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  startTime = await _selectTime(context, false);
                  setState(() {
                    if (startTime != null)
                      startTimeController.text = startTime.format(context);
                  });
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    labelText: 'Start',
                    labelStyle: TextStyle(color: Color(0xFFfabb18))),
              ),
              TextField(
                enabled: startTime != null ? true : false,
                controller: endTimeController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  endTime = await _selectTime(context, true);
                  setState(() {
                    if (endTime != null) {
                      endTimeController.text = endTime.format(context);
                    }
                  });
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    labelText: 'End',
                    labelStyle: TextStyle(color: Color(0xFFfabb18))),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('CANCEL',
                          style: TextStyle(
                              color: Color(0xFFfabb18),
                              fontFamily: "Roboto-Medium"))),
                  SizedBox(
                    width: ScreenUtil().setWidth(40),
                  ),
                  GestureDetector(
                      onTap: () {
                        widget.function(startTime, endTime);
                        Navigator.pop(context);
                      },
                      child: Text('OK',
                          style: TextStyle(
                              color: Color(0xFFfabb18),
                              fontFamily: "Roboto-Medium"))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
