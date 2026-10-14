import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/home_task.dart';
import '../services/home_task_file_service.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final HomeTaskFileService fileService = HomeTaskFileService();
  final NotificationService notificationService = NotificationService();

  DateTime? selectedTime;

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    super.dispose();
  }

  String formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
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

    timeController.text = formatTime(selectedTime!);

    setState(() {});
  }

  void saveTask() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhiệm vụ')),
      );
      return;
    }

    if (selectedTime != null && selectedTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ nhắc phải lớn hơn hiện tại')),
      );
      return;
    }

    final task = HomeTask(
      title: title,
      remindTime: selectedTime,
    );

    if (selectedTime != null) {
      final id = await notificationService.scheduleNotification(
        title: 'Nhắc nhiệm vụ',
        body: title,
        scheduledTime: selectedTime!,
        channelId: 'home_task_channel',
        channelName: 'Nhắc nhiệm vụ',
        channelDescription: 'Thông báo nhắc nhiệm vụ',
      );

      task.notificationId = id;
    }

    final tasks = await fileService.loadTasks();
    tasks.add(task);

    await fileService.saveTasks(tasks);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm nhiệm vụ mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên nhiệm vụ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: timeController,
              readOnly: true,
              onTap: pickDateTime,
              decoration: InputDecoration(
                labelText: 'Giờ nhắc',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: pickDateTime,
                  icon: const Icon(Icons.notifications_none),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveTask,
              child: const Text('Lưu nhiệm vụ'),
            ),
          ],
        ),
      ),
    );
  }
}