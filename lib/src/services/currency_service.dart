import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/currencies.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app';

  static Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/latest?from=$baseCurrency'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, double>.from(data['rates']);
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  static Future<double> convert(double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;

    final response = await http.get(
      Uri.parse('$_baseUrl/latest?amount=$amount&from=$fromCurrency&to=$toCurrency'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates'][toCurrency];
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  static Future<Map<String, String>> fetchLatestCurrencies() async {
    final response = await http.get(Uri.parse('$_baseUrl/currencies'));

    if (response.statusCode == 200) {
      return Map<String, String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  // This method could be called from an admin panel or update feature
  static Future<void> updateAvailableCurrencies() async {
    try {
      final latestCurrencies = await fetchLatestCurrencies();
      // Here you would update your local storage or database with the new currencies
      // For now, we'll just print the difference
      final newCurrencies = latestCurrencies.keys.toSet().difference(availableCurrencies.keys.toSet());
      final removedCurrencies = availableCurrencies.keys.toSet().difference(latestCurrencies.keys.toSet());

      print('New currencies: $newCurrencies');
      print('Removed currencies: $removedCurrencies');
    } catch (e) {
      print('Failed to update currencies: $e');
    }
  }
}