import 'package:crudrepo/crudrepo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:result_dart/result_dart.dart';
import 'package:mockito/annotations.dart';
import 'crudrepo_test.mocks.dart';

/// A model class representing a user with an [id] and a [name].
///
/// Provides methods for serializing to and from JSON.
class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Manager class for handling user operations.
/// Uses a repository to perform CRUD operations on [UserModel].
/// Handles both success and failure cases using the Result type.
/// Provides methods to create and retrieve users.
/// Uses dependency injection to allow for easy testing and mocking.
/// Uses the `CrudRepository` interface to abstract away the data source.
class ManagerUser {
  ManagerUser(this.repository);

  final CrudRepository repository;

  Future<UserModel> createUser(int id, String name) async {
    final user = UserModel(id: id, name: name);
    final resultCreatedUser = await repository.createItem(user);
    return resultCreatedUser.fold(
      (user) => user as UserModel,
      (error) => throw Exception('Error creating user: $error'),
    );
  }

  Future<UserModel> getUser(int id) async {
    final resultUser = await repository.getItem(id);
    return resultUser.fold(
      (user) => user as UserModel,
      (error) => throw Exception('Error getting user: $error'),
    );
  }
}

/// Mock class for the CrudRepository interface.
/// Used for testing purposes to simulate remote repository behavior.
@GenerateMocks([CrudRepository])
/// Unit tests for the ManagerUser class.
void main() {
  // Register a dummy value for ResultDart<Object, Exception>
  provideDummy<ResultDart<Object, Exception>>(
    Success(UserModel(id: 0, name: '')),
  );

  // Initialize the mock repository and manager before each test
  late MockCrudRepository mockRepository;
  late ManagerUser managerUser;

  // Set up the mock repository and manager before each test
  setUp(() {
    mockRepository = MockCrudRepository();
    managerUser = ManagerUser(mockRepository);
  });

  /// Group of tests to verify the success cases for user management operations.
  ///
  /// This group contains tests for:
  /// - Creating a user and ensuring the returned user matches the expected values.
  /// - Retrieving a user by ID and verifying the returned user's properties.
  ///
  /// Mocks are used to simulate repository responses with successful results.
  group('Success case test', () {
    final user = UserModel(id: 1, name: 'John Doe');

    /// Tests that the `createUser` method returns the created user with the correct
    /// id and name when the repository successfully creates the user.
    test('createUser should return created user', () async {
      // Mock the repository's createItem method to return a successful result
      when(
        mockRepository.createItem(any),
      ).thenAnswer((_) async => Success(user));

      // Call the createUser method and verify the returned user
      final result = await managerUser.createUser(1, 'John Doe');

      // Check that the returned user matches the expected values
      expect(result.id, 1);
      expect(result.name, 'John Doe');
    });

    /// Tests that the `getUser` method returns the user with the correct id and name
    /// when the repository successfully retrieves the user.
    test('getUser should return user by id', () async {
      // Mock the repository's getItem method to return a successful result
      when(mockRepository.getItem(any)).thenAnswer((_) async => Success(user));

      // Call the getUser method and verify the returned user
      final result = await managerUser.getUser(1);

      // Check that the returned user matches the expected values
      expect(result.id, 1);
      expect(result.name, 'John Doe');
    });
  });

  /// Group of tests to verify the failure cases for user management operations.
  ///
  /// This group contains tests for:
  /// - Creating a user and ensuring an exception is thrown when the repository fails.
  /// - Retrieving a user by ID and ensuring an exception is thrown when the repository fails
  ///
  /// Mocks are used to simulate repository responses with failure results.
  group('Failure case test', () {
    /// Tests that the `createUser` method throws an exception when the repository fails
    /// to create the user.
    test('createUser should throw exception on error', () async {
      // Mock the repository's createItem method to return a failure result
      when(
        mockRepository.createItem(any),
      ).thenAnswer((_) async => Failure(Exception('Error creating user')));

      // Call the createUser method and expect it to throw an exception
      final result = managerUser.createUser(1, 'John Doe');

      // Verify that an exception is thrown
      expect(result, throwsA(isA<Exception>()));
    });

    /// Tests that the `getUser` method throws an exception when the repository fails
    /// to retrieve the user.
    test('getUser should throw exception on error', () async {
      // Mock the repository's getItem method to return a failure result
      when(
        mockRepository.getItem(any),
      ).thenAnswer((_) async => Failure(Exception('Error getting user')));

      // Call the getUser method and expect it to throw an exception
      final result = managerUser.getUser(1);

      // Verify that an exception is thrown
      expect(result, throwsA(isA<Exception>()));
    });
  });
}
