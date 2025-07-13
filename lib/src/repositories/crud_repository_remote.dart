import 'package:result_dart/result_dart.dart';

import '../services/dio_service.dart';
import 'crud_repository.dart';

/// A repository for performing CRUD operations on a remote API using DioService.
/// This repository is designed to handle operations for a specific type [T],
/// which must be an object that can be serialized to and from JSON.
/// It provides methods to create, read, update, delete, and fetch items
/// from a remote server, as well as to handle custom queries with filters.
/// The repository uses a DioService instance to make HTTP requests to the API,
/// and it requires a function to convert JSON data into an instance of type [T].
/// The repository also allows setting an authentication token for secure API access.
class CrudRepositoryRemote<T extends Object> implements CrudRepository<T> {
  final DioService _datasource;
  final String _table;
  final String _url;
  final T Function(Map<String, dynamic>) _fromJson;

  set token(String token) {
    _datasource.token = token;
  }

  CrudRepositoryRemote({
    required DioService datasource,
    required String table,
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
  }) : _datasource = datasource,
       _table = table,
       _url = url,
       _fromJson = fromJson;

  @override
  AsyncResult<T> getItem(int idItem) async {
    try {
      // GET request to fetch the item with the given ID from the remote API
      final response = await _datasource.get('$_url/$_table/$idItem');

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Parse the response data into an instance of type T
      final item = _fromJson(response['data']);

      return Success(item);
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> createItem(T item) async {
    try {
      // POST request to create a new item in the remote API
      final response = await _datasource.post(
        '$_url/$_table',
        body: (item as dynamic).toJson(), // Assumes T has a `toJson` method
      );

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Parse the response data into an instance of type T
      final newItem = _fromJson(response['data']);

      return Success(newItem);
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> deleteItem(int idItem) async {
    try {
      // DELETE request to remove the item with the given ID from the remote API
      final response = await _datasource.delete('$_url/$_table/$idItem');

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Parse the response data into an instance of type T
      return Success(_fromJson(response['data']));
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> updateItem({
    required int id,
    required Map<String, dynamic> json,
  }) async {
    try {
      // PUT request to update the item with the given ID in the remote API
      final response = await _datasource.put('$_url/$_table/$id', body: json);

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Parse the response data into an instance of type T
      final item = _fromJson(response['data']);

      return Success(item);
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<List<T>> customGetItems(Map<String, dynamic> filters) async {
    try {
      // GET request to fetch items based on custom filters from the remote API
      final urlParams = filters.entries
          .map((e) => '${e.key}/${e.value}')
          .join('/');

      final response = await _datasource.get('$_url/$_table/$urlParams');

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Parse the response data into a list of type T
      final List<T> items = (response['data'] as List).map<T>((json) {
        return _fromJson(json);
      }).toList();
      return Success(items);
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<List<T>> getAllItems() async {
    try {
      // GET request to fetch all items from the remote API
      final response = await _datasource.get('$_url/$_table');

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Parse the response data into a list of type T
      final List<T> items = (response['data'] as List).map<T>((json) {
        return _fromJson(json);
      }).toList();

      return Success(items);
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<int> deleteAll() async {
    try {
      // DELETE request to remove all items from the remote API for the specified table
      final response = await _datasource.delete('$_url/$_table');

      // If the response indicates an error, return a Failure
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }

      // Extract the number of deleted items from the response data
      int q = response['data'];

      return Success(q);
    } on Exception catch (e) {
      // Return any exceptions as a Failure
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> replaceItem(T item) async {
    // Extract the ID of the item (assumes T has an `id` property)
    final itemId = (item as dynamic).id;

    // Attempt to fetch the item with the given ID from the remote API
    final resultItem = await getItem(itemId);

    return resultItem.fold(
      (success) {
        // If the item exists, update it with the new data
        return updateItem(id: itemId, json: (item as dynamic).toJson());
      },
      (failure) {
        // If the item does not exist, create a new item
        return createItem(item);
      },
    );
  }
}
