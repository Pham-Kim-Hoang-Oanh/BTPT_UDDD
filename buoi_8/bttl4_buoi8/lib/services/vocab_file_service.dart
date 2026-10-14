import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/vocab.dart';

class VocabFileService {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/vocabs.txt');
  }

  Future<List<Vocab>> loadVocabs() async {
    try {
      final file = await _file;
      final content = await file.readAsString();

      final result = <Vocab>[];

      for (final line in content.split('\n')) {
        if (line.trim().isEmpty) continue;

        try {
          result.add(Vocab.fromString(line));
        } catch (_) {}
      }

      return result;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVocabs(List<Vocab> vocabs) async {
    final file = await _file;

    final data = vocabs.map((e) => e.toFileString()).join('\n');

    await file.writeAsString(data);
  }

  Future<void> addVocab(Vocab vocab) async {
    final vocabs = await loadVocabs();
    vocabs.add(vocab);
    await saveVocabs(vocabs);
  }
}