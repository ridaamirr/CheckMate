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
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, completed INTEGER, due_date INTEGER, reminder_time INTEGER)',
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

  Task({
    this.id,
    required this.name,
    required this.completed,
    this.dueDate,
    this.reminderTime,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
      'due_date': dueDate != null ? dueDate!.millisecondsSinceEpoch : null,
      'reminder_time': reminderTime != null
          ? reminderTime!.hour * 60 + reminderTime!.minute
          : null,
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
          ? TimeOfDay(hour: map['reminder_time']! ~/ 60, minute: map['reminder_time']! % 60)
          : null,
    );
  }
}

