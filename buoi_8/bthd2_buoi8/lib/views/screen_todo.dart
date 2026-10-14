import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../services/file_services.dart';

class ScreenTodo extends StatefulWidget {
  const ScreenTodo({super.key});

  @override
  State<ScreenTodo> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<ScreenTodo> {
  final TextEditingController controller = TextEditingController();

  final FileService fileService = FileService();

  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loadData() async {
    todos = await fileService.loadTodos();
    setState(() {});
  }

  void addTodo() async {
    if (controller.text.trim().isEmpty || selectedTime == null) {
      return;
    }

    final todo = Todo(
      title: controller.text.trim(),
      time: selectedTime!,
    );

    todos.add(todo);

    await fileService.saveTodos(todos);

    controller.clear();
    selectedTime = null;

    setState(() {});
  }

  void pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    selectedTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {});
  }

  String formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
    ];

    Color getTextColor(Color bg) {
      return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Tên công việc',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? 'Chưa chọn thời gian'
                        : formatTime(selectedTime!),
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDateTime,
                  child: const Text('Chọn thời gian'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addTodo,
              child: const Text('Lưu'),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  final bgColor = colors[index % colors.length];

                  return Card(
                    color: bgColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.task,
                        color: getTextColor(bgColor),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          color: getTextColor(bgColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        formatTime(todo.time),
                        style: TextStyle(
                          color: getTextColor(bgColor).withOpacity(0.7),
                        ),
                      ),
                    ),
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