import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/presentation/bloc/tasks_bloc.dart';

import 'fake_task_repository.dart';

void main() {
  final milk = Task(
    id: '1',
    title: 'Купить молоко',
    createdAt: DateTime(2026, 1, 1),
  );
  final report = Task(
    id: '2',
    title: 'Сдать отчёт',
    completed: true,
    createdAt: DateTime(2026, 1, 2),
  );

  group('TasksBloc', () {
    test('initial state is empty and initial', () {
      final bloc = TasksBloc(FakeTaskRepository());
      expect(bloc.state, const TasksState());
      bloc.close();
    });

    blocTest<TasksBloc, TasksState>(
      'loads tasks from repository',
      build: () => TasksBloc(FakeTaskRepository(initial: [milk, report])),
      act: (bloc) => bloc.add(const TasksRequested()),
      expect: () => [
        const TasksState(status: TasksStatus.loading),
        TasksState(status: TasksStatus.success, tasks: [milk, report]),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'emits failure when server is unavailable',
      build: () => TasksBloc(FakeTaskRepository(shouldFail: true)),
      act: (bloc) => bloc.add(const TasksRequested()),
      expect: () => [
        const TasksState(status: TasksStatus.loading),
        const TasksState(
          status: TasksStatus.failure,
          errorMessage: 'Нет соединения с сервером',
        ),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'adds a new task to the top of the list',
      build: () => TasksBloc(FakeTaskRepository(initial: [milk])),
      seed: () => TasksState(status: TasksStatus.success, tasks: [milk]),
      act: (bloc) => bloc.add(const TaskAdded(title: 'Новая')),
      expect: () => [
        TasksState(
          status: TasksStatus.success,
          tasks: [milk],
          isSubmitting: true,
        ),
        isA<TasksState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.tasks.length, 'length', 2)
            .having((s) => s.tasks.first.title, 'first title', 'Новая'),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'toggles completion optimistically',
      build: () => TasksBloc(FakeTaskRepository(initial: [milk])),
      seed: () => TasksState(status: TasksStatus.success, tasks: [milk]),
      act: (bloc) => bloc.add(TaskCompletionToggled(milk)),
      expect: () => [
        TasksState(
          status: TasksStatus.success,
          tasks: [milk.copyWith(completed: true)],
        ),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'rolls back toggle and reports error on failure',
      build: () => TasksBloc(FakeTaskRepository(shouldFail: true)),
      seed: () => TasksState(status: TasksStatus.success, tasks: [milk]),
      act: (bloc) => bloc.add(TaskCompletionToggled(milk)),
      expect: () => [
        TasksState(
          status: TasksStatus.success,
          tasks: [milk.copyWith(completed: true)],
        ),
        TasksState(
          status: TasksStatus.success,
          tasks: [milk],
          actionError: 'Нет соединения с сервером',
        ),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'removes deleted task',
      build: () => TasksBloc(FakeTaskRepository(initial: [milk, report])),
      seed: () => TasksState(status: TasksStatus.success, tasks: [milk, report]),
      act: (bloc) => bloc.add(TaskDeleted(milk)),
      expect: () => [
        TasksState(status: TasksStatus.success, tasks: [report]),
      ],
    );

    test('visibleTasks respects the selected filter', () {
      final state = TasksState(tasks: [milk, report]);
      expect(state.copyWith(filter: TasksFilter.active).visibleTasks, [milk]);
      expect(
        state.copyWith(filter: TasksFilter.completed).visibleTasks,
        [report],
      );
      expect(state.completedCount, 1);
    });
  });

  group('Task model', () {
    test('serializes to and from JSON', () {
      final json = milk.toJson();
      expect(Task.fromJson(json), milk);
    });
  });
}
