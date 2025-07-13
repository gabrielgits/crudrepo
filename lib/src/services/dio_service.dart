import 'package:dio/dio.dart';

/// A service class for making HTTP requests using Dio.
/// This class provides methods for sending GET, POST, PUT, DELETE and getData requests,
/// as well as handling authentication tokens and custom headers.
/// It is designed to be used in a Flutter application for network communication.
/// The class encapsulates the Dio library's functionality, allowing for easy
/// configuration of headers and response types.
/// Example usage:
/// ```dart
/// final dioService = DioService();
/// final response = await dioService.get('https://api.example.com/data');
/// print(response);
/// ```

class DioService {
  /// Creates an instance of [DioService].
  /// This constructor initializes the Dio instance with default options.
  final Dio _dio = Dio();

  String _token = '';
  set token(String value) {
    _token = value;
    if (_token.isNotEmpty) {
      _dio.options.headers["Authorization"] = "Bearer $_token";
    } else {
      _dio.options.headers.remove("Authorization");
    }
  }

  /// A map containing the HTTP headers to be used for POST requests.
  ///
  /// This map defines the headers that will be included in the HTTP
  /// POST requests made by the Dio service. It typically contains
  /// key-value pairs specifying content type, authorization tokens,
  /// or other necessary metadata for the request.
  final _httpHeadersPost = {
    "Connection": "Keep-Alive",
    "Accept": "application/json",
    "Content-Type": "application/json", //"application/x-www-form-urlencoded"
  };

  /// Sends a GET request to the specified [url] and returns the response as a
  /// `Map<String, dynamic>`.
  ///
  /// This method is asynchronous and will wait for the response before returning.
  ///
  /// Throws:
  /// - `DioError` if there is an error during the request, such as network issues
  ///   or a non-2xx HTTP status code.
  ///
  /// Parameters:
  /// - [url]: The endpoint URL to which the GET request will be sent.
  ///
  /// Returns:
  /// A `Future` that resolves to a `Map<String, dynamic>` containing the response data.
  Future<Map<String, dynamic>> get(String url) async {
    _dio.options.responseType = ResponseType.json;
    try {
      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a POST request to the specified endpoint and returns the response as a map.
  ///
  /// This method takes care of sending data to the server using the POST HTTP method.
  /// It expects the endpoint and the data to be sent as parameters.
  ///
  /// Returns a `Map<String, dynamic>` containing the response data from the server.
  ///
  /// Throws an exception if the request fails or if there is an issue with the response.
  Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    _dio.options.responseType = ResponseType.json;

    final response = await _dio.post(
      url,
      data: body,
      options: Options(headers: _httpHeadersPost),
    );
    return response.data;
  }

  /// Sends a PUT request to the specified endpoint and returns the response as a map.
  ///
  /// This method is used to update resources on the server. It takes the endpoint
  /// URL and the data to be sent in the request body. The response is parsed into
  /// a `Map<String, dynamic>` for further processing.
  ///
  /// Returns:
  /// - A `Future` that resolves to a `Map<String, dynamic>` containing the server's response.
  ///
  /// Throws:
  /// - An exception if the request fails or if there is an error during the process.
  Future<Map<String, dynamic>> put(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    _dio.options.responseType = ResponseType.json;

    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(headers: _httpHeadersPost),
        // body: json.encode(body),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a DELETE request to the specified [url] and returns the response as a map.
  ///
  /// This method performs an HTTP DELETE operation using the provided [url].
  /// It is an asynchronous operation and returns a `Future` that resolves to
  /// a `Map<String, dynamic>` containing the response data.
  ///
  /// Throws:
  /// - An exception if the request fails or if there is an error during the operation.
  ///
  /// Example:
  /// ```dart
  /// final response = await dioService.delete('https://api.example.com/resource/1');
  /// print(response);
  /// ```
  Future<Map<String, dynamic>> delete(String url) async {
    _dio.options.responseType = ResponseType.json;

    try {
      final response = await _dio.delete(url);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches data from the specified URL and returns it as a list of integers.
  ///
  /// This method performs an asynchronous HTTP GET request to the provided [url]
  /// and processes the response to extract a list of integers.
  ///
  /// - Parameter [url]: The URL to fetch data from.
  /// - Returns: A `Future` that resolves to a `List<int>` containing the fetched data.
  /// - Throws: An exception if the request fails or the response cannot be processed.
  Future<List<int>> getData(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a POST request with form data to the specified [url] and returns the response as a map.
  /// ///
  /// This method is used to upload files or send data in a multipart/form-data format.
  /// It accepts a [FormData] object as the body of the request.
  /// ///
  /// Parameters:
  /// - [url]: The endpoint URL to which the POST request will be sent.
  /// - [body]: A [FormData] object containing the data to be sent in the request.
  /// Returns:
  /// A `Future` that resolves to a `Map<String, dynamic>` containing the response data.
  /// Throws:
  /// - An exception if the request fails or if there is an error during the process.
  Future<Map<String, dynamic>> postFormData(
    String url, {
    required FormData body,
  }) async {
    _dio.options.responseType = ResponseType.json;

    final response = await _dio.post(
      url,
      data: body,
      options: Options(headers: {
        "Connection": "Keep-Alive",
        "Accept": "application/json",
        "Content-Type": "multipart/form-data",
      }),
    );
    return response.data;
  }
}
