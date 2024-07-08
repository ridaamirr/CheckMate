import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  final DatabaseHelper dbHelper;

  EditTaskPage({required this.task, required this.dbHelper});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // New controller for description
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;
  String _priority = 'Low'; // Default priority
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _taskNameController.text = widget.task.name;
    _descriptionController.text = widget.task.description ?? ''; // Initialize description controller
    _dueDate = widget.task.dueDate;
    _reminderTime = widget.task.reminderTime;
    _priority = widget.task.priority; // Initialize priority
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['Low', 'Medium', 'High'].map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  ),
                  Text(
                    _dueDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${DateFormat('E, d MMMM, yyyy').format(_dueDate!)}',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _selectTime(context),
                    icon: Icon(Icons.add_alarm, color: Theme.of(context).colorScheme.primary),
                  ),
                  Text(
                    _reminderTime == null
                        ? 'Select Reminder Time'
                        : 'Reminder Time: ${DateFormat('h:mm a').format(DateTime(2024, 1, 1, _reminderTime!.hour, _reminderTime!.minute))}',
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Enter Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              SizedBox(height: 10),
              Container(
                height: 60,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.dbHelper.updateTask(Task(
                        id: widget.task.id,
                        name: _taskNameController.text,
                        description: _descriptionController.text,
                        completed: widget.task.completed,
                        dueDate: _dueDate,
                        reminderTime: _reminderTime,
                        priority: _priority,
                      ));
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    'Update Task',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
