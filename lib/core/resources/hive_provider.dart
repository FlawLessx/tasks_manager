import 'package:hive/hive.dart';
import 'package:task_manager/core/model/task_model.dart';

class HiveProvider {
  HiveProvider() : super() {
    _openBox();
  }

  Box box;

  //
  // OPEN HIVE DATABASE
  Future _openBox() async {
    print('Open Box Running');
    await Hive.openBox('taskManager');
    return;
  }

  //
  // CREATE DATA
  Future createTask(Tasks tasks) async {
    box = Hive.box('taskManager');
    box.add(tasks);
    return;
  }

  //
  // READ DATA
  Future<List<Tasks>> getAllTask() async {
    box = Hive.box('taskManager');
    Map<dynamic, dynamic> data = box.toMap();
    List<Tasks> list = List();

    if (data == null) return null;

    data.forEach((key, value) {
      list.add(value);
    });

    return list;
  }

  Future<Tasks> getTaskByID(int id) async {
    box = Hive.box('taskManager');
    Tasks task = await box.getAt(id);
    return task;
  }

  //
  // DELETE DATA
  Future updateTasks(int id, Tasks task) async {
    box = Hive.box('taskManager');
    await box.putAt(id, task);
  }

  Future deleteTasks(int id) async {
    box = Hive.box('taskManager');
    await box.deleteAt(id);
  }

  Future deleteAll() {
    box = Hive.box('taskManager');
    box.clear();
    return null;
  }
}
