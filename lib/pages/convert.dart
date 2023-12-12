import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:expense_manager/constants.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({Key? key}) : super(key: key);

  @override
  _ConvertPageState createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  double amount = 1.0;
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double convertedAmount = 0.0;
  List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildCurrencyDropdown(
                    value: fromCurrency,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        fromCurrency = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Converted Amount'),
                    readOnly: true,
                    controller: TextEditingController(
                      text: convertedAmount.toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildCurrencyDropdown(
                    value: toCurrency,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        toCurrency = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _convertCurrency();
              },
              child: const Text('Convert'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: currencies.map((String currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _fetchCurrencies() async {
    const apiUrl =
        'https://v6.exchangerate-api.com/v6/${Constants.currencyCoverterApiKey}/codes';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        currencies =
            List<String>.from(data['supported_codes'].map((code) => code[0]));
      });
    } else {
      // Handle API error
      print('Failed to fetch currencies: ${response.statusCode}');
    }
  }

  Future<void> _convertCurrency() async {
    const apiKey = '5d903643eec50096ed205816'; // Replace with your API key
    final apiUrl =
        'https://open.er-api.com/v6/latest/$fromCurrency?apiKey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rate = data['rates'][toCurrency];
      setState(() {
        convertedAmount = amount * rate;
      });
    } else {
      // Handle API error
      print('Failed to fetch exchange rates: ${response.statusCode}');
    }
  }
}
