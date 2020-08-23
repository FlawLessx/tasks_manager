import 'package:flutter/material.dart';

Widget undoStateSnackBar(String title, Function function) {
  return SnackBar(
    content: Text(title),
    action: SnackBarAction(label: 'UNDO', onPressed: function),
  );
}
