/// A Dart package for CRUD operations with remote and local repositories.
/// It provides a unified interface for performing CRUD operations on both remote APIs and local SQLite databases.
/// The package includes a DioService for remote API interactions and a FedsLocal interface for local
/// database operations. It supports caching and provides repositories for CRUD operations with
/// remote, local, and cached data sources.
/// 
/// This package is designed to be used in Flutter applications, but it can also be used in Dart console applications.

library;

export 'src/dio_service.dart';
export 'src/sqlitelib/feds_local.dart';
export 'src/sqlitelib/feds_local_sqflite_ffi.dart';
export 'src/repositories/crud_repository.dart';
export 'src/repositories/crud_repository_local.dart';
export 'src/repositories/crud_repository_remote.dart';
export 'src/repositories/crud_repository_cached.dart';