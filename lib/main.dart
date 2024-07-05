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
        brightness: Brightness.light, // Set brightness to light for white background and black text
        scaffoldBackgroundColor: Colors.white, // Set scaffold background color to white
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black), // Set text color to black
          bodyText2: TextStyle(color: Colors.black), // Set text color to black
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink, // Example primary color swatch
          backgroundColor: Colors.white, // Set background color to white
          brightness: Brightness.light, // Set brightness to light
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Set app bar background color to white
          foregroundColor: Colors.black, // Set app bar text color to black
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset('assets/logo.png'),
            ),
            SizedBox(height: 80.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'To Do',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _incompleteTasks.length,
                itemBuilder: (context, index) {
                  final task = _incompleteTasks[index];
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _removeTask(task.id!),
                    ),
                    onTap: () => _navigateToEditDeleteTask(task),
                  );
                },
              ),
            ),
            ExpansionTile(
              title: Text(
                'Completed',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = _completedTasks[index];
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                        onPressed: () => _removeTask(task.id!),
                      ),
                      onTap: () => _navigateToEditDeleteTask(task),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }




}
