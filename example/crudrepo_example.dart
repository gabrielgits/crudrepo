import 'package:crudrepo/crudrepo.dart';
import 'package:crudrepo/src/sqlitelib/feds_local_sqflite.dart';

/// Example of using the CrudRepository mixin with a User model.
/// This example demonstrates how to create, read, update, and delete user items
/// using both local and remote repositories.


/// The User model is assumed to have a `toJson` method for serialization
/// and a `fromJson` factory constructor for deserialization.
class User {
  final int id;
  final String name;
  final String email;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  /// Converts a JSON map to a User instance.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }

  /// Converts a User instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}

void main() async {
  // Initialize the local database
  // Ensure that the database is created and ready to use.
  // This example assumes you have a SQLite database set up with a 'users' table.
  // You can adjust the dbPath and dbName as per your project structure.
  // Make sure to add the sqflite package to your pubspec.yaml file.
  // Example: assets/db/app.db
  FedsLocal fedsLocal = FedsLocalSqflite(
    dbPath: 'assets/db/',
    dbName: 'app.db',
  );

  // Initialize the local repository
  // This repository will handle CRUD operations for User objects in the local SQLite database.
  // The fromJson function is used to convert JSON data into User instances.
  // Ensure that the User model has a fromJson factory constructor.
  // Example: User.fromJson(json)
  CrudRepository localRepo = CrudRepositoryLocal<User>(
    datasource: fedsLocal,
    table: 'users',
    fromJson: User.fromJson,
  );

  // Create a user
  final newUser = User(id: 1, name: 'John Doe', email: 'john.doe@example.com', password: 'password123');
  // Use the createItem method to save the new user to the local database.
  await localRepo.createItem(newUser);

  // Read all users
  final users = await localRepo.getAllItems();
  print('All users: $users');

  // Update a user
  final updatedUser = User(id: 1, name: 'John Doe', email: 'john.doe@example.com', password: 'newpassword');
  await localRepo.updateItem(
    id: updatedUser.id,
    json: updatedUser.toJson(),
  );

  // Delete a user
  await localRepo.deleteItem(1);
}