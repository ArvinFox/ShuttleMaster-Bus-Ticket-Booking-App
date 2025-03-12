class Formatters {
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith("+94")) {
      // ignore: prefer_interpolation_to_compose_strings
      return '0' + phoneNumber.substring(3);
    }

    return phoneNumber;
  }

  static String getMaskedPhoneNumber(String? phoneNumber) {
    String formatPhone = Formatters.formatPhoneNumber(phoneNumber!);
    int starsCount = formatPhone.length - 6;
    return formatPhone.substring(0, 3) + ('*' * starsCount) + formatPhone.substring(formatPhone.length - 3);
  }

  static String getMaskedEmail(String email) {
    int starsCount = email.split('@')[0].length - 3;
    return email.substring(0, 3) + ('*' * starsCount) + email.substring(email.indexOf('@'));
  }
}