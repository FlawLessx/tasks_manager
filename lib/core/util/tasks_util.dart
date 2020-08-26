import 'package:task_manager/core/model/task_model.dart';

class TasksUtil {
  int getIndex(List<Tasks> list, String taskId) {
    int index = 0;

    for (int i = 0; i < list.length; i++) {
      list[i].taskId == taskId ? index = i : index = 0;
    }

    return index;
  }

  bool checkTaskIfNow(Tasks tasks) {
    bool status;
    final now = DateTime.now();
    final taskStartTime = DateTime(tasks.date.year, tasks.date.month,
        tasks.date.day, tasks.startTime.hour, tasks.startTime.minute);
    final tasksEndTime = DateTime(tasks.date.year, tasks.date.month,
        tasks.date.day, tasks.endTime.hour, tasks.endTime.minute);

    if (now.isAfter(taskStartTime) && now.isBefore(tasksEndTime))
      status = true;
    else
      status = false;

    return status;
  }

  bool checkTimeBasedTasks(DateTime startDate, DateTime endDate, Tasks tasks) {
    bool status;

    if (tasks.date.isAfter(startDate) && tasks.date.isBefore(endDate))
      status = true;
    else
      status = false;

    return status;
  }

  Tasks saveTasks(Tasks tasks, bool isDone, bool pinned) {
    return Tasks(
        taskId: tasks.taskId,
        taskName: tasks.taskName,
        description: tasks.description,
        place: tasks.place,
        category: tasks.category,
        date: tasks.date,
        startTime: tasks.startTime,
        endTime: tasks.endTime,
        participants: tasks.participants,
        subtask: tasks.subtask,
        isDone: isDone,
        pinned: tasks.pinned != null ? tasks.pinned : pinned);
  }
}
