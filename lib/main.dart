import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'addtask.dart';
import 'edittask.dart';
import 'package:intl/intl.dart';
import 'package:todolist/services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

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
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: '', dbHelper: dbHelper),
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

  void _addTask(String name, DateTime? dueDate, TimeOfDay? reminderTime, String description) async {
    print('in add task function');
    if (name.isNotEmpty) {
      final task = Task(
        name: name,
        completed: 0,
        dueDate: dueDate,
        reminderTime: reminderTime,
        description: description,
      );
      print('adding task');
      final insertedId = await widget.dbHelper.insertTask(task);

      if (reminderTime != null || task.dueDate != null ) {
        _scheduleNotification(task, insertedId);
      }

      _taskController.clear();
      _refreshTasks();
    }
  }

  void _scheduleNotification(Task task, int insertedId) async {
    if (task.dueDate != null && task.reminderTime != null) {
      DateTime dueDate = task.dueDate!;
      TimeOfDay reminderTime = task.reminderTime!;

      DateTime scheduledDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      await NotificationService.showNotification(
        title: "Reminder",
        body: "It's time for ${task.name}",
        scheduledDateTime: scheduledDateTime,
      );
    }
  }


  void _toggleCompletion(Task task) async {
    await widget.dbHelper.updateTask(Task(
      id: task.id,
      name: task.name,
      completed: task.completed == 1 ? 0 : 1,
      dueDate: task.dueDate,
      reminderTime: task.reminderTime,
      description: task.description,
    ));
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
    print(result);
    if (result != null && result is Map<String, dynamic>) {
      String taskName = result['taskName'];
      DateTime? dueDate = result['dueDate'];
      TimeOfDay? reminderTime = result['reminderTime'];
      String description = result['description'];
      _addTask(taskName, dueDate, reminderTime, description);
    }
  }

  void _navigateToEditDeleteTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
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
    List<Task> _completedTasks = _tasks.where((task) => task.completed == 1).toList();
    List<Task> _incompleteTasks = _tasks.where((task) => task.completed == 0).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.pink, // Set the back arrow color to pink
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Adjust bottom padding as needed
        child: FloatingActionButton(
          onPressed: _navigateToAddTask,
          tooltip: 'Add Task',
          child: Icon(Icons.add),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 400, // Adjust the width as needed
                height: 200, // Adjust the height as needed
                child: Image.asset('assets/logo.png'),
              ),
            ),
            SizedBox(height: 30.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'To Do',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _incompleteTasks.length,
                itemBuilder: (context, index) {
                  final task = _incompleteTasks[index];
                  final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now());
                  return ListTile(
                    leading: Checkbox(
                      value: task.completed == 1,
                      onChanged: (bool? value) {
                        _toggleCompletion(task);
                      },
                    ),
                    title: Text(
                      task.name,
                      style: TextStyle(
                        decoration: task.completed == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: task.dueDate != null
                        ? Text(
                      'Due: ${DateFormat('E, d MMMM, yyyy').format(task.dueDate!)}',
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.grey,
                      ),
                    )
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _showDeleteDialog(context, task),
                    ),
                    onTap: () => _navigateToEditDeleteTask(task),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0), // Add some space between lists
            ExpansionTile(
              title: Text(
                'Completed',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              children: [
                Container(
                  height: 200.0, // Adjust the height as needed
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _completedTasks.length,
                    itemBuilder: (context, index) {
                      final task = _completedTasks[index];
                      final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now());
                      return ListTile(
                        leading: Checkbox(
                          value: task.completed == 1,
                          onChanged: (bool? value) {
                            _toggleCompletion(task);
                          },
                        ),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            decoration: task.completed == 1
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: task.dueDate != null
                            ? Text(
                          'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                        )
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                          onPressed: () => _showDeleteDialog(context, task),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete '${task.name}'?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                _removeTask(task.id!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
