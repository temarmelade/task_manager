import 'package:flutter/material.dart';

import '../../data/models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('«${task.title}» будет удалена без возможности восстановления.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      decoration: task.completed ? TextDecoration.lineThrough : null,
      color: task.completed ? theme.colorScheme.outline : null,
    );

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => onToggle(),
        ),
        title: Text(task.title, style: titleStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              _formatDate(task.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
