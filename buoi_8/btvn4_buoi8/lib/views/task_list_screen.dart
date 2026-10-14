import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/home_task.dart';
import '../services/home_task_file_service.dart';
import '../services/notification_service.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final HomeTaskFileService fileService = HomeTaskFileService();
  final NotificationService notificationService = NotificationService();

  List<HomeTask> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    tasks = await fileService.loadTasks();
    setState(() {});
  }

  String formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }

  int completedCount() {
    return tasks.where((e) => e.done).length;
  }

  void openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );

    if (result == true) {
      loadTasks();
    }
  }

  void confirmDone(int index, bool? value) async {
    if (value == null) return;

    if (value == false) {
      tasks[index].done = false;

      await fileService.saveTasks(tasks);

      setState(() {});
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Nhiệm vụ này đã hoàn thành?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      tasks[index].done = true;

      await fileService.saveTasks(tasks);

      setState(() {});

      await notificationService.showSimpleNotification(
        title: 'Nhiệm vụ hoàn thành',
        body: 'Bạn đã hoàn thành ${completedCount()} nhiệm vụ',
        channelId: 'task_done_channel',
        channelName: 'Hoàn thành nhiệm vụ',
      );
    }
  }

  void setReminder(int index) async {
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

    final remindTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (remindTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ nhắc phải lớn hơn hiện tại')),
      );
      return;
    }

    final task = tasks[index];

    final id = await notificationService.scheduleNotification(
      id: task.notificationId == 0 ? null : task.notificationId,
      title: 'Nhắc nhiệm vụ',
      body: task.title,
      scheduledTime: remindTime,
      channelId: 'home_task_channel',
      channelName: 'Nhắc nhiệm vụ',
      channelDescription: 'Thông báo nhắc nhiệm vụ',
    );

    task.remindTime = remindTime;
    task.notificationId = id;

    await fileService.saveTasks(tasks);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thiết lập giờ nhắc')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ mỗi ngày'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddScreen,
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('Chưa có nhiệm vụ nào'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: task.done,
                      onChanged: (value) => confirmDone(index, value),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      task.remindTime == null
                          ? 'Chưa có giờ nhắc'
                          : 'Nhắc lúc: ${formatTime(task.remindTime!)}',
                    ),
                    trailing: IconButton(
                      onPressed: () => setReminder(index),
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ),
                );
              },
            ),
    );
  }
}