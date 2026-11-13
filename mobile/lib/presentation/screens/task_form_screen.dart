import 'package:flutter/material.dart';

import '../../data/models/task.dart';

typedef TaskFormResult = ({String title, String description});

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.initialTask});

  final Task? initialTask;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialTask?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final TaskFormResult result = (
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактирование' : 'Новая задача'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: !_isEditing,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название задачи';
                  }
                  if (value.trim().length > 100) {
                    return 'Не больше 100 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(_isEditing ? 'Сохранить' : 'Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
