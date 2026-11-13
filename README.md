# Task Manager — Flutter + Bloc + REST API

Кроссплатформенное мобильное приложение для управления задачами (mid-term project).

| Требование | Как выполнено |
|---|---|
| Cross-platform mobile app (Flutter) | Приложение на Flutter, работает на Android, iOS и Web |
| Mobile must communicate with Server | REST API на Node.js (`server/`), обмен JSON по HTTP через пакет `http` |
| Must be pushed on GitHub | Репозиторий с CI (GitHub Actions: analyze + test) |
| State management (Bloc) | `flutter_bloc`: `TasksBloc`, события и состояния в `lib/presentation/bloc/` |

## Структура

```
task_manager/
├── server/                  REST API (Node.js, без внешних зависимостей)
│   └── server.js
├── mobile/                  Flutter-приложение
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/app_config.dart
│   │   ├── data/
│   │   │   ├── api/         HTTP-клиент и ошибки
│   │   │   ├── models/      модель Task
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/        TasksBloc, события, состояние
│   │       ├── screens/     экраны
│   │       └── widgets/     виджеты
│   └── test/                тесты Bloc и виджетов
└── .github/workflows/ci.yml
```

## Запуск сервера

```bash
cd server
node server.js
```

Сервер слушает `http://localhost:3000`.

| Метод | Путь | Описание |
|---|---|---|
| GET | `/health` | проверка работы |
| GET | `/tasks` | список задач |
| POST | `/tasks` | создать задачу `{ "title", "description" }` |
| PUT | `/tasks/:id` | изменить задачу |
| DELETE | `/tasks/:id` | удалить задачу |

## Запуск приложения

```bash
cd mobile
flutter create . --project-name task_manager --platforms android,ios,web
flutter pub get
flutter run
```

Для Android добавьте в `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" ...>
```

Адрес сервера выбирается автоматически: `10.0.2.2:3000` для эмулятора Android, `localhost:3000` для iOS-симулятора и Web.
Для реального телефона укажите IP компьютера в локальной сети:

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:3000
```

## Тесты

```bash
cd mobile
flutter test
```
