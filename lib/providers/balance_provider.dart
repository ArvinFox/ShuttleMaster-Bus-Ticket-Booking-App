import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceProvider extends ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  BalanceProvider() {
    _loadBalance();
  }

  // Load balance from SharedPreferences
  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble('currentBalance') ?? 0.0;
    notifyListeners();
  }

  // Update balance and save to SharedPreferences
  Future<void> addBalance(double amount) async {
    _balance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('currentBalance', _balance);
    notifyListeners();
  }
}
