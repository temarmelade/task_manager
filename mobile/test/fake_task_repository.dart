import 'package:task_manager/data/api/api_exception.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/repositories/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<Task> initial = const [], this.shouldFail = false})
      : _tasks = [...initial];

  final List<Task> _tasks;
  bool shouldFail;
  int _counter = 0;

  void _maybeFail() {
    if (shouldFail) throw const ApiException('Нет соединения с сервером');
  }

  @override
  Future<List<Task>> getTasks() async {
    _maybeFail();
    return List.of(_tasks);
  }

  @override
  Future<Task> addTask({required String title, String description = ''}) async {
    _maybeFail();
    _counter++;
    final task = Task(
      id: 'new-$_counter',
      title: title,
      description: description,
      createdAt: DateTime(2026, 1, 1),
    );
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    _maybeFail();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _maybeFail();
    _tasks.removeWhere((t) => t.id == id);
  }
}
