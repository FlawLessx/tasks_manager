import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';

class TimePicker extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function function;
  TimePicker(
      {@required this.function,
      @required this.startTime,
      @required this.endTime});

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  //
  // VARIABLES
  TimeOfDay now = TimeOfDay.now();
  TimeOfDay startTime;
  TimeOfDay endTime;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final formal = DateFormat.jm();
  bool returnStartTimeNotNull = true;
  bool returnEndTimeNotNull = true;

  //
  // FUNCTION
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

  void checkInitialTime() {
    if (widget.startTime != null || widget.endTime != null) {
      setState(() {
        startTime = widget.startTime;
        endTime = widget.endTime;
        startTimeController.text = widget.startTime.format(context);
        endTimeController.text = widget.endTime.format(context);
      });
    }
  }

  void checkReturnTime() {
    setState(() {
      startTime == null
          ? returnStartTimeNotNull = false
          : returnStartTimeNotNull = true;

      endTime == null
          ? returnEndTimeNotNull = false
          : returnEndTimeNotNull = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkInitialTime();

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
                    if (startTime != null) {
                      returnStartTimeNotNull = true;
                      startTimeController.text = startTime.format(context);
                    }
                  });
                },
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: returnEndTimeNotNull == true
                              ? Theme.of(context).primaryColor
                              : Colors.red)),
                  contentPadding: EdgeInsets.all(0.0),
                  labelText: returnStartTimeNotNull == true
                      ? 'Start'
                      : "Please select start time",
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: returnStartTimeNotNull == true
                          ? Theme.of(context).primaryColor
                          : Colors.red),
                ),
              ),
              TextField(
                enabled: startTime != null ? true : false,
                controller: endTimeController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  endTime = await _selectTime(context, true);
                  setState(() {
                    if (endTime != null) {
                      {
                        endTimeController.text = endTime.format(context);
                        returnEndTimeNotNull = true;
                      }
                    }
                  });
                },
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: returnEndTimeNotNull == true
                                ? Theme.of(context).primaryColor
                                : Colors.red)),
                    contentPadding: EdgeInsets.all(0.0),
                    labelText: returnEndTimeNotNull == true
                        ? 'End'
                        : "Please select end time",
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: returnEndTimeNotNull == true
                            ? Theme.of(context).primaryColor
                            : Colors.red)),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('CANCEL',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: "Roboto-Medium"))),
                  SizedBox(
                    width: ScreenUtil().setWidth(40),
                  ),
                  GestureDetector(
                      onTap: () {
                        checkReturnTime();

                        if (returnStartTimeNotNull == true &&
                            returnEndTimeNotNull == true) {
                          widget.function(startTime, endTime);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('OK',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
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
