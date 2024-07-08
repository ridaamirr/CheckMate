import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // New controller for description
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;
  final _formKey = GlobalKey<FormState>();

  String _priority = 'Low'; // Default priority

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
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
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _taskController,
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
                items: ['Low', 'Medium', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
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
                  labelText: 'Enter Description', // Description field
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
                      String taskName = _taskController.text.trim();
                      String description = _descriptionController.text.trim(); // Get description value
                      Navigator.pop(
                        context,
                        {
                          'taskName': taskName,
                          'dueDate': _dueDate,
                          'reminderTime': _reminderTime,
                          'description': description,
                          'priority': _priority,
                        },
                      );
                    }
                  },
                  child: Text(
                    'Add Task',
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
