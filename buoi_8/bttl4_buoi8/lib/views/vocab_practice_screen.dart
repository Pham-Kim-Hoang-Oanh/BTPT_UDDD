import 'package:flutter/material.dart';

import '../models/vocab.dart';
import '../services/notification_service.dart';
import '../services/vocab_file_service.dart';

class VocabPracticeScreen extends StatefulWidget {
  const VocabPracticeScreen({super.key});

  @override
  State<VocabPracticeScreen> createState() => _VocabPracticeScreenState();
}

class _VocabPracticeScreenState extends State<VocabPracticeScreen> {
  final TextEditingController answerController = TextEditingController();

  final VocabFileService fileService = VocabFileService();
  final NotificationService notificationService = NotificationService();

  List<Vocab> vocabs = [];
  int index = 0;

  int correctCount = 0;
  int wrongCount = 0;

  @override
  void initState() {
    super.initState();
    loadVocabs();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void loadVocabs() async {
    vocabs = await fileService.loadVocabs();
    vocabs.shuffle();

    setState(() {});
  }

  String normalize(String text) {
    return text.trim().toLowerCase();
  }

  void checkAnswer() async {
    if (vocabs.isEmpty) return;

    final current = vocabs[index];
    final answer = answerController.text;

    final isCorrect = normalize(answer) == normalize(current.meaning);

    if (isCorrect) {
      correctCount++;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chính xác!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      wrongCount++;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sai rồi! Nghĩa đúng là: ${current.meaning}'),
          backgroundColor: Colors.red,
        ),
      );

      if (wrongCount % 3 == 0) {
        await notificationService.showSimpleNotification(
          title: 'Bạn sai $wrongCount lần rồi',
          body: 'Hãy ôn tập lại từ vựng nhé!',
          channelId: 'vocab_wrong_channel',
          channelName: 'Sai từ vựng',
        );
      }
    }

    answerController.clear();

    index = (index + 1) % vocabs.length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (vocabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ôn tập từ mới'),
        ),
        body: const Center(
          child: Text('Chưa có từ vựng nào'),
        ),
      );
    }

    final current = vocabs[index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn tập từ mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  backgroundColor: Colors.green,
                  label: Text('✓ $correctCount từ'),
                ),
                const SizedBox(width: 20),
                Chip(
                  backgroundColor: Colors.orange,
                  label: Text('✕ $wrongCount từ'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.blue.shade100,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      current.word,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: answerController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập nghĩa tiếng Việt',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: checkAnswer,
                      child: const Text('Check'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}