import 'dart:convert';

class Vocab {
  String word;
  String meaning;

  Vocab({
    required this.word,
    required this.meaning,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
    };
  }

  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }

  String toFileString() {
    return jsonEncode(toJson());
  }

  static Vocab fromString(String line) {
    final data = Map<String, dynamic>.from(jsonDecode(line));
    return Vocab.fromJson(data);
  }
}