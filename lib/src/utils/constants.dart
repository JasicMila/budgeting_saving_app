// This file holds application-wide constants
import 'currencies.dart';

// List of currencies
final List<String> currencies = availableCurrencies.keys.toList();

// List of types of activities
enum ActivityType {
  income,
  expense
}