import 'package:task_manager/core/model/task_model.dart';
import 'package:timeline_node/timeline_node.dart';

class TimelineObject {
  final TimelineNodeStyle nodeStyle;
  final Tasks tasks;
  final int status;

  TimelineObject(this.nodeStyle, this.tasks, this.status);
}
