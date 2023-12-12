import 'package:expense_manager/models/earning.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var expenses = context.watch<ExpenseService>().getExpenses();
    var earnings = context.watch<ExpenseService>().getEarnings();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildListTile("Expenses", expenses, Colors.red[100]!),
          _buildListTile("Earnings", earnings, Colors.green[100]!),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, Stream<List<dynamic>> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          color: color,
          child: StreamBuilder<List<dynamic>>(
            stream: data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No $title found.'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${item.amount.toStringAsFixed(2)}'),
                        if (item.category != null)
                          Text('Category: ${item.category}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item.date.year}-${item.date.month}-${item.date.day}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, item);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      if (item.latitude != null && item.longitude != null) {
                        _showLocationDialog(
                          context,
                          item.latitude,
                          item.longitude,
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLocationDialog(
    BuildContext context,
    double latitude,
    double longitude,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${item.title}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTransaction(context, item);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(BuildContext context, dynamic item) {
    final ExpenseService expenseService = context.read<ExpenseService>();
    if (item is Expense) {
      expenseService.deleteExpense(item.id);
    } else if (item is Earning) {
      expenseService.deleteEarning(item.id);
    }
    Navigator.pop(context); // Close the delete confirmation dialog
  }
}
