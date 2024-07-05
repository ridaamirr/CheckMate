import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'task_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, completed INTEGER)',
        );
      },
    );
  }

  Future<void> insertTask(Task task) async {
    await _database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> tasks() async {
    final List<Map<String, Object?>> taskMaps = await _database.query('tasks');

    return [
      for (final {
      'id': id as int,
      'name': name as String,
      'completed': completed as int,
      } in taskMaps)
        Task(id: id, name: name, completed: completed),
    ];
  }

  Future<void> updateTask(Task task) async {
    await _database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class Task {
  final int? id;
  final String name;
  final int completed;

  Task({
    this.id,
    required this.name,
    required this.completed,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name, completed: $completed}';
  }
}
