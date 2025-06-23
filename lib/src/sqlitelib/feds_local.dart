/// An abstract class that defines the local data operations for Feds.
/// This class serves as a contract for implementing local storage
/// functionalities, such as interacting with SQLite or other local
/// databases.
abstract class FedsLocal {
  /// Saves a single item into the specified [table].
  ///
  /// - [table]: The name of the table where the item will be saved.
  /// - [item]: A map representing the item to be saved.
  ///
  /// Returns a [Future] containing the saved item as a map.
  Future<Map<String, dynamic>> save(
    String table, {
    required Map<String, dynamic> item,
  });

  /// Saves multiple items into the specified [table].
  ///
  /// - [table]: The name of the table where the items will be saved.
  /// - [items]: A list of maps representing the items to be saved.
  ///
  /// Returns a [Future] containing the number of items successfully saved.
  Future<int> saveAll(
    String table, {
    required List<Map<String, dynamic>> items,
  });

  /// Retrieves all items from the specified [table].
  ///
  /// - [table]: The name of the table to retrieve items from.
  ///
  /// Returns a [Future] containing a list of maps representing the items.
  Future<List<Map<String, dynamic>>> getAll(String table);

  /// Retrieves a single item by its [id] from the specified [table].
  ///
  /// - [table]: The name of the table to retrieve the item from.
  /// - [id]: The ID of the item to retrieve.
  ///
  /// Returns a [Future] containing the item as a map.
  Future<Map<String, dynamic>> getItem(String table, {required int id});

  /// Searches for all items in the specified [table] that match the given [criteria].
  ///
  /// - [table]: The name of the table to search in.
  /// - [criteria]: The search criteria as a string.
  ///
  /// Returns a [Future] containing a list of maps representing the matching items.
  Future<List<Map<String, dynamic>>> searchAll(
    String table, {
    required String criteria,
  });

  /// Searches for a single item in the specified [table] that matches the given [criteria].
  ///
  /// - [table]: The name of the table to search in.
  /// - [criteria]: The search criteria as a string.
  ///
  /// Returns a [Future] containing the matching item as a map.
  Future<Map<String, dynamic>> search(String table, {required String criteria});

  /// Updates items in the specified [table] that match the given [criteria].
  ///
  /// - [table]: The name of the table to update items in.
  /// - [criteria]: The search criteria as a string.
  /// - [updateItem]: A map representing the updated values.
  ///
  /// Returns a [Future] containing the number of items successfully updated.
  Future<int> searchUpdate(
    String table, {
    required String criteria,
    required Map<String, dynamic> updateItem,
  });

  /// Deletes items in the specified [table] that match the given [criteria].
  ///
  /// - [table]: The name of the table to delete items from.
  /// - [criteria]: The search criteria as a string.
  ///
  /// Returns a [Future] containing the result of the delete operation.
  Future<Object> searchDelete(String table, {required String criteria});

  /// Updates a single item in the specified [table].
  ///
  /// - [table]: The name of the table to update the item in.
  /// - [item]: A map representing the updated item.
  ///
  /// Returns a [Future] containing the updated item as a map.
  Future<Map<String, dynamic>> update(
    String table, {
    required Map<String, dynamic> item,
  });

  /// Deletes a single item by its [id] from the specified [table].
  ///
  /// - [table]: The name of the table to delete the item from.
  /// - [id]: The ID of the item to delete.
  ///
  /// Returns a [Future] containing the deleted item as a map.
  Future<Map<String, dynamic>> delete(String table, {required Object id});

  /// Deletes all items from the specified [table].
  ///
  /// - [table]: The name of the table to delete all items from.
  ///
  /// Returns a [Future] containing the number of items successfully deleted.
  Future<int> deleteAll(String table);

  /// Executes a raw SQL query and retrieves all matching items.
  ///
  /// - [sql]: The raw SQL query string.
  /// - [criteriaListData]: An optional list of parameters for the query.
  ///
  /// Returns a [Future] containing a list of maps representing the matching items.
  Future<List<Map<String, dynamic>>> searchAllRaw(
    String sql, {
    List<Object?>? criteriaListData,
  });
}
