import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/notification_service.dart';

class VocabPendingScreen extends StatefulWidget {
  const VocabPendingScreen({super.key});

  @override
  State<VocabPendingScreen> createState() => _VocabPendingScreenState();
}

class _VocabPendingScreenState extends State<VocabPendingScreen> {
  final NotificationService notificationService = NotificationService();

  List<PendingNotificationRequest> pendingList = [];

  @override
  void initState() {
    super.initState();
    loadPending();
  }

  void loadPending() async {
    pendingList = await notificationService.pendingNotifications();
    setState(() {});
  }

  void cancelNotification(int id) async {
    await notificationService.cancel(id);
    loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch nhắc'),
        actions: [
          IconButton(
            onPressed: loadPending,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pendingList.isEmpty
          ? const Center(
              child: Text('Không có lịch nhắc nào'),
            )
          : ListView.builder(
              itemCount: pendingList.length,
              itemBuilder: (context, index) {
                final item = pendingList[index];

                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(item.title ?? 'Không có tiêu đề'),
                  subtitle: Text(item.body ?? ''),
                  trailing: IconButton(
                    onPressed: () => cancelNotification(item.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                );
              },
            ),
    );
  }
}