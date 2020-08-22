part of 'database_bloc.dart';

abstract class DatabaseState extends Equatable {
  const DatabaseState();
}

class DatabaseInitial extends DatabaseState {
  @override
  List<Object> get props => [];
}

class DatabaseLoading extends DatabaseState {
  @override
  List<Object> get props => [];
}

class DatabaseLoaded extends DatabaseState {
  final List<Tasks> list;
  DatabaseLoaded({this.list});

  @override
  List<Object> get props => [list];
}

class DatabaseEmpty extends DatabaseState {
  @override
  List<Object> get props => [];
}

class TaskCreated extends DatabaseState {
  @override
  List<Object> get props => [];
}

class TaskUpdated extends DatabaseState {
  @override
  List<Object> get props => [];
}

class TaskDeleted extends DatabaseState {
  @override
  List<Object> get props => [];
}

class TaskLoaded extends DatabaseState {
  final Tasks tasks;
  TaskLoaded({this.tasks});

  @override
  List<Object> get props => [tasks];
}

class TaskByDateLoaded extends DatabaseState {
  final List<TimelineObject> list;
  TaskByDateLoaded({this.list});

  @override
  List<Object> get props => [list];
}

class HomePageTaskLoaded extends DatabaseState {
  final List<Tasks> recentlyList;
  final List<Tasks> todayList;
  final List<Tasks> upcomingList;
  final List<Tasks> laterList;
  final List<Tasks> pinnedList;
  HomePageTaskLoaded(
      {this.pinnedList,
      this.recentlyList,
      this.todayList,
      this.upcomingList,
      this.laterList});

  @override
  List<Object> get props =>
      [pinnedList, recentlyList, todayList, upcomingList, laterList];
}

class SearchTaskLoaded extends DatabaseState {
  final List<Tasks> list;
  final List<Tasks> listAllTasks;
  SearchTaskLoaded({this.list, this.listAllTasks});

  @override
  List<Object> get props => [list, listAllTasks];
}

class PinnedTaskLoaded extends DatabaseState {
  final List<Tasks> listTasks;
  PinnedTaskLoaded({this.listTasks});

  @override
  List<Object> get props => [listTasks];
}
