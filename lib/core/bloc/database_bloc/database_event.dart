part of 'database_bloc.dart';

abstract class DatabaseEvent extends Equatable {
  const DatabaseEvent();
}

class GetAllTask extends DatabaseEvent {
  @override
  List<Object> get props => [];
}

class GetTaskByDate extends DatabaseEvent {
  final DateTime date;
  GetTaskByDate({@required this.date});

  @override
  List<Object> get props => [date];
}

class GetTask extends DatabaseEvent {
  final Tasks tasks;
  final String taskId;
  GetTask({this.tasks, this.taskId});

  @override
  List<Object> get props => [tasks, taskId];
}

class CreateTask extends DatabaseEvent {
  final Tasks tasks;
  CreateTask({@required this.tasks});

  @override
  List<Object> get props => [tasks];
}

class UpdateTask extends DatabaseEvent {
  final Tasks tasks;
  UpdateTask({@required this.tasks});

  @override
  List<Object> get props => [tasks];
}

class DeleteTask extends DatabaseEvent {
  final String tasksID;
  DeleteTask({@required this.tasksID});

  @override
  List<Object> get props => [tasksID];
}

class GetHomePageTask extends DatabaseEvent {
  @override
  List<Object> get props => [];
}

class SearchTask extends DatabaseEvent {
  final String taskName;
  SearchTask({@required this.taskName})
      : assert(taskName != null, 'taskName can"t be null');

  @override
  List<Object> get props => [taskName];
}

class GetPinnedTask extends DatabaseEvent {
  @override
  List<Object> get props => [];
}
