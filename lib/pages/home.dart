import 'package:expense_manager/services/auth_service.dart';
import 'package:expense_manager/widgets/add_transaction_dialog.dart';
import 'package:expense_manager/widgets/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'convert.dart';
import 'graphs.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> pages = [
    const ExpenseList(),
    const ConvertPage(),
    const GraphsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddDialog(context);
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                _navigateToPage(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Convert'),
              onTap: () {
                _navigateToPage(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Report'),
              onTap: () {
                _navigateToPage(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: pages[_currentIndex],
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddTransactionDialog();
      },
    );
  }
}
