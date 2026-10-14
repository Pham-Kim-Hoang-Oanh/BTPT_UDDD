import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../services/file_services.dart';
import '../services/notification_service.dart';

class ScreenTodoNoti extends StatefulWidget {
  const ScreenTodoNoti({super.key});

  @override
  State<ScreenTodoNoti> createState() => _ScreenTodoNotiState();
}

class _ScreenTodoNotiState extends State<ScreenTodoNoti> {
  final TextEditingController controller = TextEditingController();

  final FileService fileService = FileService();
  final NotificationService notificationService = NotificationService();

  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    loadData();
    notificationService.init();
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

  String formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  void addTodo() async {
    if (controller.text.trim().isEmpty || selectedTime == null) {
      showSnack('Vui lòng nhập công việc và chọn thời gian');
      return;
    }

    if (selectedTime!.isBefore(DateTime.now())) {
      showSnack('Thời gian phải lớn hơn hiện tại');
      return;
    }

    final todo = Todo(
      title: controller.text.trim(),
      time: selectedTime!,
    );

    todos.add(todo);

    await fileService.saveTodos(todos);

    await notificationService.showSimpleNotification(
      title: 'Đã thêm lịch',
      body: 'Đã thêm lịch cho công việc: ${todo.title}',
      channelId: 'todo_added_channel',
      channelName: 'Thông báo thêm lịch',
    );

    await notificationService.scheduleNotification(
      title: 'Nhắc việc',
      body: 'Đến giờ làm: ${todo.title}',
      scheduledTime: todo.time,
      channelId: 'todo_reminder_channel',
      channelName: 'Nhắc việc',
      channelDescription: 'Nhắc việc theo giờ đã chọn',
    );

    controller.clear();
    selectedTime = null;

    setState(() {});

    showSnack('Đã lưu và thiết lập lịch nhắc');
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App Notification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tên công việc',
                border: OutlineInputBorder(),
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
                  final color = colors[index % colors.length];

                  return Card(
                    color: color,
                    child: ListTile(
                      leading: const Icon(Icons.alarm),
                      title: Text(
                        todo.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(formatTime(todo.time)),
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