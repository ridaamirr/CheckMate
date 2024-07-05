import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditDeleteTaskPage extends StatelessWidget {
  final Task task;
  final DatabaseHelper dbHelper;

  const EditDeleteTaskPage({
    Key? key,
    required this.task,
    required this.dbHelper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Task Name: ${task.name}',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await dbHelper.deleteTask(task.id!);
                Navigator.pop(context, true);
              },
              child: const Text('Delete Task'),
            ),
          ],
        ),
      ),
    );
  }
}
