import 'package:flutter/material.dart';

import '../controllers/expense_controller.dart';
import '../models/expense.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseController _controller = ExpenseController();

  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await _controller.getExpenses();

    if (!mounted) return;

    setState(() {
      _expenses = data;
      _isLoading = false;
    });
  }

  double get _totalAmount {
    return _expenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0)} VNĐ';
  }

  Future<void> _showExpenseForm({Expense? expense}) async {
  final formKey = GlobalKey<FormState>();

  final contentController = TextEditingController(
    text: expense?.content ?? '',
  );

  final amountController = TextEditingController(
    text: expense == null ? '' : expense.amount.toStringAsFixed(0),
  );

  final noteController = TextEditingController(
    text: expense?.note ?? '',
  );

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          expense == null ? 'Thêm chi tiêu' : 'Cập nhật chi tiêu',
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung chi tiêu',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Số tiền',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (amount == null || amount <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              final newExpense = Expense(
                id: expense?.id,
                content: contentController.text.trim(),
                amount: double.parse(
                  amountController.text.trim(),
                ),
                note: noteController.text.trim(),
              );

              if (expense == null) {
                await _controller.insertExpense(newExpense);
              } else {
                await _controller.updateExpense(newExpense);
              }

              // Tải lại danh sách trước khi đóng dialog.
              await _loadExpenses();

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );
 
}

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có muốn xóa khoản chi "${expense.content}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && expense.id != null) {
      await _controller.deleteExpense(expense.id!);
      await _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Tổng tiền đã chi',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatMoney(_totalAmount),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? const Center(
                        child: Text('Chưa có khoản chi tiêu nào'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];

                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.payments),
                              ),
                              title: Text(
                                expense.content,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                expense.note.isEmpty
                                    ? 'Không có ghi chú'
                                    : expense.note,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatMoney(expense.amount),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showExpenseForm(expense: expense);
                                      } else if (value == 'delete') {
                                        _deleteExpense(expense);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Cập nhật'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showExpenseForm(expense: expense);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}