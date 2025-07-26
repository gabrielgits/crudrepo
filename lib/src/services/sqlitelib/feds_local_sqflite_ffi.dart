import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Correct import for sqflite_ffi
import 'package:path/path.dart'; // Import the path package
import 'package:path_provider/path_provider.dart';

import 'feds_local.dart';

/// FedsLocalSqfliteFfi is a class that implements the FedsLocal interface
/// using the sqflite_ffi package for SQLite database operations on desktop platforms.
/// It provides methods to perform CRUD operations on a local SQLite database.
/// This implementation adapts the mobile version for desktop compatibility,
/// addressing potential differences in file paths and threading models.
class FedsLocalSqfliteFfi implements FedsLocal {
  static Database? _database;
  final String dbPath;
  final String dbName;
  final String? androidVersionPath;

  const FedsLocalSqfliteFfi({
    required this.dbPath,
    required this.dbName,
    this.androidVersionPath,
  });

  static void initDesktopDb() {
    // Initialize FFI for sqflite_ffi
    sqfliteFfiInit();

    // Set the database factory
    databaseFactory = databaseFactoryFfi;
  }

  /// Initializes the database connection.
  ///
  /// On desktop platforms, it uses `sqflite_ffi` to open the database.
  /// The database file is copied from the asset bundle to a platform-specific
  /// directory if it doesn't already exist.
  ///
  /// Returns:
  ///   A `Future<Database?>` that completes with the database instance if
  ///   the initialization is successful, or `null` if an error occurs.
  Future<Database?> _initDatabase() async {
    if (_database != null) {
      return _database;
    }

    // Get the application documents directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String deviceDbPath = appDocDir.path;
    final deviceDb = join(deviceDbPath, dbName);

    // Check if the database file exists
    bool fileCreated = await File(deviceDb).exists();
    if (!fileCreated) {
      // Copy the database file from the asset bundle to the application documents directory
      ByteData data = await rootBundle.load('$dbPath$dbName');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(deviceDb).writeAsBytes(bytes);
    }

    // Open the database
    _database = await openDatabase(deviceDb);
    return _database;
  }

  @override
  Future<Map<String, dynamic>> delete(
    String table, {
    required Object id,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized and attempt to delete the record
    if (_database != null &&
        await _database!.delete(table, where: 'id = ?', whereArgs: [id]) > 0) {
      // Return the ID of the deleted record if successful
      return {'id': id};
    }

    // Return an empty map if the deletion was unsuccessful
    return {};
  }

  @override
  Future<int> deleteAll(String table) async {
    /// Deletes all records from the specified table in the SQLite database.
    ///
    /// This function initializes the database connection and, if successful,
    /// executes a SQL `DELETE` statement to remove all rows from the given table.
    ///
    /// Returns:
    /// - `1` if the operation is successful.
    /// - `0` if the database connection could not be established.
    ///
    /// Note:
    /// Ensure that the table name provided in the variable `table` is valid
    /// and exists in the database schema.
    _database = await _initDatabase();
    if (_database != null) {
      await _database!.execute('DELETE FROM $table');
      return 1;
    }
    return 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Query all records from the specified table
      final list = await _database!.query(table);

      // Return the list of records if not empty
      if (list.isNotEmpty) {
        return list;
      }
    }

    // Return an empty list if no records are found or the database is not initialized
    return [];
  }

  @override
  Future<Map<String, dynamic>> getItem(String table, {required int id}) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Query the table for a record with the specified ID
      final list = await _database!.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );

      // If a record is found, return the first result
      if (list.isNotEmpty) {
        return list[0];
      }
    }

    // Return an empty map if no record is found or the database is not initialized
    return {};
  }

  @override
  Future<Map<String, dynamic>> save(
    String table, {
    required Map<String, dynamic> item,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Insert the item into the specified table and get the generated ID
      final id = await _database!.insert(table, item);

      // If the insertion is successful, retrieve and return the inserted item
      if (id > 0) {
        return await getItem(table, id: id);
      }
    }

    // Return an empty map if the insertion was unsuccessful
    return {};
  }

  @override
  Future<int> saveAll(
    String table, {
    required List<Map<String, dynamic>> items,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();
    int quant = 0;

    // Check if the database is initialized
    if (_database != null) {
      // Iterate through the list of items and insert each into the table
      for (var element in items) {
        final result = await _database!.insert(table, element);

        // If an insertion fails, return the count of successfully inserted items
        if (result < 1) {
          return quant;
        }

        // Increment the count of successfully inserted items
        quant++;
      }
    }

    // Return the total number of successfully inserted items
    return quant;
  }

  @override
  Future<Map<String, dynamic>> search(
    String table, {
    required String criteria,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Query the table for a record matching the specified criteria
      final list = await _database!.query(table, where: criteria);

      // If a matching record is found, return the first result
      if (list.isNotEmpty) {
        return list[0];
      }
    }

    // Return an empty map if no matching record is found or the database is not initialized
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> searchAll(
    String table, {
    required String criteria,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Query the table for records matching the specified criteria
      final list = await _database!.query(table, where: criteria);

      // If matching records are found, return the list of results
      if (list.isNotEmpty) {
        return list;
      }
    }

    // Return an empty list if no matching records are found or the database is not initialized
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> searchAllRaw(
    String sql, {
    List<Object?>? criteriaListData,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Execute the raw SQL query with the provided criteria list data
      final list = await _database!.rawQuery(sql, criteriaListData);

      // If the query returns results, return the list of records
      if (list.isNotEmpty) {
        return list;
      }
    }

    // Return an empty list if no records are found or the database is not initialized
    return [];
  }

  @override
  Future<int> searchDelete(String table, {required String criteria}) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Execute a SQL `DELETE` statement with the specified criteria
      return await _database!.delete(table, where: criteria);
    }

    // Return 0 if the database is not initialized or the deletion fails
    return 0;
  }

  @override
  Future<int> searchUpdate(
    String table, {
    required String criteria,
    required Map<String, dynamic> updateItem,
  }) async {
    /// Updates records in the specified table of the SQLite database based on the given criteria.
    _database = await _initDatabase();
    // Check if the database is initialized
    if (_database != null) {
      // Execute a SQL `UPDATE` statement with the specified criteria and update item
      // The `updateItem` is a map containing the new values for the columns
      // The `criteria` is a string that specifies which records to update
      // The `where` clause is used to filter the records that will be updated
      return await _database!.update(table, updateItem, where: criteria);
    }
    // Return 0 if the database is not initialized or the update fails
    return 0;
  }

  @override
  Future<Map<String, dynamic>> update(
    String table, {
    required Map<String, dynamic> item,
  }) async {
    // Initialize the database if not already initialized
    _database = await _initDatabase();

    // Check if the database is initialized
    if (_database != null) {
      // Attempt to update the specified item in the table
      final result = await _database!.update(
        table, // The table name
        item, // The item to update
        where: 'id = ?', // The condition to match the record by ID
        whereArgs: [item['id']], // The ID of the item to update
      );

      // If the update is successful, return the ID of the updated item
      if (result > 0) {
        return {'id': item['id']};
      }
    }

    // Return an empty map if the update was unsuccessful
    return {};
  }
}
