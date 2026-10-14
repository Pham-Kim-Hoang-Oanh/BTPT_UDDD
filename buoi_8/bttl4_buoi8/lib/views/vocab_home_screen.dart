import 'package:flutter/material.dart';

import '../models/vocab.dart';
import '../services/notification_service.dart';
import '../services/vocab_file_service.dart';
import 'vocab_pending_screen.dart';
import 'vocab_practice_screen.dart';
import 'vocab_quiz_screen.dart';

class VocabHomeScreen extends StatefulWidget {
  const VocabHomeScreen({super.key});

  @override
  State<VocabHomeScreen> createState() => _VocabHomeScreenState();
}

class _VocabHomeScreenState extends State<VocabHomeScreen> {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();

  final VocabFileService fileService = VocabFileService();
  final NotificationService notificationService = NotificationService();

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  void openScreen(Widget screen) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void saveAndRemind() async {
    final word = wordController.text.trim();
    final meaning = meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ và nghĩa')),
      );
      return;
    }

    final vocab = Vocab(
      word: word,
      meaning: meaning,
    );

    await fileService.addVocab(vocab);

    await notificationService.showSimpleNotification(
      title: 'Đã lưu từ vựng',
      body: 'Đã lưu "$word". Hãy ôn tập sau 10 phút',
      channelId: 'vocab_save_channel',
      channelName: 'Lưu từ vựng',
    );

    await notificationService.scheduleNotificationAfter(
      delay: const Duration(minutes: 10),
      title: 'Ôn tập từ vựng',
      body: 'Đến giờ ôn lại từ "$word"',
      channelId: 'vocab_review_channel',
      channelName: 'Nhắc ôn từ vựng',
      channelDescription: 'Nhắc học từ sau 10 phút',
    );

    wordController.clear();
    meaningController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu và lên lịch nhắc học từ sau 10 phút'),
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.school),
                ),
                SizedBox(height: 12),
                Text(
                  'Trợ lý học từ vựng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chính'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Học từ'),
            onTap: () => openScreen(const VocabPracticeScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Kiểm tra từ'),
            onTap: () => openScreen(const VocabQuizScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Lịch nhắc'),
            onTap: () => openScreen(const VocabPendingScreen()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        title: const Text('Ứng dụng học từ vựng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: wordController,
              decoration: const InputDecoration(
                labelText: 'Từ',
              ),
            ),
            TextField(
              controller: meaningController,
              decoration: const InputDecoration(
                labelText: 'Nghĩa',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveAndRemind,
              child: const Text('Lưu & Nhắc học sau 10 phút'),
            ),
          ],
        ),
      ),
    );
  }
}