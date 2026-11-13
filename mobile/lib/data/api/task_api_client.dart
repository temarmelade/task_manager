import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.dart';
import 'api_exception.dart';

class TaskApiClient {
  TaskApiClient({
    required http.Client httpClient,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _baseUrl = baseUrl;

  final http.Client _httpClient;
  final String _baseUrl;

  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<Task>> fetchTasks() async {
    final response = await _send(() => _httpClient.get(_uri('/tasks')));
    final data = _decode(response) as List<dynamic>;
    return data
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Task> createTask({
    required String title,
    String description = '',
  }) async {
    final response = await _send(
      () => _httpClient.post(
        _uri('/tasks'),
        headers: _headers,
        body: jsonEncode({'title': title, 'description': description}),
      ),
    );
    return Task.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<Task> updateTask(Task task) async {
    final response = await _send(
      () => _httpClient.put(
        _uri('/tasks/${task.id}'),
        headers: _headers,
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'completed': task.completed,
        }),
      ),
    );
    return Task.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _send(() => _httpClient.delete(_uri('/tasks/$id')));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('Сервер не отвечает. Попробуйте позже.');
    } catch (_) {
      throw const ApiException(
        'Нет соединения с сервером. Проверьте, что сервер запущен.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw ApiException(
      _extractError(response),
      statusCode: response.statusCode,
    );
  }

  dynamic _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _extractError(http.Response response) {
    final fallback = 'Ошибка сервера (${response.statusCode})';
    try {
      final body = _decode(response);
      if (body is Map<String, dynamic> && body['error'] is String) {
        return body['error'] as String;
      }
      return fallback;
    } on FormatException {
      return fallback;
    }
  }
}
