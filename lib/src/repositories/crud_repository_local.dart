import 'package:result_dart/result_dart.dart';

import '../sqlitelib/feds_local.dart';
import 'crud_repository.dart';

/// A repository for performing CRUD operations on a local SQLite database.
/// This repository is designed to handle operations for a specific type [T],
/// which must be an object that can be serialized to and from JSON.
/// It provides methods to create, read, update, delete, and fetch items
/// from a local database, as well as to handle custom queries with filters.
/// The repository uses a FedsLocal instance to perform database operations,
/// and it requires a function to convert JSON data into an instance of type [T].
class CrudRepositoryLocal<T extends Object> implements CrudRepository<T> {
  final FedsLocal _datasource;
  final String _table;
  final T Function(Map<String, dynamic>) _fromJson;

  CrudRepositoryLocal({
    required FedsLocal datasource,
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
  }) : _fromJson = fromJson,
       _datasource = datasource,
       _table = table;

  @override
  AsyncResult<T> getItem(int idItem) async {
    try {
      // Fetch an item by its ID from the data source.
      final response = await _datasource.getItem(_table, id: idItem);
      if (response.isNotEmpty) {
        // Convert the response to the desired object type.
        final item = _fromJson(response);
        return Success(item);
      }
      // Return an error if the item is not found.
      return Failure(Exception('Item not found'));
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> createItem(T item) async {
    try {
      // Save a new item to the data source.
      final response = await _datasource.save(
        _table,
        item: (item as dynamic).toJson(),
      );

      // Convert the response to the desired object type.
      final newItem = _fromJson(response);
      return Success(newItem);
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> deleteItem(int idItem) async {
    try {
      // Delete an item by its ID from the data source.
      final response = await _datasource.delete(_table, id: idItem);
      // Convert the response to the desired object type.
      return Success(_fromJson(response));
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> updateItem({
    required int id,
    required Map<String, dynamic> json,
  }) async {
    try {
      // Update an item in the data source with the provided JSON data.
      final response = await _datasource.update(_table, item: json);
      if (response['id'] > 0) {
        // Return the updated item if the operation was successful.
        return Success(_fromJson(json));
      }
      // Return an error if the item was not found.
      return Failure(Exception('Item not found'));
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<List<T>> customGetItems(Map<String, dynamic> filters) async {
    try {
      // Fetch all items from the data source.
      final allItems = await _datasource.getAll(_table);

      // Filter the items based on the provided filters.
      final filteredItems = allItems
          .where(
            (item) => filters.entries.every(
              (filter) => item[filter.key] == filter.value,
            ),
          )
          .toList();

      // Convert the filtered items to the desired object type.
      final List<T> items = filteredItems
          .map<T>((json) => _fromJson(json))
          .toList();
      return Success(items);
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<List<T>> getAllItems() async {
    try {
      // Fetch all items from the data source.
      final response = await _datasource.getAll(_table);

      // Convert the items to the desired object type.
      final List<T> items = response.map<T>((json) {
        return _fromJson(json);
      }).toList();
      return Success(items);
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<int> deleteAll() async {
    try {
      // Delete all items from the data source.
      final response = await _datasource.deleteAll(_table);

      // Return the number of deleted items.
      return Success(response);
    } on Exception catch (e) {
      // Handle any exceptions that occur.
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> replaceItem(T item) async {
    // Get the ID of the item to be replaced.
    final itemId = (item as dynamic).id;
    // Attempt to fetch the item by its ID.
    final resultItem = await getItem(itemId);
    return resultItem.fold(
      (success) {
        // If the item exists, update it with the new data.
        return updateItem(id: itemId, json: (item as dynamic).toJson());
      },
      (failure) {
        // If the item does not exist, create a new item.
        return createItem(item);
      },
    );
  }
}
