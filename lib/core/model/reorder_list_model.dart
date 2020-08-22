import 'package:flutter/material.dart';
import 'package:task_manager/core/model/task_model.dart';

class ItemData {
  ItemData(this.subtask, this.key);

  final Subtask subtask;

  // Each item in reorderable list needs stable and unique key
  final Key key;
}

enum DraggingMode {
  iOS,
  Android,
}
