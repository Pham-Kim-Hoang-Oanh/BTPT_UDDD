import 'dart:math';

import 'package:flutter/material.dart';

import '../models/vocab.dart';
import '../services/vocab_file_service.dart';

class VocabQuizScreen extends StatefulWidget {
  const VocabQuizScreen({super.key});

  @override
  State<VocabQuizScreen> createState() => _VocabQuizScreenState();
}

class _VocabQuizScreenState extends State<VocabQuizScreen> {
  final VocabFileService fileService = VocabFileService();
  final Random random = Random();

  List<Vocab> vocabs = [];

  Vocab? currentVocab;
  String displayedMeaning = '';
  bool pairIsCorrect = true;

  int correctCount = 0;
  int wrongCount = 0;
  int answeredCount = 0;

  final int totalQuestion = 10;

  @override
  void initState() {
    super.initState();
    loadVocabs();
  }

  void loadVocabs() async {
    vocabs = await fileService.loadVocabs();

    if (vocabs.isNotEmpty) {
      generateQuestion();
    }

    setState(() {});
  }

  void generateQuestion() {
    if (vocabs.isEmpty) return;

    final word = vocabs[random.nextInt(vocabs.length)];

    bool correctPair = random.nextBool();

    if (vocabs.length == 1) {
      correctPair = true;
    }

    String meaning = word.meaning;

    if (!correctPair) {
      final others = vocabs.where((e) => e.meaning != word.meaning).toList();

      if (others.isNotEmpty) {
        meaning = others[random.nextInt(others.length)].meaning;
      } else {
        correctPair = true;
      }
    }

    currentVocab = word;
    displayedMeaning = meaning;
    pairIsCorrect = correctPair;
  }

  void answer(bool userChooseCorrect) {
    final result = userChooseCorrect == pairIsCorrect;

    if (result) {
      correctCount++;
    } else {
      wrongCount++;
    }

    answeredCount++;

    if (answeredCount >= totalQuestion) {
      setState(() {});
      showResultDialog();
    } else {
      generateQuestion();
      setState(() {});
    }
  }

  void showResultDialog() {
    final total = correctCount + wrongCount;
    final ratio = total == 0 ? 0 : correctCount * 100 / total;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Kết thúc bài kiểm tra'),
          content: Text(
            'Số câu đúng: $correctCount\n'
            'Số câu sai: $wrongCount\n'
            'Tỉ lệ đúng: ${ratio.toStringAsFixed(1)}%',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                correctCount = 0;
                wrongCount = 0;
                answeredCount = 0;

                generateQuestion();
                setState(() {});
              },
              child: const Text('Làm lại'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Thoát'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (vocabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trắc nghiệm Đúng / Sai'),
        ),
        body: const Center(
          child: Text('Chưa có dữ liệu từ vựng'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trắc nghiệm Đúng / Sai'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(
                  backgroundColor: Colors.green,
                  label: Text('Đúng: $correctCount'),
                ),
                Chip(
                  backgroundColor: Colors.orange,
                  label: Text('Sai: $wrongCount'),
                ),
              ],
            ),

            const SizedBox(height: 50),

            Text(
              currentVocab?.word ?? '',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                displayedMeaning,
                style: const TextStyle(fontSize: 20),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => answer(true),
                  icon: const Icon(Icons.check),
                  label: const Text('Đúng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => answer(false),
                  icon: const Icon(Icons.close),
                  label: const Text('Sai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}