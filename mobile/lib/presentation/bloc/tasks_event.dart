part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

final class TasksRequested extends TasksEvent {
  const TasksRequested();
}

final class TaskAdded extends TasksEvent {
  const TaskAdded({required this.title, this.description = ''});

  final String title;
  final String description;

  @override
  List<Object?> get props => [title, description];
}

final class TaskEdited extends TasksEvent {
  const TaskEdited(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskCompletionToggled extends TasksEvent {
  const TaskCompletionToggled(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskDeleted extends TasksEvent {
  const TaskDeleted(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TasksFilterChanged extends TasksEvent {
  const TasksFilterChanged(this.filter);

  final TasksFilter filter;

  @override
  List<Object?> get props => [filter];
}
