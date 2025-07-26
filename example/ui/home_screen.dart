import 'package:crudrepo/crudrepo.dart';
import '../models/task.dart';
import 'add_edit_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CrudRepository<Task> _repository;
  late Future<List<Task>> _todosFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the local database
    FedsLocal fedsLocal = FedsLocalSqfliteFfi(
      dbPath: 'assets/',
      dbName: 'dbtodo.db',
    );

    // Initialize the local repository
    _repository = CrudRepositoryLocal<Task>(
      datasource: fedsLocal,
      table: 'tasks',
      fromJson: Task.fromJson,
    );
    _todosFuture = _seedAndGetTodos();
  }

  Future<List<Task>> _seedAndGetTodos() async {
    final result = await _repository.getAllItems();

    return result.fold(
      (todos) async {
        if (todos.isEmpty) {
          // Seed the database with some initial data if it's empty
          await _repository.createItem(
              Task(title: 'First Todo', description: 'This is the first todo'));
          await _repository.createItem(Task(
              title: 'Second Todo', description: 'This is the second todo'));
          // Fetch again and return the new list
          final newResult = await _repository.getAllItems();
          return newResult.getOrThrow();
        }
        return todos;
      },
      (error) => throw error, // Propagate error to FutureBuilder
    );
  }

  void _refreshTodos() {
    setState(() {
      _todosFuture = _seedAndGetTodos();
    });
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true) {
      _refreshTodos();
    }
  }

  Future<void> _showDeleteConfirmationDialog(Task todo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this todo?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _repository.deleteItem(todo.id!);
                _refreshTodos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No todos found.'));
          } else {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(todo),
                  ),
                  onTap: () => _navigateAndRefresh(
                    AddEditScreen(todo: todo, repository: _repository),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(
          AddEditScreen(repository: _repository),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}