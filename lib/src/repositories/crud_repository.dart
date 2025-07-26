import 'package:result_dart/result_dart.dart';

/// A mixin that provides a base structure for CRUD (Create, Read, Update, Delete)
/// operations on a generic type [T].
///
/// This mixin can be used to define common CRUD functionality that can be
/// shared across multiple repository implementations.
mixin CrudRepository<T extends Object> {
  /// Retrieves all items of type [T].
  ///
  /// Returns a [Result] containing a list of items of type [T].
  AsyncResult<List<T>> getAllItems();

  /// Retrieves a specific item of type [T] by its [idItem].
  ///
  /// [idItem] - The unique identifier of the item to retrieve.
  ///
  /// Returns a [Result] containing the requested item of type [T].
  AsyncResult<T> getItem(int idItem);

  /// Creates a new item of type [T].
  ///
  /// [item] - The item to be created.
  ///
  /// Returns a [Result] containing the created item of type [T].
  AsyncResult<T> createItem(T item);

  /// Replaces an existing item of type [T] with a new one.
  ///
  /// [item] - The new item to replace the existing one.
  ///
  /// Returns a [Result] containing the replaced item of type [T].
  AsyncResult<T> replaceItem(T item);

  /// Updates specific fields of an existing item of type [T].
  ///
  /// [id] - The unique identifier of the item to update.
  /// [json] - A map containing the fields to update and their new values.
  ///
  /// Returns a [Result] containing the updated item of type [T].
  AsyncResult<T> updateItem({
    required int id,
    required Map<String, dynamic> json,
  });

  /// Deletes a specific item of type [T] by its [idItem].
  ///
  /// [idItem] - The unique identifier of the item to delete.
  ///
  /// Returns a [Result] containing the deleted item of type [T].
  AsyncResult<int> deleteItem(int idItem);

  /// Retrieves items of type [T] based on custom filters.
  ///
  /// [filters] - A map containing the filter criteria.
  ///
  /// Returns a [Result] containing a list of items of type [T] that match the filters.
  AsyncResult<List<T>> customGetItems(Map<String, dynamic> filters);

  /// Deletes all items of type [T].
  ///
  /// Returns a [Result] containing the number of items deleted.
  AsyncResult<int> deleteAll();
}
