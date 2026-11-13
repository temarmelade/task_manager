import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task.dart';
import '../bloc/tasks_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/task_tile.dart';
import '../widgets/tasks_header.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  Future<void> _openForm(BuildContext context, {Task? task}) async {
    final bloc = context.read<TasksBloc>();
    final result = await Navigator.of(context).push<TaskFormResult>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(initialTask: task)),
    );
    if (result == null) return;
    if (task == null) {
      bloc.add(TaskAdded(title: result.title, description: result.description));
    } else {
      bloc.add(TaskEdited(
        task.copyWith(title: result.title, description: result.description),
      ));
    }
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<TasksBloc>()..add(const TasksRequested());
    await bloc.stream.firstWhere((s) => s.status != TasksStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TasksBloc>().add(const TasksRequested()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: BlocSelector<TasksBloc, TasksState, bool>(
            selector: (state) =>
                state.isSubmitting ||
                (state.status == TasksStatus.loading && state.tasks.isNotEmpty),
            builder: (context, busy) => busy
                ? const LinearProgressIndicator(minHeight: 4)
                : const SizedBox(height: 4),
          ),
        ),
      ),
      body: BlocConsumer<TasksBloc, TasksState>(
        listenWhen: (previous, current) =>
            current.actionError != null &&
            previous.actionError != current.actionError,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.actionError!)));
        },
        builder: (context, state) {
          final isFirstLoad = state.tasks.isEmpty &&
              (state.status == TasksStatus.initial ||
                  state.status == TasksStatus.loading);
          if (isFirstLoad) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == TasksStatus.failure && state.tasks.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Что-то пошло не так',
              onRetry: () =>
                  context.read<TasksBloc>().add(const TasksRequested()),
            );
          }

          final visible = state.visibleTasks;
          return Column(
            children: [
              TasksHeader(
                total: state.tasks.length,
                completed: state.completedCount,
                filter: state.filter,
                onFilterChanged: (filter) => context
                    .read<TasksBloc>()
                    .add(TasksFilterChanged(filter)),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: visible.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Icon(Icons.inbox_outlined, size: 64),
                            SizedBox(height: 12),
                            Center(child: Text('Здесь пока нет задач')),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final task = visible[index];
                            return TaskTile(
                              task: task,
                              onToggle: () => context
                                  .read<TasksBloc>()
                                  .add(TaskCompletionToggled(task)),
                              onDelete: () => context
                                  .read<TasksBloc>()
                                  .add(TaskDeleted(task)),
                              onTap: () => _openForm(context, task: task),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Задача'),
      ),
    );
  }
}
