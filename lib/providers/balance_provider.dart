import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceProvider extends ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  BalanceProvider() {
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble('current_balance') ?? 0.0;
    notifyListeners();
  }

  Future<void> updateBalance(double amount) async {
    _balance = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('current_balance', _balance);
    notifyListeners();
  }
}
