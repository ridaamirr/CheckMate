import 'package:flutter/material.dart';

class AddTaskPage extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter a new task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _taskController.text);
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
