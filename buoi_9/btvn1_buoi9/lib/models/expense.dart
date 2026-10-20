class Expense {
  final int? id;
  final String content;
  final double amount;
  final String note;

  Expense({
    this.id,
    required this.content,
    required this.amount,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'amount': amount,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int,
      content: map['content'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
    );
  }
}