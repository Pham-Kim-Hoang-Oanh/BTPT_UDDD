import 'dart:convert';

class HomeTask {
  String title;
  DateTime? remindTime;
  bool done;
  int notificationId;

  HomeTask({
    required this.title,
    this.remindTime,
    this.done = false,
    this.notificationId = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'remindTime': remindTime?.toIso8601String(),
      'done': done,
      'notificationId': notificationId,
    };
  }

  factory HomeTask.fromJson(Map<String, dynamic> json) {
    final remind = json['remindTime'];

    return HomeTask(
      title: json['title'] ?? '',
      remindTime: remind == null ? null : DateTime.tryParse(remind.toString()),
      done: json['done'] == true,
      notificationId: json['notificationId'] ?? 0,
    );
  }

  String toFileString() {
    return jsonEncode(toJson());
  }

  static HomeTask fromString(String line) {
    final data = Map<String, dynamic>.from(jsonDecode(line));
    return HomeTask.fromJson(data);
  }
}