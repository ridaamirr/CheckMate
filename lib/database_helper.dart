import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

class DatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'task.db');

    _database = await openDatabase(
      path,
      version: 8,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, completed INTEGER, due_date INTEGER, reminder_time TEXT, priority TEXT)',
        );
      },

    );
  }

  Future<int> insertTask(Task task) async {
    final id = await _database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<Task>> tasks() async {
    final List<Map<String, dynamic>> taskMaps = await _database.query('tasks');

    return taskMaps.map((map) => Task.fromMap(map)).toList();
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
  final DateTime? dueDate;
  final TimeOfDay? reminderTime;
  final String description;
  final String priority;

  Task({
    this.id,
    required this.name,
    required this.completed,
    this.dueDate,
    this.reminderTime,
    required this.description,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'reminder_time': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'description': description,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      name: map['name'] as String,
      completed: map['completed'] as int,
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      reminderTime: map['reminder_time'] != null
          ? parseTimeOfDay(map['reminder_time'].toString())
          : null,
      description: map['description'] as String,
      priority: map['priority'] as String? ?? 'Low', // Parse priority from the map
    );
  }
}

TimeOfDay parseTimeOfDay(String? timeString) {
  if (timeString == null || !timeString.contains(':')) {
    return TimeOfDay(hour: 0, minute: 0); // Default to midnight if format is invalid or timeString is null
  }
  final parts = timeString.split(':');
  if (parts.length != 2) {
    return TimeOfDay(hour: 0, minute: 0); // Handle unexpected format gracefully
  }
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
