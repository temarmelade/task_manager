import 'package:flutter/material.dart';

import '../bloc/tasks_bloc.dart';

class TasksHeader extends StatelessWidget {
  const TasksHeader({
    super.key,
    required this.total,
    required this.completed,
    required this.filter,
    required this.onFilterChanged,
  });

  final int total;
  final int completed;
  final TasksFilter filter;
  final ValueChanged<TasksFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Выполнено $completed из $total',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TasksFilter>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: TasksFilter.all, label: Text('Все')),
              ButtonSegment(value: TasksFilter.active, label: Text('Активные')),
              ButtonSegment(value: TasksFilter.completed, label: Text('Готово')),
            ],
            selected: {filter},
            onSelectionChanged: (selection) => onFilterChanged(selection.first),
          ),
        ],
      ),
    );
  }
}
