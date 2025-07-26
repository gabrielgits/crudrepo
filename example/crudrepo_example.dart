import 'package:crudrepo/crudrepo.dart';

/// Example of using the CrudRepository mixin with a Todo model.
/// This example demonstrates how to create, read, update, and delete todo items
/// using both local and remote repositories.
///
/// The Todo model is assumed to have a `toJson` method for serialization
/// and a `fromJson` factory constructor for deserialization.
class Todo {
  final int id;
  final String title;
  final String description;

  Todo({
    required this.id,
    required this.title,
    required this.description,
  });

  /// Converts a JSON map to a Todo instance.
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  /// Converts a Todo instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

void main() async {
  // Initialize the local database
  // Ensure that the database is created and ready to use.
  // This example assumes you have a SQLite database set up with a 'todos' table.
  // You can adjust the dbPath and dbName as per your project structure.
  // Make sure to add the sqflite package to your pubspec.yaml file.
  // Example: assets/db/app.db
  FedsLocal fedsLocal = FedsLocalSqfliteFfi(
    dbPath: 'assets/db/',
    dbName: 'app.db',
  );

  // Initialize the local repository
  // This repository will handle CRUD operations for Todo objects in the local SQLite database.
  // The fromJson function is used to convert JSON data into Todo instances.
  // Ensure that the Todo model has a fromJson factory constructor.
  // Example: Todo.fromJson(json)
  CrudRepository localRepo = CrudRepositoryLocal<Todo>(
    datasource: fedsLocal,
    table: 'todos',
    fromJson: Todo.fromJson,
  );

  // Create a todo
  final newTodo = Todo(
    id: 1,
    title: 'Test Todo',
    description: 'This is a test.',
  );
  // Use the createItem method to save the new todo to the local database.
  await localRepo.createItem(newTodo);

  // Read all todos
  final todos = await localRepo.getAllItems();
  print('All todos: $todos');

  // Update a todo
  final updatedTodo = Todo(
    id: 1,
    title: 'Test Todo',
    description: 'This is an updated test.',
  );
  await localRepo.updateItem(id: updatedTodo.id, json: updatedTodo.toJson());

  // Delete a todo
  await localRepo.deleteItem(1);
}
