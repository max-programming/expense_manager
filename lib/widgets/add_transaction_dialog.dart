import 'package:expense_manager/main.dart';
import 'package:expense_manager/models/earning.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  String _category = 'Expense'; // Default category is 'Expense'

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _dueDateController,
              decoration: const InputDecoration(labelText: 'Due Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _dueDateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Expense', 'Earning']
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            _addTransaction(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addTransaction(BuildContext context) {
    final String title = _titleController.text.trim();
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final String dueDateString = _dueDateController.text.trim();
    final DateTime? dueDate = dueDateString.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(dueDateString)
        : null;

    if (title.isNotEmpty && amount > 0) {
      final ExpenseService expenseService = context.read<ExpenseService>();
      if (_category == 'Expense') {
        expenseService.addExpense(
          Expense(
            id: '',
            title: title,
            amount: amount,
            date: DateTime.now(),
            dueDate: dueDate,
            category: 'Expense',
          ),
        );

        // Schedule notification if due date is provided
        if (dueDate != null) {
          scheduleNotification(
            'Expense Due',
            '$title is due on ${DateFormat('yyyy-MM-dd').format(dueDate)}',
            dueDate,
          );
        }
      } else if (_category == 'Earning') {
        expenseService.addEarning(
          Earning(
            id: '',
            title: title,
            amount: amount,
            date: DateTime.now(),
            category: 'Earning',
          ),
        );
      }

      // Close the dialog
      Navigator.pop(context);
    } else {
      // Show an error message if title or amount is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid title or amount.'),
        ),
      );
    }
  }
}
