import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/home_task.dart';

class HomeTaskFileService {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/home_tasks.txt');
  }

  Future<List<HomeTask>> loadTasks() async {
    try {
      final file = await _file;
      final content = await file.readAsString();

      final result = <HomeTask>[];

      for (final line in content.split('\n')) {
        if (line.trim().isEmpty) continue;

        try {
          result.add(HomeTask.fromString(line));
        } catch (_) {}
      }

      return result;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<HomeTask> tasks) async {
    final file = await _file;

    final data = tasks.map((e) => e.toFileString()).join('\n');

    await file.writeAsString(data);
  }
}