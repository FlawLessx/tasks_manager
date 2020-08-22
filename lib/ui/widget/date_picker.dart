import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

Future<DateTime> selectDate(BuildContext context) async {
  final initialDate = DateTime.now();

  final DateTime picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101));
  if (picked != null) {
    return picked;
  } else
    return null;
}
