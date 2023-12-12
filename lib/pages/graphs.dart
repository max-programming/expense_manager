import 'package:expense_manager/models/earning.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/services/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GraphsPage extends StatefulWidget {
  const GraphsPage({Key? key}) : super(key: key);

  @override
  _GraphsPageState createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  final ExpenseService expenseService = ExpenseService();

  Future<Map<String, List<dynamic>>> _fetchData() async {
    List<Expense> expenses = await expenseService.getExpenses().first;
    List<Earning> earnings = await expenseService.getEarnings().first;

    return {
      'expenses': expenses,
      'earnings': earnings,
    };
  }

  List<PieChartSectionData> _getSections(
      List<dynamic>? expenses, List<dynamic>? earnings) {
    List<PieChartSectionData> sections = [];

    if (expenses != null && expenses.isNotEmpty) {
      sections.addAll(expenses.map((expense) {
        return PieChartSectionData(
          color: Colors.red[400], // red-ish color for expenses
          value: expense.amount.toDouble(),
          title: "",
          radius: 30,
        );
      }).toList());
    }

    if (earnings != null && earnings.isNotEmpty) {
      sections.addAll(earnings.map((earning) {
        return PieChartSectionData(
          color: Colors.green[400], // green-ish color for earnings
          value: earning.amount.toDouble(),
          title: '',
          radius: 30,
        );
      }).toList());
    }

    return sections;
  }

  List<BarChartGroupData> _getBarGroups(
      List<dynamic>? expenses, List<dynamic>? earnings) {
    List<BarChartGroupData> barGroups = [];
    barGroups.add(_getBarGroup(expenses ?? [], 0));
    barGroups.add(_getBarGroup(earnings ?? [], 1));
    return barGroups;
  }

  BarChartGroupData _getBarGroup(List<dynamic> data, int index) {
    List<BarChartRodData> barRods = data.map((item) {
      double value = item.amount.toDouble();
      return BarChartRodData(
        toY: value,
        color: index == 0 ? Colors.red : Colors.green,
        width: 20,
      );
    }).toList();

    return BarChartGroupData(
      x: index,
      barRods: barRods,
      showingTooltipIndicators: [index],
    );
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<void> _downloadExcel() async {
    final data = await _fetchData();

// Create a new Excel workbook
    final excel = Excel.createExcel();

// Add a worksheet for expenses
    final Sheet expenseSheet = excel['Expenses'];
    expenseSheet.appendRow([
      const TextCellValue('Title'),
      const TextCellValue('Amount'),
      const TextCellValue('Date'),
      const TextCellValue('Category'),
    ]);

    for (Expense expense in data['expenses']!) {
      expenseSheet.appendRow([
        TextCellValue(expense.title),
        TextCellValue(expense.amount.toString()), // Convert amount to String
        TextCellValue(expense.date.toString()), // Convert date to String
        TextCellValue(expense.category),
      ]);
    }

    // Save the Excel file to the device
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/transactions_report.xlsx';
    final File file = File(path);
    final List<int>? encodedData = excel.encode();

    if (encodedData != null) {
      file.writeAsBytes(encodedData);
      OpenFile.open(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: const [
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   onPressed: () {
          //     _downloadExcel();
          //   },
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FutureBuilder(
            future: _fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final Map<String, List<dynamic>> data =
                    snapshot.data as Map<String, List<dynamic>>;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Earning vs Expense Pie Chart'),
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections:
                              _getSections(data['expenses'], data['earnings']),
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 40,
                          sectionsSpace: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Expense vs Earning Bar Chart'),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          barGroups:
                              _getBarGroups(data['expenses'], data['earnings']),
                          titlesData: const FlTitlesData(show: true),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
