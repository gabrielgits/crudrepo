import 'package:result_dart/result_dart.dart';

import '../dio_service.dart';
import '../sqlitelib/feds_local.dart';
import 'crud_repository.dart';

/// A repository for performing CRUD operations on a remote API with local caching.
/// This repository is designed to handle operations for a specific type [T],
/// which must be an object that can be serialized to and from JSON.
/// It provides methods to create, read, update, delete, and fetch items
/// from a remote server, while also caching results locally using FedsLocal.
/// The repository uses a DioService instance to make HTTP requests to the API,
/// and it requires a function to convert JSON data into an instance of type [T].
/// The repository also allows setting an authentication token for secure API access.
class CrudRepositoryCached<T extends Object> implements CrudRepository<T> {
  final DioService _remoteDatasource;
  final FedsLocal _localDatasource;
  final String _table;
  final String _url;
  final T Function(Map<String, dynamic>) _fromJson;

  CrudRepositoryCached({
    required DioService remoteDatasource,
    required FedsLocal localDatasource,
    required String table,
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _table = table,
       _url = url,
       _fromJson = fromJson;

  set token(String token) {
    _remoteDatasource.token = token;
  }

  @override
  AsyncResult<T> getItem(int idItem) async {
    // Try to fetch the item from the remote datasource (API)
    try {
      final remoteResponse = await _remoteDatasource.get(
        '$_url/$_table/$idItem',
      );
      if (remoteResponse['status'] == true) {
        // If successful, convert the response to the model and update local cache
        final item = _fromJson(remoteResponse['data']);
        await _localDatasource.update(_table, item: remoteResponse['data']);
        //
        return Success(item);
      }
    } catch (_) {
      // Ignore remote errors, fallback to local
    }

    // If remote fetch fails, try to get the item from the local datasource (cache)
    try {
      final localResponse = await _localDatasource.getItem(_table, id: idItem);
      if (localResponse.isNotEmpty) {
        return Success(_fromJson(localResponse));
      }
      // If not found locally, return a failure
      return Failure(Exception('Item not found'));
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  AsyncResult<List<T>> getAllItems() async {
    // Try to fetch all items from the remote datasource (API)
    try {
      final response = await _remoteDatasource.get('$_url/$_table');
      if (response['status'] == true) {
        // If successful, save all items to the local cache
        await _localDatasource.saveAll(_table, items: response['data']);
        // Convert the response data to a list of model objects
        final List<T> items = (response['data'] as List)
            .map<T>((json) => _fromJson(json))
            .toList();
        return Success(items);
      }
    } catch (e, stack) {
      // Log any errors from the remote fetch
      print('Error in getAllItems remote fetch: $e\n$stack');
    }

    // If remote fetch fails, try to get all items from the local datasource (cache)
    try {
      final localResponse = await _localDatasource.getAll(_table);
      final List<T> items = localResponse.map<T>(_fromJson).toList();
      return Success(items);
    } on Exception catch (e) {
      // Return failure if local fetch also fails
      return Failure(e);
    }
  }

  @override
  AsyncResult<List<T>> customGetItems(Map<String, dynamic> filters) async {
    // Try to fetch filtered items from the remote datasource (API)
    try {
      // Build URL parameters from the filters map
      final urlParams = filters.entries
          .map((e) => '${e.key}/${e.value}')
          .join('/');
      final remoteResponse = await _remoteDatasource.get(
        '$_url/$_table/$urlParams',
      );
      if (remoteResponse['status'] == true) {
        // If successful, save all items to the local cache
        await _localDatasource.saveAll(_table, items: remoteResponse['data']);
        // Convert the response data to a list of model objects
        final List<T> items = (remoteResponse['data'] as List)
            .map<T>((json) => _fromJson(json))
            .toList();
        return Success(items);
      }
    } catch (_) {
      // Ignore remote errors, fallback to local
    }

    // If remote fetch fails, try to get all items from the local datasource (cache)
    try {
      final localResponse = await _localDatasource.getAll(_table);
      final List<T> items = localResponse.map<T>(_fromJson).toList();
      return Success(items);
    } on Exception catch (e) {
      // Return failure if local fetch also fails
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> createItem(T item) async {
    try {
      // Send a POST request to the remote datasource to create the item
      final response = await _remoteDatasource.post(
        '$_url/$_table',
        body: (item as dynamic).toJson(),
      );
      // If the response indicates failure, return a Failure result
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }
      // Update the local cache with the newly created item
      await _localDatasource.update(_table, item: response['data']);
      // Convert the response data to the model object
      final newItem = _fromJson(response['data']);
      // Return the created item as a Success result
      return Success(newItem);
    } on Exception catch (e) {
      // Return a Failure result if any exception occurs
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> deleteItem(int idItem) async {
    try {
      // Delete the item from the remote datasource (API)
      final response = await _remoteDatasource.delete('$_url/$_table/$idItem');
      // If the response indicates failure, return a Failure result
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }
      // Delete the item from the local cache
      await _localDatasource.delete(_table, id: idItem);
      // Convert the response data to the model object
      return Success(_fromJson(response['data']));
    } on Exception catch (e) {
      // Return a Failure result if any exception occurs
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> updateItem({
    required int id,
    required Map<String, dynamic> json,
  }) async {
    try {
      // Send a PUT request to the remote datasource to update the item
      final response = await _remoteDatasource.put(
        '$_url/$_table/$id',
        body: json,
      );
      // If the response indicates failure, return a Failure result
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }
      // Update the local cache with the updated item
      await _localDatasource.update(_table, item: response['data']);
      // Convert the response data to the model object
      final item = _fromJson(response['data']);
      // Return the updated item as a Success result
      return Success(item);
    } on Exception catch (e) {
      // Return a Failure result if any exception occurs
      return Failure(e);
    }
  }

  @override
  AsyncResult<int> deleteAll() async {
    try {
      // Send a DELETE request to the remote datasource to delete all items
      final response = await _remoteDatasource.delete('$_url/$_table');
      // If the response indicates failure, return a Failure result
      if (response['status'] == false) {
        return Failure(Exception(response['message']));
      }
      // Delete all items from the local cache
      final q = await _localDatasource.deleteAll(_table);
      // Return the number of deleted items as a Success result
      return Success(q);
    } on Exception catch (e) {
      // Return a Failure result if any exception occurs
      return Failure(e);
    }
  }

  @override
  AsyncResult<T> replaceItem(T item) async {
    // Get the item's ID using dynamic access
    final itemId = (item as dynamic).id;
    // Try to fetch the item by ID to check if it exists
    final resultItem = await getItem(itemId);
    // If the item exists, update it; otherwise, create a new item
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
