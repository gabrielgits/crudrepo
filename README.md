<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# crudrepo

A Dart package providing a flexible, generic repository pattern for CRUD (Create, Read, Update, Delete) operations with support for local SQLite and remote HTTP APIs, including optional caching.

## Features

- **Generic CRUD Repositories**: Easily create repositories for any model type.
- **Local Storage**: Use SQLite via `sqflite` for persistent local storage.
- **Remote API Integration**: Use `dio` for HTTP-based CRUD operations.
- **Caching Layer**: Combine remote and local repositories for offline-first or cached data access.
- **Result Handling**: All operations return `Result` types for robust error handling.
- **Custom Queries**: Support for custom filters and raw SQL queries.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  crudrepo: ^0.2.0
```

## Usage

### Define Your Model

Your model should implement `toJson()` and have a constructor from `Map<String, dynamic>`:

```dart
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

### Local Repository Example

```dart
import 'package:crudrepo/crudrepo.dart';

final localRepo = CrudRepositoryLocal<User>(
  datasource: FedsLocalSqflite(dbPath: 'assets/db/', dbName: 'app.db'),
  table: 'users',
  fromJson: User.fromJson,
);

// Create a user
final result = await localRepo.createItem(User(id: 1, name: 'Alice'));
result.fold(
  (user) => print('Created: ${user.name}'),
  (error) => print('Error: $error'),
);
```

### Remote Repository Example

```dart
final remoteRepo = CrudRepositoryRemote<User>(
  datasource: DioService(),
  table: 'users',
  url: 'https://api.example.com',
  fromJson: User.fromJson,
);
```

### Cached Repository Example

```dart
final cachedRepo = CrudRepositoryCached<User>(
  remoteDatasource: DioService(),
  localDatasource: FedsLocalSqflite(dbPath: 'assets/db/', dbName: 'app.db'),
  table: 'users',
  url: 'https://api.example.com',
  fromJson: User.fromJson,
);
```

## API Reference

- [`CrudRepository`](lib/src/repositories/crud_repository.dart): Base mixin for CRUD operations.
- [`CrudRepositoryLocal`](lib/src/repositories/crud_repository_local.dart): Local SQLite repository.
- [`CrudRepositoryRemote`](lib/src/repositories/crud_repository_remote.dart): Remote HTTP repository.
- [`CrudRepositoryCached`](lib/src/repositories/crud_repository_cached.dart): Cached repository (remote + local).
- [`FedsLocal`](lib/src/sqlitelib/feds_local.dart): Abstract interface for local storage.
- [`FedsLocalSqflite`](lib/src/sqlitelib/feds_local_sqflite.dart): SQLite implementation.
- [`DioService`](lib/src/dio_service.dart): HTTP client abstraction.

## Testing

See [test/crudrepo_test.dart](test/crudrepo_test.dart) for example tests.

## Contributing

Contributions are welcome! Please open issues or submit pull requests.

## License

[MIT](LICENSE)
