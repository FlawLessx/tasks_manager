import '../model/task_model.dart';
import 'hive_provider.dart';

class HiveRepository {
  final hiveProvider = HiveProvider();

  Future createTask(Tasks tasks) => hiveProvider.createTask(tasks);
  Future<List<Tasks>> getAllTask() => hiveProvider.getAllTask();
  Future<Tasks> getTaskByID(int id) => hiveProvider.getTaskByID(id);
  Future updateTasks(int id, Tasks task) => hiveProvider.updateTasks(id, task);
  Future deleteTasks(int id) => hiveProvider.deleteTasks(id);
  Future deleteAll() => hiveProvider.deleteAll();
}
