import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._repository) : super(const TasksState()) {
    on<TasksRequested>(_onRequested);
    on<TaskAdded>(_onAdded);
    on<TaskEdited>(_onEdited);
    on<TaskCompletionToggled>(_onCompletionToggled);
    on<TaskDeleted>(_onDeleted);
    on<TasksFilterChanged>(_onFilterChanged);
  }

  final TaskRepository _repository;

  Future<void> _onRequested(
    TasksRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final tasks = await _repository.getTasks();
      emit(state.copyWith(status: TasksStatus.success, tasks: tasks));
    } catch (error) {
      emit(state.copyWith(
        status: TasksStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onAdded(TaskAdded event, Emitter<TasksState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final task = await _repository.addTask(
        title: event.title,
        description: event.description,
      );
      emit(state.copyWith(
        isSubmitting: false,
        status: TasksStatus.success,
        tasks: [task, ...state.tasks],
      ));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, actionError: error.toString()));
    }
  }

  Future<void> _onEdited(TaskEdited event, Emitter<TasksState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final saved = await _repository.updateTask(event.task);
      emit(state.copyWith(
        isSubmitting: false,
        tasks: _replace(state.tasks, saved),
      ));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, actionError: error.toString()));
    }
  }

  Future<void> _onCompletionToggled(
    TaskCompletionToggled event,
    Emitter<TasksState> emit,
  ) async {
    final original = event.task;
    final toggled = original.copyWith(completed: !original.completed);
    emit(state.copyWith(tasks: _replace(state.tasks, toggled)));
    try {
      final saved = await _repository.updateTask(toggled);
      emit(state.copyWith(tasks: _replace(state.tasks, saved)));
    } catch (error) {
      emit(state.copyWith(
        tasks: _replace(state.tasks, original),
        actionError: error.toString(),
      ));
    }
  }

  Future<void> _onDeleted(TaskDeleted event, Emitter<TasksState> emit) async {
    final index = state.tasks.indexWhere((t) => t.id == event.task.id);
    emit(state.copyWith(
      tasks: state.tasks.where((t) => t.id != event.task.id).toList(),
    ));
    try {
      await _repository.deleteTask(event.task.id);
    } catch (error) {
      final restored = [...state.tasks];
      final position =
          index < 0 || index > restored.length ? restored.length : index;
      restored.insert(position, event.task);
      emit(state.copyWith(tasks: restored, actionError: error.toString()));
    }
  }

  void _onFilterChanged(TasksFilterChanged event, Emitter<TasksState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  List<Task> _replace(List<Task> tasks, Task updated) {
    return [
      for (final task in tasks) task.id == updated.id ? updated : task,
    ];
  }
}
