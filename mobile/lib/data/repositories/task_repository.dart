import '../api/task_api_client.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();

  Future<Task> addTask({required String title, String description = ''});

  Future<Task> updateTask(Task task);

  Future<void> deleteTask(String id);
}

class HttpTaskRepository implements TaskRepository {
  HttpTaskRepository(this._apiClient);

  final TaskApiClient _apiClient;

  @override
  Future<List<Task>> getTasks() => _apiClient.fetchTasks();

  @override
  Future<Task> addTask({required String title, String description = ''}) {
    return _apiClient.createTask(title: title, description: description);
  }

  @override
  Future<Task> updateTask(Task task) => _apiClient.updateTask(task);

  @override
  Future<void> deleteTask(String id) => _apiClient.deleteTask(id);
}
