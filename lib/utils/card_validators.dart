class Validators {
  static String? validateCardNumber(String? value) {
    if (value == null || value.replaceAll(' ', '').length != 16) {
      return 'Enter a valid 16-digit card number';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.length != 5 || !value.contains('/')) {
      return 'Enter a valid expiry date (MM/YY)';
    }

    final parts = value.split('/');
    int month = int.tryParse(parts[0]) ?? 0;
    int year = 2000 + (int.tryParse(parts[1]) ?? 0); // Convert YY to YYYY

    final now = DateTime.now();
    final expiryDate = DateTime(year, month);

    if (expiryDate.isBefore(now)) {
      return 'Enter a future expiry date';
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.length != 3) {
      return 'Enter a valid 3-digit CVV';
    }
    return null;
  }

  static String? validateCardHolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a valid name';
    }
    return null;
  }
}
