import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      completed: (json['completed'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? title,
    String? description,
    bool? completed,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, completed, createdAt];
}
