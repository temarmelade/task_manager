part of 'tasks_bloc.dart';

enum TasksStatus { initial, loading, success, failure }

enum TasksFilter { all, active, completed }

final class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.filter = TasksFilter.all,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionError,
  });

  final TasksStatus status;
  final List<Task> tasks;
  final TasksFilter filter;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionError;

  List<Task> get visibleTasks {
    return switch (filter) {
      TasksFilter.all => tasks,
      TasksFilter.active => tasks.where((t) => !t.completed).toList(),
      TasksFilter.completed => tasks.where((t) => t.completed).toList(),
    };
  }

  int get completedCount => tasks.where((t) => t.completed).length;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    TasksFilter? filter,
    bool? isSubmitting,
    String? errorMessage,
    String? actionError,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        filter,
        isSubmitting,
        errorMessage,
        actionError,
      ];
}
