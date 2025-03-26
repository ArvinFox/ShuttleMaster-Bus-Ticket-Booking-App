import 'package:flutter/services.dart';
import 'package:shuttlemaster/constants/app_config.dart';

class CustomAuthIdInputFormatter extends TextInputFormatter {
  final String role;

  CustomAuthIdInputFormatter(this.role);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final validPattern = role == AppConfig.passengerRole
      ? RegExp(r'^[0-9]{0,8}$')
      : RegExp(r'^[0-9VXvx]{0,12}$');

    if (validPattern.hasMatch(newValue.text)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}