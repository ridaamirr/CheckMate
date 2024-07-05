import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'addtask.dart'; // Import add task page
import 'edit_delete_task.dart'; // Import edit/delete task page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.initializeDatabase();

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'To-Do List', dbHelper: dbHelper),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final DatabaseHelper dbHelper;

  const MyHomePage({Key? key, required this.title, required this.dbHelper})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() async {
    final data = await widget.dbHelper.tasks();
    setState(() {
      _tasks = data;
    });
  }

  void _addTask(String name) async {
    if (name.isNotEmpty) {
      await widget.dbHelper.insertTask(Task(name: name, completed: 0));
      _taskController.clear();
      _refreshTasks();
    }
  }

  void _toggleCompletion(Task task) async {
    await widget.dbHelper.updateTask(Task(
        id: task.id, name: task.name, completed: task.completed == 1 ? 0 : 1));
    _refreshTasks();
  }

  void _removeTask(int id) async {
    await widget.dbHelper.deleteTask(id);
    _refreshTasks();
  }

  void _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskPage()),
    );
    if (result != null && result is String) {
      _addTask(result);
    }
  }

  void _navigateToEditDeleteTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDeleteTaskPage(
          task: task,
          dbHelper: widget.dbHelper,
        ),
      ),
    );
    if (result != null && result is bool && result) {
      _refreshTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(
                      task.name,
                      style: TextStyle(
                        decoration: task.completed == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: Checkbox(
                      value: task.completed == 1,
                      onChanged: (bool? value) {
                        _toggleCompletion(task);
                      },
                    ),
                    onTap: () => _navigateToEditDeleteTask(task),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
