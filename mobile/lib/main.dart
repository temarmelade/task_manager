import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/app_config.dart';
import 'data/api/task_api_client.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/bloc/tasks_bloc.dart';
import 'presentation/screens/tasks_screen.dart';

void main() {
  final apiClient = TaskApiClient(
    httpClient: http.Client(),
    baseUrl: AppConfig.baseUrl,
  );
  final repository = HttpTaskRepository(apiClient);
  runApp(TaskManagerApp(repository: repository));
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key, required this.repository});

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TaskRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (_) => TasksBloc(repository)..add(const TasksRequested()),
        child: MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            useMaterial3: true,
          ),
          home: const TasksScreen(),
        ),
      ),
    );
  }
}
