import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/main.dart';

import 'fake_task_repository.dart';

void main() {
  testWidgets('shows tasks loaded from repository', (tester) async {
    final repository = FakeTaskRepository(initial: [
      Task(id: '1', title: 'Купить молоко', createdAt: DateTime(2026, 1, 1)),
    ]);

    await tester.pumpWidget(TaskManagerApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Мои задачи'), findsOneWidget);
    expect(find.text('Купить молоко'), findsOneWidget);
    expect(find.text('Выполнено 0 из 1'), findsOneWidget);
  });

  testWidgets('shows error view when server is unavailable', (tester) async {
    final repository = FakeTaskRepository(shouldFail: true);

    await tester.pumpWidget(TaskManagerApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}
